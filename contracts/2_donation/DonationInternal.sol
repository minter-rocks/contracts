// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./DonationStorage.sol";

abstract contract DonationInternal {
    using DonationStorage for DonationStorage.Layout;
    using DonationStorage for DonationStorage.Donate;

    function _nextTokenId() internal returns(uint256) {
        return DonationStorage.layout().nextTokenId++;
    }

    function _userTotalDonation(address userAddr) internal view returns(uint256) {
        return DonationStorage.layout().userTotalDonation[userAddr];
    }

    function _newDonation(
        address userAddr,
        uint256 id,
        string memory tag,
        uint256 amount_Matic,
        uint256 amount_USD,
        uint256 blockNumber
    ) internal {
        DonationStorage.Layout storage l = DonationStorage.layout();

        l.donates[id] = DonationStorage.Donate(
            tag, 
            amount_Matic, 
            amount_USD, 
            consumePower(amount_Matic),
            blockNumber
        );
        l.userTotalDonation[userAddr] += amount_USD;
    }

    function consumePower(uint256 paidAmount) internal returns(uint256) {
        return paidAmount * DonationStorage.layout().powerNumenator-- / 10000;
    }

    function _setPowerNumenator(uint256 powerNumenator) internal {
        DonationStorage.layout().powerNumenator = powerNumenator;
    }

    function _newNotification(string memory notification) internal {
        DonationStorage.layout().notification = notification;
    }
}