// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IDCardInterface {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function username(uint256 _userId) external view returns (string memory _username);
}