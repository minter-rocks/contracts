// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";

abstract contract PriceFeed {

    //aggregator on Polygon Mainnet
    AggregatorInterface constant AGGREGATOR_MATIC_USD_8 = AggregatorInterface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);

    function _MATIC_USD_8() internal view returns(uint256) {
        return uint256(AGGREGATOR_MATIC_USD_8.latestAnswer());
    }

    function _IN_USD_18(uint256 _MATIC_AMOUNT_18) internal view returns(uint256) {
        return _MATIC_AMOUNT_18 * _MATIC_USD_8() / 10 ** 8;
    }
}