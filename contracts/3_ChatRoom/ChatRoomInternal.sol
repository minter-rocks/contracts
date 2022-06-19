// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ChatRoomStorage.sol";
import "./utils/StringUtil.sol";
import "./utils/LiteralRegex.sol";

contract ChatRoomInternal {
    using ChatRoomStorage for ChatRoomStorage.Layout;
    using StringUtil for string;
    using LiteralRegex for string;

    event Register(address userAddr, string username);

    function _register(address userAddr, string memory _username) public {
        ChatRoomStorage.Layout storage l = ChatRoomStorage.layout();

        require(
            _username.isLiteral(),
            "you can just use numbers(0-9) letters(a-zA-Z) and signs(-._)"
        );

        string memory lower = _username.lower();

        require(
            l.registered[lower] == address(0), 
            "ChatRoomInternal: the username has already been registered"
        );

        l.users[userAddr] = _username;
        l.registered[lower] = userAddr;

        emit Register(userAddr, _username);
    }
}