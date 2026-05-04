import { readFile } from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

import Ajv2020 from 'ajv/dist/2020.js'
import addFormats from 'ajv-formats'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const repoRoot = path.resolve(__dirname, '..')
const profilesPath = path.resolve(repoRoot, 'deployments/profiles.json')
const schemaPath = path.resolve(repoRoot, 'deployments/profiles.schema.json')

async function readJson(filePath) {
	return JSON.parse(await readFile(filePath, 'utf8'))
}

function fail(message) {
	throw new Error(message)
}

function validateRegistry(profile) {
	const { registry } = profile
	const hasAddress = typeof registry.address === 'string'
	const hasDeploymentBlock = typeof registry.deploymentBlock === 'string'
	const hasExplorerUrl = typeof registry.explorerUrl === 'string'

	if (registry.status === 'not-deployed') {
		if (hasAddress || hasDeploymentBlock || hasExplorerUrl) {
			fail(
				`Profile "${profile.id}" is marked not-deployed but still carries registry deployment fields.`
			)
		}
		return
	}

	if (!hasAddress) {
		fail(`Profile "${profile.id}" must include registry.address when registry.status is ${registry.status}.`)
	}
	if (!hasDeploymentBlock) {
		fail(
			`Profile "${profile.id}" must include registry.deploymentBlock when registry.status is ${registry.status}.`
		)
	}
	if (registry.status === 'verified' && !hasExplorerUrl) {
		fail(`Profile "${profile.id}" must include registry.explorerUrl when registry.status is verified.`)
	}
}

function validateProfileSemantics(artifact) {
	const seenIds = new Set()
	const profileIds = new Set(artifact.profiles.map(profile => profile.id))

	for (const profile of artifact.profiles) {
		if (seenIds.has(profile.id)) {
			fail(`Duplicate profile id "${profile.id}" found in profiles artifact.`)
		}
		seenIds.add(profile.id)

		const expectedCaip2 = `${profile.chain.namespace}:${profile.chain.chainId}`
		if (profile.chain.caip2 !== expectedCaip2) {
			fail(
				`Profile "${profile.id}" has chain.caip2 "${profile.chain.caip2}" but expected "${expectedCaip2}".`
			)
		}

		if (profile.x402.defaultPaymentNetwork !== expectedCaip2) {
			fail(
				`Profile "${profile.id}" has x402.defaultPaymentNetwork "${profile.x402.defaultPaymentNetwork}" but expected "${expectedCaip2}".`
			)
		}

		if (!Array.isArray(profile.chain.defaultRpcUrls) || profile.chain.defaultRpcUrls.length === 0) {
			fail(`Profile "${profile.id}" must include at least one default RPC URL.`)
		}

		if (!profile.linker.enabled && profile.linker.managementEnabled) {
			fail(`Profile "${profile.id}" cannot enable management when linker.enabled is false.`)
		}

		if (profile.linker.managementEnabled && profile.registry.status === 'not-deployed') {
			fail(`Profile "${profile.id}" cannot enable management before the registry is deployed.`)
		}

		if (profile.status === 'stable' && profile.registry.status !== 'verified') {
			fail(`Profile "${profile.id}" cannot be stable until the registry status is verified.`)
		}

		validateRegistry(profile)
	}

	for (const overlay of artifact.partnerOverlays) {
		if (!profileIds.has(overlay.profileId)) {
			fail(`Partner overlay "${overlay.id}" references missing profile "${overlay.profileId}".`)
		}
	}
}

const schema = await readJson(schemaPath)
const artifact = await readJson(profilesPath)

const ajv = new Ajv2020({
	allErrors: true,
	strict: true,
	validateFormats: true,
})
addFormats(ajv)

const validate = ajv.compile(schema)
if (!validate(artifact)) {
	const message = validate.errors
		?.map(error => `${error.instancePath || '/'} ${error.message}`)
		.join('\n')
	fail(`profiles.json failed schema validation:\n${message}`)
}

validateProfileSemantics(artifact)

console.log(
	`Validated ${artifact.profiles.length} profile(s) and ${artifact.partnerOverlays.length} partner overlay(s).`
)
