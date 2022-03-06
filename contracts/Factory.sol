// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract Factory is Ownable {
    using Clones for address;

    function newNFTContract(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) public {
        
    }
}