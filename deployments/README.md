# AgentLink Registry Deployments

This folder records AgentLink registry deployment metadata.

The deployment records are the contracts-side source for profile metadata. SDK, linker, docs, and demos should consume or copy from generated profile artifacts later, not hand-maintain registry addresses independently.

## Records

- [Machine-readable profile artifact](./profiles.json)
- [Profile artifact schema](./profiles.schema.json)
- [Base Sepolia](./base-sepolia.md)
- [Base mainnet](./base.md)
- [Deployment template](./TEMPLATE.md)

## Required Fields

Every live registry deployment must record:

- profile id
- chain id
- CAIP-2 chain id
- registry address
- Bridged Biomapper address
- deployment block
- deploy commit
- deployer
- deployment date
- ABI version
- verification status
- explorer URL

Missing production data must be explicit. Do not use placeholder addresses in generated profile metadata.

## Artifact Rules

- `profiles.json` is the first machine-readable handoff for SDK, linker, docs, and demos.
- `pnpm validate:profiles` MUST pass before `profiles.json` changes are merged.
- Markdown deployment records remain the review surface for humans.
- A profile with no live registry must omit `registry.address` and use `registry.status: "not-deployed"`.
- Public docs must not claim stable support for any profile unless the artifact has a verified registry address and deployment block.
- Partner overlays stay empty until a real pilot has an owner, visibility, and support status.

## Validation Rules

Methodology: evolutionary architecture fitness functions and arc42 quality evidence.

Source: [Thoughtworks Technology Radar: Evolutionary architecture](https://www.thoughtworks.com/en-us/radar/techniques/evolutionary-architecture), [arc42 quality requirements](https://quality.arc42.org/requirements/)

The artifact validation step checks both schema shape and semantic invariants:

- profile ids must be unique
- `chain.caip2` must match `namespace + chainId`
- `x402.defaultPaymentNetwork` must match the profile chain
- deployed and verified registries must include address and deployment block
- verified registries must include an explorer URL
- stable profiles must point to a verified registry
- linker management cannot be enabled before a registry is deployed
- partner overlays must reference an existing profile id
