// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ChatRoomInternal.sol";

contract ChatRoom is ChatRoomInternal{
    
    
    function register(string memory _username) public {
        _register(msg.sender, _username);
    }
}