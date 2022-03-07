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
        string NFTName,
        string NFTSymbol,
        string baseURI,
        address contAddr,
        address contOwner
    );

    function newNFTCollection(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) public {
        address contAddr = address(NFTLib).clone();
        NFTCollection(contAddr).initialize(name, symbol, baseURI);
        emit NewNFTCollection(name, symbol, baseURI, contAddr, msg.sender);
    }
}