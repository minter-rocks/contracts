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
        uint256 amount_MATIC,
        uint256 amount_USD,
        uint256 blockNumber
    ) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        TagStorage.Tag storage t = l.tags[id];

        require(
            amount_MATIC >= l.minValue,
            "TagInternal: minimum value error."
        );

        uint256 power = _consumePower(amount_MATIC);

        (string memory notion1, string memory notion2) = convert2Lines(notion);

        (
            t.notion1,
            t.notion2,
            t.amount_MATIC,
            t.amount_USD,
            t.votingPower,
            t.blockNumber
        ) = (
            notion1,
            notion2,
            amount_MATIC, 
            amount_USD, 
            power,
            blockNumber
        );
        _increaseUserPower(userAddr, power);
        l.totalValue += amount_MATIC;
    }

    function _levelup(
        uint256 id,
        address tokenOwner,
        uint256 amount_MATIC,
        string memory mention
    ) internal {
        TagStorage.Layout storage l = TagStorage.layout();
        require(
            amount_MATIC >= l.minLevelup,
            "TagInternal: minimum value error."
        );

        uint256 power = _consumePower(amount_MATIC);

        l.tags[id].amount_MATIC += amount_MATIC;
        l.tags[id].votingPower += power;
        l.tags[id].donates[l.tags[id].donatesCount++] =
            TagStorage.Donate(msg.sender, amount_MATIC, mention);

        _increaseUserPower(tokenOwner, power);
        l.totalValue += amount_MATIC;
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

    function convert2Lines(string calldata input) internal pure returns (
        string memory output1,
        string memory output2
    ) {
        uint256 endLine;
        uint256 inputLen2;
        bool line2;
        uint256 char;
        uint256 charAdd;
        bytes memory inputBytes = bytes(input);

        while (char < inputBytes.length){
            if (inputBytes[char]>>7==0){
                charAdd = 1;
            } else if (inputBytes[char]>>5==bytes1(uint8(0x6))){
                charAdd = 2;
            } else if (inputBytes[char]>>4==bytes1(uint8(0xE))){
                charAdd = 3;
                inputLen2 ++;
            } else if (inputBytes[char]>>3==bytes1(uint8(0x1E))){
                charAdd = 4;
                inputLen2 += 2;
            } else {
                //For safety
                charAdd = 1;
            }

            if(!line2 && inputBytes[char] == 0x20){
                endLine = char+charAdd;
            }

            char += charAdd;
            inputLen2 += 2;

            if(inputLen2 > 66){
                require(
                    !line2,
                    "TagInternal: input string overflow1"
                );
                line2 = true;
                endLine = endLine != 0 ? endLine : char-charAdd;
                inputLen2 = 0;
            }
        }
        
        if(line2) {
            require(
                inputLen2/2 < endLine,
                "TagInternal: input string overflow2"
            );
            output1 = input[:endLine];
            output2 = input[endLine:char];   
        } else {
            output1 = input;
        }
    }

}