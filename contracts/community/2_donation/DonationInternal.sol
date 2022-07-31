// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./TagStorage.sol";

abstract contract TagInternal {
    using TagStorage for TagStorage.Layout;
    using TagStorage for TagStorage.Tag;

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
        uint256 amount_Matic,
        uint256 amount_USD,
        uint256 blockNumber
    ) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        require(
            amount_Matic >= l.minTag,
            "TagInternal: minimum tag error."
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
            require(notionLen - endLine <= 33, "TagInternal: notion string overflow");
            notion1 = notion[:endLine];
            notion2 = notion[endLine:notionLen];
        } else {
            notion1 = notion;
        }

        uint256 power = _consumePower(amount_Matic);

        l.tags[id] = TagStorage.Tag(
            notion1,
            notion2,
            amount_Matic, 
            amount_USD, 
            power,
            blockNumber,
            0
        );
        _increaseUserPower(userAddr, power);
        l.totalTag += amount_Matic;
    }

    function _increaseNonce(uint256 tokenId) internal {
        TagStorage.layout().tags[tokenId].nonce ++;
    }

    function _consumePower(uint256 paidAmount) internal returns(uint256 powerAmount) {
        TagStorage.Layout storage d = TagStorage.layout();
        powerAmount = paidAmount / (10 ** 10) * d.powerNumerator;
        d.powerNumerator -= d.powerNumerator / 666;
    }

    function _setPowerNumerator(uint256 powerNumerator) internal {
        TagStorage.layout().powerNumerator = powerNumerator;
    }

    function _setMinTag(uint256 minTag) internal {
        TagStorage.layout().minTag = minTag;
    }

    function _setNotification(
        string memory notification1,
        string memory notification2
    ) internal {
        TagStorage.layout().notification1 = notification1;
        TagStorage.layout().notification2 = notification2;
    }

}