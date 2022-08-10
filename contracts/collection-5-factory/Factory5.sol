// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 *             .----------------. 
 *            | .--------------. |
 *            | |  _______     | |
 *            | | |_   __ \    | |
 *            | |   | |__) |   | |
 *            | |   |  __ /    | |
 *            | |  _| |  \ \_  | |
 *            | | |____| |___| | |
 *            | |              | |
 *            | '--------------' |
 *            '-- MINTER.ROCKS --' 
 */

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Collection5.sol";

contract Factory5 {
    using Clones for address;

    mapping(address => address[]) public _userCollections;

    /**
     * @notice the predeployed collection contract abi which the Factory clones.
     */
    Collection5 public collectionBase = new Collection5();

    event NewCollection(
        string collectionInfo,
        string tokenName,
        string tokenSymbol,
        address creatorAddress,
        address contractAddress
    );

    function newCollection(
        string memory collectionInfo,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        address creatorAddr = msg.sender;
        address collectionAddr = address(collectionBase).cloneDeterministic(
            bytes32(abi.encodePacked(creatorAddr, _userCollections[creatorAddr].length))
        );
        _userCollections[creatorAddr].push(collectionAddr);
        Collection5(collectionAddr).initialize(
            collectionInfo,
            tokenName, 
            tokenSymbol,
            creatorAddr
        );
        emit NewCollection(
            collectionInfo,
            tokenName,
            tokenSymbol,
            creatorAddr,
            collectionAddr
        );
    }

    function userCollections(address user) public view returns(address[] memory addre) {

    }

    function nextCollectionAddr(
        address creatorAddr
    ) public view returns(address) {
        return address(collectionBase).predictDeterministicAddress(
            bytes32(abi.encodePacked(creatorAddr, _userCollections[creatorAddr].length)), 
            address(this)
        );
    }
}