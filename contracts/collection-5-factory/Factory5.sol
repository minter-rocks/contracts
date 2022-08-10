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
        string memory tokenSymbol,
        uint96 royaltyNumerator,
        address royaltyReciever
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
            creatorAddr,
            royaltyNumerator,
            royaltyReciever
        );
        emit NewCollection(
            collectionInfo,
            tokenName,
            tokenSymbol,
            creatorAddr,
            collectionAddr
        );
    }

    function userCollections(address user) public view returns(
        address[] memory addrs,
        string[] memory infos
    ) {
        uint256 len = _userCollections[user].length;
        
        addrs = new address[](len);
        infos = new string[](len);

        for(uint16 i; i < len; i++) {
            addrs[i] = _userCollections[user][i];
            infos[i] = Collection5(_userCollections[user][i]).collectionInfo();
        }
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