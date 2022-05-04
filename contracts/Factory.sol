// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./Gallery.sol";

contract Factory {
    using Clones for address;
    using Address for address;

    Gallery NFT = new Gallery();

    function newGallery(
        string memory contractName,
        string memory contractSymbol,
        string memory creatorName
    ) public {
        address galleryAddr = address(NFT).clone();
        galleryAddr.functionDelegateCall(
            abi.encodeWithSelector(
                NFT.initialize.selector, 
                contractName, 
                contractSymbol, 
                creatorName
            )
        );
    }
}