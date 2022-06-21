// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


library DonationStorage {

    bytes32 constant DONATION_STORAGE_POSITION = keccak256("DONATION_STORAGE_POSITION");

    struct Layout {
        uint256 nextTokenId;
        uint256 powerDenumenator;
        mapping(uint256 => Donate) donates;
        mapping(address => uint256) userTotalDonation;
        string notification;
    }

    struct Donate {
        string tag;
        uint256 amount_MATIC;
        uint256 amount_USD;
        uint256 votingPower;
        uint256 blockNumber;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = DONATION_STORAGE_POSITION;
        assembly {
            l.slot := slot
        }
    }
}
