// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BanTheBanNFT.sol";

contract BTBMarket is BanTheBanNFT {

    struct Offer {
        bool isForSale;
        uint256 tokenId;
        address seller;
        uint256 minValue;          // in ether
    }

    mapping (uint256 => Offer) public tokensOfferedForSale;
    mapping (address => uint256) public pendingWithdrawals;

    event ForSale(uint256 tokenId, uint256 minValue);
    event noLongerForSale(uint256 tokenId);
    event bought(uint256 tokenId, uint256 value, address from, address to);
}