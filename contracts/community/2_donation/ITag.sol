// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITag {

    function userPower(address userAddr) external view returns(uint256);

    function totalPower() external view returns(uint256);
}