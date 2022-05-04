// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Gallery.sol";

contract Factory {
    using Clones for address;

    Gallery NFT = new Gallery();

    function newGallery(
        string memory name,
        string memory symbol
    ) public {

    }
}