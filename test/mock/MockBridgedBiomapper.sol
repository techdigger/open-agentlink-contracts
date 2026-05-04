// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IBridgedBiomapperRead} from "../../src/interfaces/IBridgedBiomapperRead.sol";

contract MockBridgedBiomapper is IBridgedBiomapperRead {
    uint256 public generationsHead;
    mapping(address => mapping(uint256 => uint256)) private _biomappingPtrs;

    function setGenerationHead(uint256 generationPtr) external {
        generationsHead = generationPtr;
    }

    function setBiomappingPtr(address account, uint256 generationPtr, uint256 biomappingPtr) external {
        _biomappingPtrs[account][generationPtr] = biomappingPtr;
    }

    function lookupBiomappingPtr(address account, uint256 generationPtr) external view returns (uint256 biomappingPtr) {
        return _biomappingPtrs[account][generationPtr];
    }
}
