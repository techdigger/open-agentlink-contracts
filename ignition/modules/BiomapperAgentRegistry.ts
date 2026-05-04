import { buildModule } from '@nomicfoundation/hardhat-ignition/modules'

const BiomapperAgentRegistryModule = buildModule('BiomapperAgentRegistryModule', m => {
	const bridgedBiomapper = m.getParameter('bridgedBiomapper')

	const registry = m.contract('BiomapperAgentRegistry', [bridgedBiomapper])

	return { registry }
})

export default BiomapperAgentRegistryModule
