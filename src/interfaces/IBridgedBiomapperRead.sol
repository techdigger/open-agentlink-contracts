// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBridgedBiomapperRead {
    function generationsHead() external view returns (uint256 generationPtr);

    function lookupBiomappingPtr(address account, uint256 generationPtr) external view returns (uint256 biomappingPtr);
}
