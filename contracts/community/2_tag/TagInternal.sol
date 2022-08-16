// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./TagStorage.sol";
import "./utils/UTF8HoldingSpace.sol";

abstract contract TagInternal {
    using TagStorage for TagStorage.Layout;
    using TagStorage for TagStorage.Tag;
    using UTF8HoldingSpace for string;

    function _nextTokenId() internal returns(uint256) {
        return TagStorage.layout().nextTokenId++;
    }

    function _cardPower(uint256 tokenId) internal view returns(uint256) {
        return TagStorage.layout().tags[tokenId].votingPower;
    }

    function _userPower(address userAddr) internal view returns(uint256) {
        return TagStorage.layout().userPower[userAddr];
    }

    function _totalPower() internal view returns(uint256) {
        return TagStorage.layout().totalPower;
    }

    function _increaseUserPower(address userAddr, uint256 amount) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        l.userPower[userAddr] += amount;
        l.totalPower += amount;
    }

    function _decreaseUserPower(address userAddr, uint256 amount) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        l.userPower[userAddr] -= amount;
        l.totalPower -= amount;
    }

    function _newTag(
        address userAddr,
        uint256 id,
        string calldata notion,
        uint256 value,
        uint256 blockNumber
    ) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        TagStorage.Tag storage t = l.tags[id];
        
        require(
            notion.holdingSpace() <= 66,
            "TagInternal: notion string overflow."
        );

        require(
            value >= l.minValue,
            "TagInternal: minimum value error."
        );

        uint256 power = _consumePower(value);

        (
            t.notion,
            t.value,
            t.votingPower,
            t.blockNumber
        ) = (
            notion,
            value, 
            power,
            blockNumber
        );
        _increaseUserPower(userAddr, power);
        l.totalValue += value;

        require(
            t.value <= l.nextTokenId * 10 ** 18,
            "TagInternal: maximum value error."
        );
    }

    function _withdrawTag(uint256 tokenId, address receiver) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        TagStorage.Tag storage t = l.tags[tokenId];

        uint256 amount = t.value * 80 / 100;
        l.userPower[receiver] -= t.votingPower;
        l.totalPower -= t.votingPower;
        l.totalValue -= t.value;

        delete l.tags[tokenId].value;
        delete l.tags[tokenId].votingPower;

        payable(receiver).transfer(amount);
    }

    function _levelup(
        uint256 id,
        address tokenOwner,
        uint256 value,
        string memory mention
    ) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        require(
            value >= l.minLevelup,
            "TagInternal: minimum value error."
        );

        uint256 power = _consumePower(value) / 5;

        l.tags[id].value += value;
        l.tags[id].votingPower += power;
        l.tags[id].donates[l.tags[id].donatesCount++] =
            TagStorage.Donate(msg.sender, value, mention);

        _increaseUserPower(tokenOwner, power);
        l.totalValue += value;
    }

    function _consumePower(uint256 paidAmount) internal returns(uint256 powerAmount) {
        TagStorage.Layout storage d = TagStorage.layout();
        powerAmount = paidAmount / (10 ** 10) * d.powerNumerator;
        d.powerNumerator -= d.powerNumerator / 666;
    }

    function _setPowerNumerator(uint256 powerNumerator) internal {
        TagStorage.layout().powerNumerator = powerNumerator;
    }

    function _setMinValue(uint256 minValue) internal {
        TagStorage.layout().minValue = minValue;
    }

    function _setMinLevelup(uint256 minLevelup) internal {
        TagStorage.layout().minLevelup = minLevelup;
    }

    function _setNotification(
        string memory notification1,
        string memory notification2
    ) internal {
        TagStorage.layout().notification1 = notification1;
        TagStorage.layout().notification2 = notification2;
    }
}