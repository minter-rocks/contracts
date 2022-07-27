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

    /**
     * @notice the predeployed collection contract abi which the Factory clones.
     */
    Collection5 public collectionCont = new Collection5();

    event NewCollection(address contractAddress);

    function newCollection() public {
        address collectionAddr = address(collectionCont).clone();
        Collection5(collectionAddr).initialize();
        emit NewCollection(collectionAddr);
    }
}