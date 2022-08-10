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
    Collection5 public implementation = new Collection5();

    event NewCollection(
        string collectionInfo,
        string collectionName,
        string collectionSymbol,
        address creatorAddress,
        address contractAddress
    );

    function newCollection(
        string memory collectionInfo,
        string memory collectionName,
        string memory collectionSymbol,
        uint96 royaltyNumerator,
        address royaltyReciever
    ) public {
        address creatorAddr = msg.sender;
        address collectionAddr = address(implementation).cloneDeterministic(
            bytes32(abi.encodePacked(creatorAddr, _userCollections[creatorAddr].length))
        );
        _userCollections[creatorAddr].push(collectionAddr);
        Collection5(collectionAddr).initialize(
            collectionInfo,
            collectionName, 
            collectionSymbol,
            creatorAddr,
            royaltyNumerator,
            royaltyReciever
        );
        emit NewCollection(
            collectionInfo,
            collectionName,
            collectionSymbol,
            creatorAddr,
            collectionAddr
        );
    }

    function userCollections(address user) public view returns(
        address[] memory addrs,
        string[] memory names
    ) {
        uint256 len = _userCollections[user].length;
        
        addrs = new address[](len);
        names = new string[](len);

        for(uint16 i; i < len; i++) {
            addrs[i] = _userCollections[user][i];
            names[i] = Collection5(_userCollections[user][i]).name();
        }
    }

    function nextCollectionAddr(
        address creatorAddr
    ) public view returns(address) {
        return address(implementation).predictDeterministicAddress(
            bytes32(abi.encodePacked(creatorAddr, _userCollections[creatorAddr].length)), 
            address(this)
        );
    }
}