// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../1_ERC721SolidState/base/ERC721BaseInternal.sol";
import "../2_donation/DonationStorage.sol";
import '@solidstate/contracts/utils/AddressUtils.sol';
import '@solidstate/contracts/utils/UintUtils.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./utils/UintToFloatString.sol";

contract OnchainMetadata is ERC721BaseInternal {
//     using AddressUtils for address;
    using UintUtils for uint;
//     using UintToFloatString for uint;
//     using ERC721BaseStorage for ERC721BaseStorage.Layout;

//     function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
//         require(ERC721BaseStorage.layout().exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

//         DonationStorage.Layout storage d = DonationStorage.layout();

//         return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
//             '{',
//                 '"name": "donation card", ',
//                 '"description": "donation receipt card", ',
//                 '"image": "', 
//                     _image({
//                         tag : d.donates[tokenId].tag,
//                         cardPower : d.donates[tokenId].votingPower.floatString(20, 3),
//                         notification : bytes(d.notification).length > 0 ? d.notification : 
//                         string.concat('First Goal : ',d.totalDonation.floatString(18, 2),' of 8000 MATIC'),
//                         blockNumber : d.donates[tokenId].blockNumber.toString(),
//                         donationMatic : d.donates[tokenId].amount_MATIC.floatString(18, 2),
//                         donationUSD : d.donates[tokenId].amount_USD.floatString(18, 2)
//                     }),
//                 '"', 
//             '}'
//             ))
//         ); 
//     }

//     function _image(
//         uint256 tokenId
//     ) internal pure returns(string memory) {
        
//         string memory imageString = string.concat(
//             '<?xml version="1.0" encoding="utf-8"?><svg viewBox="214.568 -83.812 262.342 393.227" width="262.342" height="393.227" xmlns="http://www.w3.org/2000/svg"><path style="stroke: rgb(0, 0, 0); fill: none;" d="',
//             M 666.348 -9.121,
//             L -9.886 249.777 
//             L 515.946 164.817 
//             L 166.348 13.841 
//             L 137.071 113.152 
//             L 703.087 275.609 
//             L 294.936 -114.173 
//             L 205.383 285.368 
//             L 663.478 389.846 
//             L 131.331 -104.414
//             '"/></svg>'
//         );
        
//         return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(imageString)));
//     }

    function _points(uint256 tokenId) public pure returns(string memory points) {
        while(tokenId > 1000) {
            points = string.concat(
                points,
                ((tokenId /= 1000) % 1000 / 2).toString(),
                " "
            );
        }
    }
}