# AgentLink Contracts

[![Tests](https://github.com/techdigger/open-agentlink-contracts/actions/workflows/ci.yml/badge.svg)](https://github.com/techdigger/open-agentlink-contracts/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

On-chain registry linking AI agent wallets to biomapped human wallets on Base.

## Deployments

| Network | Contract | Address |
|---------|----------|---------|
| Base | `BiomapperAgentRegistry` | [`0x31e98F489ad65dF5Ee43CBe06e4f35557Cd0abb2`](https://basescan.org/address/0x31e98F489ad65dF5Ee43CBe06e4f35557Cd0abb2) |
| Base Sepolia | `BiomapperAgentRegistry` | [`0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2`](https://sepolia.basescan.org/address/0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2) |

## Bug Bounty

This repository is subject to the AgentLink bug bounty program. To report a vulnerability, email **security@humanode.io** — please do not open a public issue.

## Using the Interface

Install via Forge:

```bash
forge install techdigger/open-agentlink-contracts
```

Import in your contracts:

```solidity
import {IBiomapperAgentRegistry} from "open-agentlink-contracts/src/interfaces/IBiomapperAgentRegistry.sol";

contract MyContract {
    IBiomapperAgentRegistry registry;

    function isAgentActive(address agent) external view returns (bool) {
        (,, bool active) = registry.getAgentStatus(agent);
        return active;
    }
}
```

## Development

```bash
forge soldeer install
forge build --sizes
forge test -vvv
```

## License

[MIT](./LICENSE)
