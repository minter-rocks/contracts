// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BanTheBanNFT.sol";

contract BTBMarket is BanTheBanNFT {

    struct Offer {
        bool isForSale;
        uint256 tokenId;
        address seller;
        uint256 minValue;
    }

    mapping (uint256 => Offer) public tokensOfferedForSale;
    mapping (address => uint256) public pendingWithdrawals;

    event ForSale(uint256 tokenId, uint256 minValue);
    event noLongerForSale(uint256 tokenId);
    event bought(uint256 tokenId, uint256 value, address from, address to);

    function offerToken(uint256 tokenId, uint256 minSalePriceInWei, bool isForSale) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "BTBMarket : you do not have access to this token");
        tokensOfferedForSale[tokenId] = Offer(isForSale, tokenId, ownerOf(tokenId), minSalePriceInWei);
        if(isForSale) {
            emit ForSale(tokenId, minSalePriceInWei);
        } else {
            emit noLongerForSale(tokenId);
        }
    }

    function buyToken(uint256 tokenId) public payable {
        Offer memory offer = tokensOfferedForSale[tokenId];
        uint256 availableAmount = msg.value;
        require(offer.isForSale, "token is not for sale");
        require(availableAmount >= offer.minValue, "Insufficient amount to pay");

        //pay royalty
        (address royaltyReceiver, uint256 royaltyAmount) = royaltyInfo(tokenId, availableAmount);
        if (royaltyAmount > 0) {availableAmount -= royaltyAmount;}
        pendingWithdrawals[royaltyReceiver] += availableAmount;

        //pay main value
        address seller = offer.seller;
        _safeTransfer(seller, _msgSender(), tokenId, "");
        pendingWithdrawals[seller] += availableAmount;
        emit bought(tokenId, msg.value, seller, _msgSender());
    }

    function withdraw() public {
        uint256 amount = pendingWithdrawals[_msgSender()];
        pendingWithdrawals[_msgSender()] = 0;
        payable(msg.sender).transfer(amount);
    }
}