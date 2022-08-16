// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


library TagStorage {

    bytes32 constant DONATION_STORAGE_POSITION = keccak256("DONATION_STORAGE_POSITION");

    struct Layout {
        uint256 nextTokenId;
        uint256 minValue;
        uint256 powerNumerator; //denominator is 10,000,000,000
        mapping(uint256 => Tag) tags;
        mapping(address => uint256) userPower;
        uint256 totalValue;
        uint256 totalPower;
        uint256 minLevelup;
        string notification1;
        string notification2;
    }

    struct Tag {
        string notion;
        uint256 value;
        uint256 votingPower;
        uint256 blockNumber;
        uint256 donatesCount;
        mapping(uint256 => Donate) donates;
    }

    struct Donate{
        address donator;
        uint256 amount;
        string mention;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = DONATION_STORAGE_POSITION;
        assembly {
            l.slot := slot
        }
    }
}
