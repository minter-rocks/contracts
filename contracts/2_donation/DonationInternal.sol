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

    function _userPower(address userAddr) internal view returns(uint256) {
        return DonationStorage.layout().userPower[userAddr];
    }

    function _increaseUserPower(address userAddr, uint256 amount) internal {
        DonationStorage.layout().userPower[userAddr] += amount;
    }

    function _decreaseUserPower(address userAddr, uint256 amount) internal {
        DonationStorage.layout().userPower[userAddr] -= amount;
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
            amount_Matic >= l.minDonation,
            "DonationInternal: minimum donation error."
        );

        uint256 power = _consumePower(amount_Matic);

        l.donates[id] = DonationStorage.Donate(
            tag, 
            amount_Matic, 
            amount_USD, 
            power,
            blockNumber
        );
        l.userPower[userAddr] += power;
    }

    function _consumePower(uint256 paidAmount) internal returns(uint256 powerAmount) {
        powerAmount = paidAmount / (10 ** 8) * DonationStorage.layout().powerNumenator;
        DonationStorage.layout().powerNumenator -= DonationStorage.layout().powerNumenator / 300;
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