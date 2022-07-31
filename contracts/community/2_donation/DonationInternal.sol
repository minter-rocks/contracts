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

    function _totalPower() internal view returns(uint256) {
        return DonationStorage.layout().totalPower;
    }

    function _increaseUserPower(address userAddr, uint256 amount) internal {
        DonationStorage.Layout storage l = DonationStorage.layout();
        l.userPower[userAddr] += amount;
        l.totalPower += amount;
    }

    function _decreaseUserPower(address userAddr, uint256 amount) internal {
        DonationStorage.Layout storage l = DonationStorage.layout();
        l.userPower[userAddr] -= amount;
        l.totalPower -= amount;
    }

    function _newDonation(
        address userAddr,
        uint256 id,
        string calldata notion,
        uint256 amount_Matic,
        uint256 amount_USD,
        uint256 blockNumber
    ) internal {
        DonationStorage.Layout storage l = DonationStorage.layout();
        require(
            amount_Matic >= l.minDonation,
            "DonationInternal: minimum donation error."
        );

        bytes memory bytsTag = bytes(notion);
        uint256 notionLen = bytsTag.length;

        string memory notion1;
        string memory notion2;

        if(notionLen > 33){
            uint256 endLine = 34;
            while(endLine > 0) {
                if(bytsTag[endLine] == 0x20){
                    endLine ++;
                    break;
                }
                endLine--;
            }
            endLine = endLine != 0 ? endLine : 33;
            require(notionLen - endLine <= 33, "DonationInternal: notion string overflow");
            notion1 = notion[:endLine];
            notion2 = notion[endLine:notionLen];
        } else {
            notion1 = notion;
        }

        uint256 power = _consumePower(amount_Matic);

        l.donates[id] = DonationStorage.Donate(
            notion1,
            notion2,
            amount_Matic, 
            amount_USD, 
            power,
            blockNumber,
            0
        );
        _increaseUserPower(userAddr, power);
        l.totalDonation += amount_Matic;
    }

    function _increaseNonce(uint256 tokenId) internal {
        DonationStorage.layout().donates[tokenId].nonce ++;
    }

    function _consumePower(uint256 paidAmount) internal returns(uint256 powerAmount) {
        DonationStorage.Layout storage d = DonationStorage.layout();
        powerAmount = paidAmount / (10 ** 10) * d.powerNumenator;
        d.powerNumenator -= d.powerNumenator / 666;
    }

    function _setPowerNumenator(uint256 powerNumenator) internal {
        DonationStorage.layout().powerNumenator = powerNumenator;
    }

    function _setMinDonation(uint256 minDonation) internal {
        DonationStorage.layout().minDonation = minDonation;
    }

    function _setNotification(
        string memory notification1,
        string memory notification2
    ) internal {
        DonationStorage.layout().notification1 = notification1;
        DonationStorage.layout().notification2 = notification2;
    }

}