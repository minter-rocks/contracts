// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../1_ERC721SolidState/base/ERC721BaseInternal.sol";
import "../2_donation/DonationStorage.sol";
import '@solidstate/contracts/utils/AddressUtils.sol';
import '@solidstate/contracts/utils/UintUtils.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./utils/UintToFloatString.sol";
import "./utils/SVGTextValidator.sol";

contract OnchainMetadata is ERC721BaseInternal {
    using AddressUtils for address;
    using UintUtils for uint;
    using UintToFloatString for uint;
    using ERC721BaseStorage for ERC721BaseStorage.Layout;

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(ERC721BaseStorage.layout().exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        DonationStorage.Layout storage d = DonationStorage.layout();

        uint256 cardPower = d.donates[tokenId].votingPower;

        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
            '{',
                '"name": "donation number ', tokenId, '", ',
                '"description": "', d.donates[tokenId].tag, '", ',
                '"image": "',
                    cardPower < 10 ** 21 ?
                    _image({
                        tag : SVGTextValidator.validate(d.donates[tokenId].tag),
                        cardPower : cardPower.floatString(20, 3),
                        notification : bytes(d.notification).length > 0 ? d.notification : 
                        string.concat('First Goal : ',d.totalDonation.floatString(18, 2),' of 8000 MATIC'),
                        blockNumber : d.donates[tokenId].blockNumber.toString(),
                        donationMatic : d.donates[tokenId].amount_MATIC.floatString(18, 2),
                        donationUSD : d.donates[tokenId].amount_USD.floatString(18, 2)
                    }) :
                    _image2({
                        tag : SVGTextValidator.validate(d.donates[tokenId].tag),
                        cardPower : cardPower.floatString(20, 3),
                        notification : bytes(d.notification).length > 0 ? d.notification : 
                        string.concat('First Goal : ',d.totalDonation.floatString(18, 2),' of 8000 MATIC'),
                        blockNumber : d.donates[tokenId].blockNumber.toString(),
                        donationMatic : d.donates[tokenId].amount_MATIC.floatString(18, 2),
                        donationUSD : d.donates[tokenId].amount_USD.floatString(18, 2),
                        points : _points(tokenId, cardPower)
                    }),
                '"', 
            '}'
            ))
        ); 
    }

    function _points(uint256 tokenId, uint256 cardPower) private pure returns(string memory points) {
        uint256 counter = cardPower / 10 ** 21 + 1;
        uint256 hashNum = uint256(keccak256(abi.encode(tokenId)));
        while(counter > 0) {
            if(hashNum > 1000) {
                points = string.concat(
                    points,
                    ((hashNum /= 10) % 1000 / 2).toString(),
                    " "
                );
                counter --;
            }
        }
    }

    function _image(
        string memory tag,
        string memory cardPower,
        string memory notification,
        string memory blockNumber,
        string memory donationMatic,
        string memory donationUSD
    ) private pure returns(string memory) {
        
        string memory imageString = string.concat(
                '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 493 840"><defs><style>.cls-1{fill:none;}.cls-2{clip-path:url(#clip-path);}.cls-3,.cls-7{fill:#fff;}.cls-4{fill:#f8f8f8;}.cls-5{font-size:32px;}.cls-5,.cls-8{font-family:Poppins-SemiBold, Poppins;font-weight:600;}.cls-6,.cls-7{font-size:24px;font-family:Poppins-Regular, Poppins;}.cls-8{font-size:40px;}.cls-9{fill:#86efac;}.cls-10{fill:#a5f3fc;}.cls-11{fill:#fca5a5;}.cls-12{fill:#fef08a;}</style><clipPath id="clip-path" transform="translate(6)"><rect class="cls-1" width="480" height="840" rx="48"/></clipPath></defs><g class="cls-2"><rect class="cls-3" x="6" width="480" height="840" rx="48"/><rect class="cls-4" x="41" y="81" width="341" height="83" rx="10"/><rect class="cls-4" x="41" y="408" width="410" height="181" rx="10"/><rect y="761" width="493" height="79"/></g><text class="cls-5" transform="translate(54 462)">',
                donationMatic, ' MATIC (', donationUSD, 
                ' $)</text><text class="cls-5" transform="translate(54 516)"> Donate</text><text class="cls-6" transform="translate(54 560)"> Block Number : ',
                blockNumber,
                '</text><text class="cls-6" transform="translate(54 708)"> card voting power : ',
                cardPower,
                '</text><text class="cls-7" transform="translate(54 806)">',
                notification,
                '</text><text class="cls-8" transform="translate(54 223)"> ',
                tag,
                '</text><text class="cls-8" transform="translate(54.94 138.23)"> Minter.Rocks</text><circle class="cls-9" cx="131.66" cy="385.4" r="15"/><circle class="cls-9" cx="223.68" cy="322.15" r="4.36"/><circle class="cls-10" cx="309.36" cy="336.47" r="12.64"/><circle class="cls-10" cx="60.97" cy="363.44" r="6.97"/><circle class="cls-11" cx="172.69" cy="346.76" r="5.86"/><circle class="cls-11" cx="366.05" cy="375.72" r="7.24"/><circle class="cls-12" cx="235.63" cy="378.39" r="7.59"/><circle class="cls-12" cx="430.01" cy="349.11" r="10.01"/><circle class="cls-12" cx="97.76" cy="320.03" r="3.8"/></svg>'
        );
        
        return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(imageString)));
    }

    function _image2(
        string memory tag,
        string memory cardPower,
        string memory notification,
        string memory blockNumber,
        string memory donationMatic,
        string memory donationUSD,
        string memory points
    ) private pure returns(string memory) {      
        string memory imageString = string.concat(
            '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="100 0 300 500"><defs><style>.cls-1,.cls-9{fill:none;}.cls-2{clip-path:url(#clip-path);}.cls-3{stroke:#1d1d1b;}.cls-3,.cls-9{stroke-miterlimit:10;}.cls-14,.cls-4,.cls-6,.cls-7,.cls-8{font-size:10px;}.cls-11,.cls-14,.cls-4{fill:#99cf29;}.cls-11,.cls-13,.cls-4,.cls-5,.cls-6,.cls-7,.cls-8{font-family:CourierNewPS-BoldMT, Courier New;font-weight:700;}.cls-5{font-size:12px;}.cls-13,.cls-5{fill:#fff;}.cls-6{fill:#a80054;}.cls-12,.cls-7{fill:#dd6400;}.cls-8{fill:#00e1f2;}.cls-9{stroke:#dadada;stroke-width:0.5px;}.cls-10{fill:#1b1718;opacity:0.98;}.cls-11{font-size:14px;}.cls-13{overflow: scroll; font-size:7px;}.cls-14{text-align: right; font-family:CourierNewPSMT, Courier New;}</style><clipPath id="clip-path" transform="translate(78.35 72.9)"><rect class="cls-1" width="195.23" height="265.56"/></clipPath></defs><g class="cls-2"><rect class="cls-3" x="78.35" y="72.9" width="195.23" height="265.14"/><text class="cls-4" transform="translate(87.76 273.1)">Voting</text><text class="cls-5" transform="translate(87.76 236.5)">',
            donationMatic, ' MATIC (', donationUSD, 
            ' $)</text><text class="cls-6" transform="translate(162.09 257.92)">',
            blockNumber,
            '</text><text class="cls-7" transform="translate(87.76 257.92)">Block</text><text class="cls-7" transform="translate(128.81 273.1)">Power</text><text class="cls-8" transform="translate(122.42 257.92)">number</text><polygon class="cls-9" points="',
            points,
            '"/><rect class="cls-10" x="78.35" y="69.5" width="195.23" height="57.3"/><rect class="cls-10" x="76.13" y="284.56" width="197.45" height="53.9"/><text class="cls-11" transform="translate(87.76 94.59)">Minter.<tspan class="cls-12" x="58.81" y="0">rocks</tspan></text><text class="cls-8" transform="translate(163.96 273.1)">',
            cardPower,
            '</text><text class="cls-13" transform="translate(87.76 105.97)">',
            tag,
            '</tspan></text><text class="cls-14" transform="translate(87.75 303.68)">NOTIFICATION</text><text class="cls-14" transform="translate(87.76 322.84)">',
            notification,
            '</text></g></svg>'
        );
        
        return string.concat('data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(imageString)));
    }


}