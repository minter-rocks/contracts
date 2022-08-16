// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library UTF8Length {

    function len(
        string memory input
    ) internal pure returns(uint256) {

        uint256 char;
        uint256 len2;

        bytes memory inputBytes = bytes(input);

        while (char < inputBytes.length){
            if (inputBytes[char]>>7==0){
                char += 1;
                len2 += 2;
            } else if (inputBytes[char]>>5==bytes1(uint8(0x6))){
                char += 2;
                len2 += 2;
            } else if (inputBytes[char]>>4==bytes1(uint8(0xE))){
                char += 3;
                len2 += 3;
            } else if (inputBytes[char]>>3==bytes1(uint8(0x1E))){
                char += 4;
                len2 += 4;
            } else {
                //For safety
                char += 1;
                len2 += 2;
            }
        }
        return len2 / 2;
    }
}