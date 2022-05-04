// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Gallery.sol";

contract NFTFactory is Ownable {
    using Clones for address;

    Gallery NFT = new Gallery();

    function newNFTContract(
        string memory name,
        string memory symbol
    ) public {

    }
}