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

    function offerToken(uint256 tokenId, uint256 minSalePriceInWei, bool isForSale) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "BTBMarket : you do not have access to this token");
        tokensOfferedForSale[tokenId] = Offer(isForSale, tokenId, ownerOF(tokenId), minSalePriceInWei);
        if(isForSale) {
            emit ForSale(tokenId, minSalePriceInWei);
        } else {
            emit noLongerForSale(tokenId);
        }
    }

    function buyToken(uint256 tokenId) public payable {
        Offer memory offer = tokensOfferedForSale[tokenId];
        require(offer.isForSale, "token is not for sale");
        require(msg.value >= offer.minValue, "Insufficient amount to pay");

        address seller = offer.seller;
        _safeTransfer(seller, _msgSender(), tokenId, "");
        pendingWithdrawals[seller] += msg.value;
        emit bought(tokenId, msg.value, seller, _msgSender());
    }

    function withdraw() public {
        uint256 amount = pendingWithdrawals[_msgSender()];
        pendingWithdrawals[_msgSender()] = 0;
        payable(msg.sender).transfer(amount);
    }
}