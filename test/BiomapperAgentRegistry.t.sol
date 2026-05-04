// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {BiomapperAgentRegistry} from "../src/BiomapperAgentRegistry.sol";
import {MockBridgedBiomapper} from "./mock/MockBridgedBiomapper.sol";
import {MockERC1271Wallet} from "./mock/MockERC1271Wallet.sol";

contract BiomapperAgentRegistryTest is Test {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 internal constant AGENT_LINK_TYPEHASH =
        keccak256("AgentLink(address agent,address owner,uint256 nonce,uint256 deadline)");

    uint256 internal constant OWNER_1_PK = 0xA11CE;
    uint256 internal constant OWNER_2_PK = 0xB0B;
    uint256 internal constant AGENT_1_PK = 0xC0DE;
    uint256 internal constant AGENT_SIGNER_PK = 0xD00D;

    MockBridgedBiomapper public biomapper;
    BiomapperAgentRegistry public registry;
    MockERC1271Wallet public smartAgent;

    address internal owner1;
    address internal owner2;
    address internal agent1;
    address internal smartAgentSigner;

    function setUp() public {
        biomapper = new MockBridgedBiomapper();
        registry = new BiomapperAgentRegistry(address(biomapper));

        owner1 = vm.addr(OWNER_1_PK);
        owner2 = vm.addr(OWNER_2_PK);
        agent1 = vm.addr(AGENT_1_PK);
        smartAgentSigner = vm.addr(AGENT_SIGNER_PK);
        smartAgent = new MockERC1271Wallet(smartAgentSigner);

        biomapper.setGenerationHead(100);
        biomapper.setBiomappingPtr(owner1, 100, 1234);
    }

    function testConstructorRejectsZeroBiomapper() public {
        vm.expectRevert(BiomapperAgentRegistry.InvalidConfiguration.selector);
        new BiomapperAgentRegistry(address(0));
    }

    function testConstructorRejectsContractWithoutBiomapperInterface() public {
        vm.expectRevert(BiomapperAgentRegistry.InvalidConfiguration.selector);
        new BiomapperAgentRegistry(address(smartAgent));
    }

    function testEOAAgentCanBeLinked() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);

        (address owner, uint256 generationPtr, bool active) = registry.getAgentStatus(agent1);
        assertEq(owner, owner1);
        assertEq(generationPtr, 100);
        assertTrue(active);
        assertEq(registry.agentNonce(agent1), 1);
    }

    function testERC1271AgentCanBeLinked() public {
        bytes memory signature =
            signAuthorization(AGENT_SIGNER_PK, address(smartAgent), owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(address(smartAgent), block.timestamp + 1 hours, signature);

        (address owner,, bool active) = registry.getAgentStatus(address(smartAgent));
        assertEq(owner, owner1);
        assertTrue(active);
    }

    function testRejectsOwnerThatIsNotBiomapped() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner2, 0, block.timestamp + 1 hours);

        vm.prank(owner2);
        vm.expectRevert(BiomapperAgentRegistry.OwnerNotBiomapped.selector);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);
    }

    function testRejectsZeroAgentAddress() public {
        vm.prank(owner1);
        vm.expectRevert(BiomapperAgentRegistry.ZeroAddress.selector);
        registry.linkAgent(address(0), block.timestamp + 1 hours, hex"");
    }

    function testRejectsExpiredLink() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp - 1);

        vm.prank(owner1);
        vm.expectRevert(BiomapperAgentRegistry.LinkExpired.selector);
        registry.linkAgent(agent1, block.timestamp - 1, signature);
    }

    function testRejectsWrongOwnerSignature() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner2, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        vm.expectRevert(BiomapperAgentRegistry.InvalidAgentSignature.selector);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);
    }

    function testRejectsWrongNonceSignature() public {
        bytes memory firstSignature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, firstSignature);

        vm.prank(owner1);
        vm.expectRevert(BiomapperAgentRegistry.InvalidAgentSignature.selector);
        registry.linkAgent(agent1, block.timestamp + 1 hours, firstSignature);
    }

    function testRejectsWrongDomainSignature() public {
        bytes memory signature =
            signAuthorizationForRegistry(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours, address(0xBEEF));

        vm.prank(owner1);
        vm.expectRevert(BiomapperAgentRegistry.InvalidAgentSignature.selector);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);
    }

    function testOwnerCanUnlinkAgent() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);

        vm.prank(owner1);
        registry.unlinkAgent(agent1);

        (address owner,, bool active) = registry.getAgentStatus(agent1);
        assertEq(owner, address(0));
        assertFalse(active);
        assertEq(registry.agentNonce(agent1), 2);
    }

    function testAgentCanUnlinkItself() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);

        vm.prank(agent1);
        registry.unlinkAgent(agent1);

        (address owner,, bool active) = registry.getAgentStatus(agent1);
        assertEq(owner, address(0));
        assertFalse(active);
    }

    function testRejectsUnlinkWhenAgentIsNotLinked() public {
        vm.expectRevert(BiomapperAgentRegistry.AgentNotLinked.selector);
        registry.unlinkAgent(agent1);
    }

    function testRejectsUnauthorizedUnlink() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);

        vm.prank(owner2);
        vm.expectRevert(BiomapperAgentRegistry.NotAuthorized.selector);
        registry.unlinkAgent(agent1);
    }

    function testAgentCanRelinkToNewOwnerWithFreshConsent() public {
        bytes memory firstSignature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, firstSignature);

        biomapper.setBiomappingPtr(owner2, 100, 5678);

        bytes memory secondSignature = signAuthorization(AGENT_1_PK, agent1, owner2, 1, block.timestamp + 1 hours);

        vm.prank(owner2);
        registry.linkAgent(agent1, block.timestamp + 1 hours, secondSignature);

        (address owner, uint256 generationPtr, bool active) = registry.getAgentStatus(agent1);
        assertEq(owner, owner2);
        assertEq(generationPtr, 100);
        assertTrue(active);
        assertEq(registry.linkedOwner(agent1), owner2);
        assertEq(registry.agentNonce(agent1), 2);
    }

    function testGenerationRolloverDisablesAndReenablesLinks() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);

        biomapper.setGenerationHead(200);

        (, uint256 generationPtrAfterRollover, bool activeAfterRollover) = registry.getAgentStatus(agent1);
        assertEq(generationPtrAfterRollover, 200);
        assertFalse(activeAfterRollover);

        biomapper.setBiomappingPtr(owner1, 200, 5678);

        (, uint256 generationPtrAfterRebiomap, bool activeAfterRebiomap) = registry.getAgentStatus(agent1);
        assertEq(generationPtrAfterRebiomap, 200);
        assertTrue(activeAfterRebiomap);
    }

    function testOwnerWalletSwitchLeavesOldLinkInactive() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);

        biomapper.setGenerationHead(300);
        biomapper.setBiomappingPtr(owner2, 300, 9999);

        (address owner, uint256 generationPtr, bool active) = registry.getAgentStatus(agent1);
        assertEq(owner, owner1);
        assertEq(generationPtr, 300);
        assertFalse(active);
    }

    function testLinkedOwnerPersistsWhenCurrentGenerationIsInactive() public {
        bytes memory signature = signAuthorization(AGENT_1_PK, agent1, owner1, 0, block.timestamp + 1 hours);

        vm.prank(owner1);
        registry.linkAgent(agent1, block.timestamp + 1 hours, signature);

        biomapper.setGenerationHead(200);

        assertEq(registry.linkedOwner(agent1), owner1);

        (address owner, uint256 generationPtr, bool active) = registry.getAgentStatus(agent1);
        assertEq(owner, owner1);
        assertEq(generationPtr, 200);
        assertFalse(active);
    }

    function signAuthorization(uint256 signerPk, address agent, address owner, uint256 nonce, uint256 deadline)
        internal
        view
        returns (bytes memory)
    {
        return signAuthorizationForRegistry(signerPk, agent, owner, nonce, deadline, address(registry));
    }

    function signAuthorizationForRegistry(
        uint256 signerPk,
        address agent,
        address owner,
        uint256 nonce,
        uint256 deadline,
        address verifyingContract
    ) internal view returns (bytes memory) {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes("BiomapperAgentRegistry")),
                keccak256(bytes("1")),
                block.chainid,
                verifyingContract
            )
        );

        bytes32 structHash = keccak256(abi.encode(AGENT_LINK_TYPEHASH, agent, owner, nonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        return abi.encodePacked(r, s, v);
    }
}
