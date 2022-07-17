// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SVGTextRegex {

    string constant regex = '^[&<"]';

    function isValid(string memory text) internal pure returns(bool) {
        bytes memory t = bytes(text);
        for (uint i = 0; i < t.length; i++) {
            if(!_isValid(t[i])) {return false;}
        }
        return true;
    }

    function _isValid(bytes1 char) private pure returns(bool) {
        if (  
            char == 0x22 // `"`
            ||
            char == 0x26 // `&`
            ||
            char == 0x3c // `<`
        ) {
            return false;
        }
        return true;
    }
}