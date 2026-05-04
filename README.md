# AgentLink Contracts

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

On-chain registry linking AI agent wallets to human-verified owner wallets on Base.

## Deployments

### BiomapperAgentRegistry

| Network | Address |
|---------|---------|
| Base | [`0x31e98F489ad65dF5Ee43CBe06e4f35557Cd0abb2`](https://basescan.org/address/0x31e98F489ad65dF5Ee43CBe06e4f35557Cd0abb2) |
| Base Sepolia | [`0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2`](https://sepolia.basescan.org/address/0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2) |

## Overview

`BiomapperAgentRegistry` links AI agent wallets to human-verified owner wallets via [Humanode](https://humanode.io) biomapping. A link is active only while the owner remains biomapped — if their verification lapses, the link goes dormant automatically and reactivates when they re-verify. No admin keys. No upgrades.

```
owner (biomapped human) ──link──▶ agent wallet
                                       │
                         BridgedBiomapper confirms active status live
```

**Properties**

- Immutable `BridgedBiomapper` dependency — set once at deployment, never changed
- Stores only `agent → owner` mappings, nothing else
- Agent consent verified via EIP-712 signature — supports EOA and ERC-1271 smart wallets
- Active status derived live from the Biomapper, never cached
- Owner can relink an agent to a new wallet with fresh agent consent
- Either party — owner or agent — can unlink at any time

## Interface

```solidity
/// Link an agent to the caller. Caller must be biomapped.
function linkAgent(address agent, uint256 deadline, bytes calldata signature) external;

/// Unlink. Callable by the linked owner or the agent itself.
function unlinkAgent(address agent) external;

/// Returns (owner, generationPtr, active).
function getAgentStatus(address agent) external view returns (address, uint256, bool);

/// Current nonce for building agent consent signatures.
function agentNonce(address agent) external view returns (uint256);

/// Stored owner address (zero if never linked), regardless of active status.
function linkedOwner(address agent) external view returns (address);
```

## Repository Layout

```
src/          BiomapperAgentRegistry and interfaces
test/         Foundry tests and test-only mocks
script/       Foundry deployment scripts
ignition/     Hardhat Ignition module and network parameters
deployments/  Published deployment metadata and addresses
```

## Development

**Prerequisites:** [Foundry](https://getfoundry.sh), [Node.js](https://nodejs.org), [pnpm](https://pnpm.io)

```bash
# Install dependencies
pnpm install

# Compile
pnpm contracts:compile

# Test (Hardhat)
pnpm contracts:test

# Test (Foundry)
forge soldeer install
forge build --sizes
forge test -vvv
```

## Deployment Metadata

Deployment profiles live in [`deployments/profiles.json`](./deployments/profiles.json). Update these before syncing addresses into any downstream SDK, linker, or docs.

Validate before publishing:

```bash
pnpm validate:profiles
```

## Security

This contract has not yet undergone a formal third-party audit. Use in production at your own risk.

To report a vulnerability, email **security@humanode.io**. Please do not open a public GitHub issue for security concerns.

## License

[MIT](./LICENSE)
