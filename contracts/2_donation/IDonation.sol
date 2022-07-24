// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IDonation {

    function userPower(address userAddr) external view returns(uint256);
}