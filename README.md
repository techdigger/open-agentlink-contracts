<p align="center">
  <img src="https://raw.githubusercontent.com/techdigger/agentlink-landing/master/public/brand/wordmark.svg" alt="AgentLink" height="48" />
</p>

<h1 align="center">AgentLink Contracts</h1>

<h4 align="center">Link AI agent wallets to verified human wallets on-chain.</h4>

<p align="center">
  <strong>
    <a href="https://agentlink.humanode.io">About</a>
    &nbsp;&nbsp;&bull;&nbsp;&nbsp;
    <a href="https://agentlink.humanode.io/docs">Docs</a>
    &nbsp;&nbsp;&bull;&nbsp;&nbsp;
    <a href="https://sepolia.basescan.org/address/0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2">Basescan</a>
    &nbsp;&nbsp;&bull;&nbsp;&nbsp;
    <a href="https://humanode.io">Humanode</a>
  </strong>
</p>

## About

AgentLink is an on-chain registry that links AI agent wallets to human-verified owner wallets via [Humanode](https://humanode.io) biomapping. A link is active only while the owner remains biomapped — no admin keys, no upgrades, no stale state.

Learn more at [agentlink.humanode.io](https://agentlink.humanode.io).

## Deployments

| Network | Contract | Address |
|---------|----------|---------|
| Base Sepolia | `BiomapperAgentRegistry` | [`0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2`](https://sepolia.basescan.org/address/0x16F2a7AC67B6aC1E57dD5528A24b1fC689902Be2) |

## Usage

See the [documentation](https://agentlink.humanode.io/docs) for integration guides and examples.

Install via Forge:

```shell
forge install techdigger/open-agentlink-contracts
```

```solidity
import {IBiomapperAgentRegistry} from "open-agentlink-contracts/src/interfaces/IBiomapperAgentRegistry.sol";
```

## Development

### Requirements

- [Foundry](https://getfoundry.sh)
- [Node.js](https://nodejs.org) + [pnpm](https://pnpm.io)

### Building and testing

```shell
forge soldeer install
forge build --sizes
forge test -vvv
```

### Contribution

1. Fork the repository, clone your fork, create a branch for your changes.
2. Write your code and tests, commit the changes.
3. Create a pull request.

## Security

To report a vulnerability, email **security@humanode.io** — please do not open a public issue.

## License

[MIT](./LICENSE)
