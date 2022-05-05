// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./Gallery.sol";

contract Factory {
    using Clones for address;
    using Address for address;

    Gallery public galleryCont = new Gallery();

    event NewGallery(
        string creatorName,
        string tokenName,
        string tokenSymbol,
        address creatorAddress,
        address contractAddress,
        uint96 defaultRoyalty
    );

    function newGallery(
        string memory creatorName,
        string memory tokenName,
        string memory tokenSymbol,
        uint96 royaltyNumerator,
        address royaltyReciever
    ) public {
        address galleryAddr = address(galleryCont).clone();
        galleryAddr.functionDelegateCall(
            abi.encodeWithSelector(
                galleryCont.initialize.selector, 
                creatorName,
                tokenName, 
                tokenSymbol, 
                royaltyNumerator,
                royaltyReciever
            )
        );
        emit NewGallery(
            creatorName, 
            tokenName, 
            tokenSymbol, 
            msg.sender,
            galleryAddr, 
            royaltyNumerator
        );
    }
}