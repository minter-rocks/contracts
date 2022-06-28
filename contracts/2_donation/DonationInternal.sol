// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./DonationStorage.sol";

abstract contract DonationInternal {
    using DonationStorage for DonationStorage.Layout;
    using DonationStorage for DonationStorage.Donate;

    function _nextTokenId() internal returns(uint256) {
        return DonationStorage.layout().nextTokenId++;
    }

    function _cardPower(uint256 tokenId) internal view returns(uint256) {
        return DonationStorage.layout().donates[tokenId].votingPower;
    }

    function _userTotalDonation(address userAddr) internal view returns(uint256) {
        return DonationStorage.layout().userTotalDonation[userAddr];
    }

    function _increaseUserTotalDonation(address userAddr, uint256 amount) internal {
        DonationStorage.layout().userTotalDonation[userAddr] += amount;
    }

    function _decreaseUserTotalDonation(address userAddr, uint256 amount) internal {
        DonationStorage.layout().userTotalDonation[userAddr] -= amount;
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
        require(
            amount_Matic >= 10 ** 18,
            "DonationInternal: minimum donation is 1 MATIC."
        );
        l.donates[id] = DonationStorage.Donate(
            tag, 
            amount_Matic, 
            amount_USD, 
            _consumePower(amount_Matic),
            blockNumber
        );
        l.userTotalDonation[userAddr] += amount_USD;
    }

    function _consumePower(uint256 paidAmount) internal returns(uint256 powerAmount) {
        powerAmount = paidAmount * DonationStorage.layout().powerNumenator / 1000000;
        DonationStorage.layout().powerNumenator -= DonationStorage.layout().powerNumenator / 100000;
    }

    function _setPowerNumenator(uint256 powerNumenator) internal {
        DonationStorage.layout().powerNumenator = powerNumenator;
    }

    function _setMinDonation(uint256 minDonation) internal {
        DonationStorage.layout().minDonation = minDonation;
    }

    function _newNotification(string memory notification) internal {
        DonationStorage.layout().notification = notification;
    }
}