// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "@openzeppelin-contracts-5.0.2/utils/cryptography/ECDSA.sol";

contract MockERC1271Wallet {
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    address public immutable signer;

    constructor(address _signer) {
        signer = _signer;
    }

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4) {
        address recovered = ECDSA.recover(hash, signature);
        return recovered == signer ? MAGICVALUE : bytes4(0xffffffff);
    }
}
