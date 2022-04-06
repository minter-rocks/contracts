// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BanTheBanNFT.sol";

contract BTBMarket is BanTheBanNFT {

    event ForSale(uint256 tokenId, uint256 minValue);
    event noLongerForSale(uint256 tokenId);
    event bought(uint256 tokenId, uint256 value, address from, address to);
}