// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBiomapperAgentRegistry {
    event AgentLinked(address indexed agent, address indexed owner, uint256 indexed generationPtr);
    event AgentUnlinked(address indexed agent, address indexed owner);

    function linkAgent(address agent, uint256 deadline, bytes calldata signature) external;

    function unlinkAgent(address agent) external;

    function linkedOwner(address agent) external view returns (address owner);

    function agentNonce(address agent) external view returns (uint256 nonce);

    function getAgentStatus(address agent) external view returns (address owner, uint256 generationPtr, bool active);
}
