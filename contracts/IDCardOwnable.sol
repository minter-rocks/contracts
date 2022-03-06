// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IDCardInterface.sol";

contract IDCardOwnable {
    // IDCard Contract address on rinkeby
    IDCardInterface immutable IDCard = IDCardInterface(0x3Cd233baBa7c4B24745215E9eDE95F6761A0CDa8);

    uint256 private _ownerID;

    constructor(uint256 ownerID_) {
        _ownerID = ownerID_;
    }

    function owner() public view virtual returns (string memory) {
        return IDCard.username(_ownerID);
    }

    modifier onlyOwner() {
        require(msg.sender == IDCard.ownerOf(_ownerID), "IDCardOwnable: caller is not the owner");
        _;
    }
}