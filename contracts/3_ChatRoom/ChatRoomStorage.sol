// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


library ChatRoomStorage {

    bytes32 constant CHATROOM_STORAGE_POSITION = keccak256("CHATROOM_STORAGE_POSITION");

    struct Layout {
        mapping(address => string) users;
        mapping(string => address) registered;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = CHATROOM_STORAGE_POSITION;
        assembly {
            l.slot := slot
        }
    }
}
