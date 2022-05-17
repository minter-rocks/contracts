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
 * @title NFT Collection Factory
 * @author Minter.Rocks
 * @notice create your own NFT Collection contract and convert your files to NFTs
 * in the simplest way possible.
 */
contract Factory1 {
    using Clones for address;

    /**
     * @notice the predeployed Collection contract abi which the Factory clones.
     */
    Collection public CollectionCont = new Collection();

    event NewCollection(
        string creatorName,
        string tokenName,
        string tokenSymbol,
        address creatorAddress,
        address contractAddress,
        uint96 defaultRoyalty
    );

    /**
     * @notice Create a new NFT Collection.
     * @param creatorName enter your name as the creator of the new Collection.
     * @param tokenName name of Collection tokens.
     * @param tokenSymbol symbol of Collection tokens.
     * @param royaltyNumerator the numerator of default token royalties which denumerator.
     * is 10000. if you set a royaltyNumerator, you will earn a fraction of the tokens.
     * price, every time they tranfers in market places.
     * @param royaltyReciever the wallet address that receives the royalty.
     * @dev clones a predeployed Collection contract abi with a new address onchain.
     * @dev and initializes the new created Collection as the creator desired.
     * @dev emits a NewCollection event.
     */
    function newCollection(
        string memory creatorName,
        string memory tokenName,
        string memory tokenSymbol,
        uint96 royaltyNumerator,
        address royaltyReciever
    ) public {
        address CollectionAddr = address(CollectionCont).clone();
        Collection(CollectionAddr).initialize(
            creatorName,
            tokenName, 
            tokenSymbol,
            msg.sender,
            royaltyNumerator,
            royaltyReciever
        );
        emit NewCollection(
            creatorName, 
            tokenName, 
            tokenSymbol, 
            msg.sender,
            CollectionAddr, 
            royaltyNumerator
        );
    }
}