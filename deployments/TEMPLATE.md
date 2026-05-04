# Deployment: <profile-id>

- profile: `<profile-id>`
- status: `draft | deployed | verified | deprecated`
- chain id: `<number>`
- caip-2: `eip155:<number>`
- registry: `<0x... | not deployed>`
- bridged biomapper: `<0x...>`
- deployment block: `<number | not deployed>`
- deploy commit: `<sha | unknown>`
- deployer: `<address | unknown>`
- date: `<YYYY-MM-DD | unknown>`
- abi version: `1`
- verification status: `unverified | verified | not deployed`
- explorer: `<url | not deployed>`
- profile manifest status: `<pending | synced>`

## Notes

- Record the exact deployed registry address, not the Bridged Biomapper address.
- Record deployment block for event indexers and management UI.
- Use `not deployed` instead of placeholders for missing production deployments.
- Update profile metadata only after this record is reviewed.
