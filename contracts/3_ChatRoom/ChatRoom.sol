// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ChatRoomInternal.sol";

contract ChatRoom is ChatRoomInternal{
    
    
    function register(string memory username_) public {
        _register(msg.sender, username_);
    }    
    
    function unRegister() public {
        _unRegister(msg.sender);
    }

    function username(address userAddr) public view returns(string memory usename_) {
        usename_ = _username(userAddr);
        require(bytes(usename_).length > 0, "ChatRoom: query for not registered user");
    }
}