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
import "./Collection1.sol";

/**
 * @title NFT collection Factory
 * @author Minter.Rocks
 * @notice create your own NFT collection contract and convert your files to NFTs
 * in the simplest way possible.
 */
contract Factory1 {
    using Clones for address;

    mapping(address => address[]) public _userCollections;

    /**
     * @notice the predeployed collection contract abi which the Factory clones.
     */
    Collection1 public implementation = new Collection1();

    event NewCollection(
        string creatorName,
        string tokenName,
        string tokenSymbol,
        address creatorAddress,
        address contractAddress,
        uint96 defaultRoyalty
    );

    /**
     * @notice Create a new NFT collection.
     * @param creatorName enter your name as the creator of the new collection.
     * @param tokenName name of collection tokens.
     * @param tokenSymbol symbol of collection tokens.
     * @param royaltyNumerator the numerator of default token royalties which denumerator.
     * is 10000. if you set a royaltyNumerator, you will earn a fraction of the tokens.
     * price, every time they tranfers in market places.
     * @param royaltyReciever the wallet address that receives the royalty.
     * @dev clones a predeployed collection contract abi with a new address onchain.
     * @dev and initializes the new created collection as the creator desired.
     * @dev emits a NewCollection event.
     */
    function newCollection(
        string memory creatorName,
        string memory tokenName,
        string memory tokenSymbol,
        uint96 royaltyNumerator,
        address royaltyReciever
    ) public {
        address creatorAddr = msg.sender;
        address collectionAddr = address(implementation).cloneDeterministic(
            bytes32(abi.encodePacked(creatorAddr, _userCollections[creatorAddr].length))
        );
        Collection1(collectionAddr).initialize(
            creatorName,
            tokenName, 
            tokenSymbol,
            creatorAddr,
            royaltyNumerator,
            royaltyReciever
        );
        emit NewCollection(
            creatorName, 
            tokenName, 
            tokenSymbol, 
            creatorAddr,
            collectionAddr, 
            royaltyNumerator
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
            names[i] = Collection1(_userCollections[user][i]).name();
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