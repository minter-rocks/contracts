// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


library DonationStorage {

    bytes32 constant DONATION_STORAGE_POSITION = keccak256("DONATION_STORAGE_POSITION");

    struct Layout {
        uint256 nextTokenId;
        uint256 minDonation;
        uint256 powerNumenator; //denumerator is 10,000
        mapping(uint256 => Donate) donates;
        mapping(address => uint256) userPower;
        uint256 totalDonation;
        uint256 totalPower;
        string notification1;
        string notification2;
    }

    struct Donate {
        string tag1;
        string tag2;
        uint256 amount_MATIC;
        uint256 amount_USD;
        uint256 votingPower;
        uint256 blockNumber;
        uint256 nonce;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = DONATION_STORAGE_POSITION;
        assembly {
            l.slot := slot
        }
    }
}
