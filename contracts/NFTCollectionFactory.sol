// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./NFTCollection.sol";

contract NFTFactory {

    function version() public pure returns(string memory V_) {
        V_ = "0.1";
    }

    using Clones for address;

    NFTCollection public NFTLib = new NFTCollection();

    event NewNFTCollection(
        address collectionAddr,
        address collectionOwner,
        string name,
        string symbol
    );

    function newNFTCollection(
        string memory name,
        string memory symbol
    ) public {
        address collectionAddr = address(NFTLib).clone();
        NFTCollection(collectionAddr).initialize(name, symbol);
        emit NewNFTCollection(collectionAddr, msg.sender, name, symbol);
    }
}