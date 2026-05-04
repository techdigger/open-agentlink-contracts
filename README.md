<img alt="AgentLink" src="https://raw.githubusercontent.com/techdigger/agentlink-landing/master/public/brand/wordmark.svg" height="48" />

On-chain registry linking AI agent wallets to biomapped human wallets.

To learn more about AgentLink see the [docs].

[docs]: https://agentlink.humanode.io/docs

## Contract Addresses

| Network | Contract | Address |
|---------|----------|---------|
| Base | `BiomapperAgentRegistry` | [`0x31e98F489ad65dF5Ee43CBe06e4f35557Cd0abb2`](https://basescan.org/address/0x31e98F489ad65dF5Ee43CBe06e4f35557Cd0abb2) |
| Base Sepolia | `BiomapperAgentRegistry` | [`0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2`](https://sepolia.basescan.org/address/0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2) |

## Implementation Table

| Contract | Implemented Interfaces |
|----------|----------------------|
| `BiomapperAgentRegistry` | [`IBiomapperAgentRegistry`], [`IBridgedBiomapperRead`] |

[`IBiomapperAgentRegistry`]: src/interfaces/IBiomapperAgentRegistry.sol
[`IBridgedBiomapperRead`]: src/interfaces/IBridgedBiomapperRead.sol

## Installation

### With Foundry

```shell
forge install techdigger/open-agentlink-contracts
```

Import in your contracts:

```solidity
import {IBiomapperAgentRegistry} from "open-agentlink-contracts/src/interfaces/IBiomapperAgentRegistry.sol";
```

### With npm/yarn

```shell
npm install @agentlink/contracts
```

```solidity
import {IBiomapperAgentRegistry} from "@agentlink/contracts/src/interfaces/IBiomapperAgentRegistry.sol";
```

## Usage

See the [`examples`][examples] directory for integration examples.

[examples]: ./examples

## Bug Bounty

To report a vulnerability, email **security@humanode.io** — please do not open a public issue.

## License

[MIT](./LICENSE)
