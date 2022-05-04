// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./Gallery.sol";

contract Factory {
    using Clones for address;
    using Address for address;

    Gallery galleryCont = new Gallery();

    event NewGallery(
        string tokenName,
        string tokenSymbol,
        string creatorName,
        address contractAddress,
        address creatorAddress
    );

    function newGallery(
        string memory tokenName,
        string memory tokenSymbol,
        string memory creatorName
    ) public {
        address galleryAddr = address(galleryCont).clone();
        galleryAddr.functionDelegateCall(
            abi.encodeWithSelector(
                galleryCont.initialize.selector, 
                tokenName, 
                tokenSymbol, 
                creatorName
            )
        );
    }
}