// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./NFTContract.sol";

contract NFTFactory {
    using Clones for address;

    NFTContract public NFTLib = new NFTContract();

    event NewNFTContract(
        string NFTName,
        string NFTSymbol,
        string baseURI,
        address contAddr,
        address contOwner
    );

    function newNFTContract(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) public {
        address contAddr = address(NFTLib).clone();
        NFTContract(contAddr).initialize(name, symbol, baseURI);
        emit NewNFTContract(name, symbol, baseURI, contAddr, msg.sender);
    }
}