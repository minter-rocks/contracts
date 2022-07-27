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
import "./Collection2.sol";

/**
 * @title NFT collection Factory
 * @author Minter.Rocks
 * @notice create your own NFT collection contract and convert your files to NFTs
 * in the simplest way possible.
 */
contract Factory {
    using Clones for address;

    /**
     * @notice the predeployed collection contract abi which the Factory clones.
     */
    Collection2 public CollectionCont = new Collection2();

    event NewCollection(
        string creatorName,
        string tokenName,
        string tokenSymbol,
        string baseURI,
        uint256 maxSupply,
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
        string memory baseURI,
        uint256 maxSupply,
        uint96 royaltyNumerator,
        address royaltyReciever
    ) public {
        address collectionAddr = address(CollectionCont).clone();
        Collection2(collectionAddr).initialize(
            creatorName,
            tokenName, 
            tokenSymbol,
            baseURI,
            maxSupply,
            msg.sender,
            royaltyNumerator,
            royaltyReciever
        );
        emit NewCollection(
            creatorName, 
            tokenName, 
            tokenSymbol,
            baseURI,
            maxSupply,
            msg.sender,
            collectionAddr, 
            royaltyNumerator
        );
    }
}