// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {IBiomapperAgentRegistry} from "./interfaces/IBiomapperAgentRegistry.sol";
import {IBridgedBiomapperRead} from "./interfaces/IBridgedBiomapperRead.sol";

/// @title Biomapper Agent Registry
/// @notice Links EVM agent wallets to owner wallets that are biomapped in the
/// current Biomapper generation.
contract BiomapperAgentRegistry is IBiomapperAgentRegistry, EIP712 {
    error InvalidConfiguration();
    error ZeroAddress();
    error OwnerNotBiomapped();
    error LinkExpired();
    error InvalidAgentSignature();
    error AgentNotLinked();
    error NotAuthorized();

    bytes32 private constant AGENT_LINK_TYPEHASH =
        keccak256("AgentLink(address agent,address owner,uint256 nonce,uint256 deadline)");

    IBridgedBiomapperRead public immutable BRIDGED_BIOMAPPER;

    mapping(address agent => address owner) private _linkedOwners;
    mapping(address agent => uint256 nonce) public agentNonce;

    constructor(address bridgedBiomapper) EIP712("BiomapperAgentRegistry", "1") {
        if (bridgedBiomapper == address(0) || bridgedBiomapper.code.length == 0) {
            revert InvalidConfiguration();
        }

        try IBridgedBiomapperRead(bridgedBiomapper).generationsHead() returns (uint256) {}
        catch {
            revert InvalidConfiguration();
        }

        BRIDGED_BIOMAPPER = IBridgedBiomapperRead(bridgedBiomapper);
    }

    function linkAgent(address agent, uint256 deadline, bytes calldata signature) external {
        if (agent == address(0)) revert ZeroAddress();
        if (block.timestamp > deadline) revert LinkExpired();

        address owner = msg.sender;
        uint256 generationPtr = BRIDGED_BIOMAPPER.generationsHead();
        if (!_isBiomapped(owner, generationPtr)) revert OwnerNotBiomapped();

        uint256 nonce = agentNonce[agent];
        _linkedOwners[agent] = owner;
        agentNonce[agent] = nonce + 1;

        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(AGENT_LINK_TYPEHASH, agent, owner, nonce, deadline)));

        if (!SignatureChecker.isValidSignatureNow(agent, digest, signature)) {
            revert InvalidAgentSignature();
        }

        emit AgentLinked(agent, owner, generationPtr);
    }

    function unlinkAgent(address agent) external {
        address owner = _linkedOwners[agent];
        if (owner == address(0)) revert AgentNotLinked();
        if (msg.sender != owner && msg.sender != agent) revert NotAuthorized();

        delete _linkedOwners[agent];
        agentNonce[agent] += 1;

        emit AgentUnlinked(agent, owner);
    }

    function linkedOwner(address agent) external view returns (address owner) {
        return _linkedOwners[agent];
    }

    function getAgentStatus(address agent) external view returns (address owner, uint256 generationPtr, bool active) {
        owner = _linkedOwners[agent];
        generationPtr = BRIDGED_BIOMAPPER.generationsHead();
        active = owner != address(0) && _isBiomapped(owner, generationPtr);
    }

    function _isBiomapped(address account, uint256 generationPtr) private view returns (bool) {
        if (account == address(0) || generationPtr == 0) return false;
        return BRIDGED_BIOMAPPER.lookupBiomappingPtr(account, generationPtr) != 0;
    }
}
