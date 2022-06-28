// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../1_ERC721SolidState/base/ERC721BaseInternal.sol";
import "../2_donation/DonationStorage.sol";
import '@solidstate/contracts/utils/AddressUtils.sol';
import '@solidstate/contracts/utils/UintUtils.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./utils/UintToFloatString.sol";

contract OnchainMetadata is ERC721BaseInternal {
    using AddressUtils for address;
    using UintUtils for uint;
    using UintToFloatString for uint;
    using ERC721BaseStorage for ERC721BaseStorage.Layout;

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(ERC721BaseStorage.layout().exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        DonationStorage.Layout storage d = DonationStorage.layout();

        return string.concat('data:application/json;base64,', Base64.encode(abi.encodePacked(
            '{',
                '"name": "donation card", ',
                '"description": "donation receipt card", ',
                '"image": "', 
                    _image({
                        tag : d.donates[tokenId].tag,
                        cardPower : d.donates[tokenId].votingPower.floatString(20, 4),
                        notification : address(this).balance.floatString(18, 2),
                        blockNumber : d.donates[tokenId].blockNumber.toString(),
                        donationMatic : d.donates[tokenId].amount_MATIC.floatString(18, 2),
                        donationUSD : d.donates[tokenId].amount_USD.floatString(18, 2)
                    }),
                '"', 
            '}'
            ))
        ); 
    }

    function _image(
        string memory tag,
        string memory cardPower,
        string memory notification,
        string memory blockNumber,
        string memory donationMatic,
        string memory donationUSD
    ) internal pure returns(string memory) {
        return string.concat(
            'data:image/svg+xml;base64,', Base64.encode(abi.encodePacked(
                '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 493 840"><defs><style>.cls-1{fill:none;}.cls-2{clip-path:url(#clip-path);}.cls-3,.cls-7{fill:#fff;}.cls-4{fill:#f8f8f8;}.cls-5{font-size:32px;}.cls-5,.cls-8{font-family:Poppins-SemiBold, Poppins;font-weight:600;}.cls-6,.cls-7{font-size:24px;font-family:Poppins-Regular, Poppins;}.cls-8{font-size:40px;}.cls-9{fill:#86efac;}.cls-10{fill:#a5f3fc;}.cls-11{fill:#fca5a5;}.cls-12{fill:#fef08a;}</style><clipPath id="clip-path" transform="translate(6)"><rect class="cls-1" width="480" height="840" rx="48"/></clipPath></defs><g class="cls-2"><rect class="cls-3" x="6" width="480" height="840" rx="48"/><rect class="cls-4" x="41" y="81" width="341" height="83" rx="10"/><rect class="cls-4" x="41" y="408" width="410" height="181" rx="10"/><rect y="761" width="493" height="79"/></g><text class="cls-5" transform="translate(54 462)">',
                donationMatic,
                '<tspan x="20.61" y="0" xml:space="preserve"> ',
                'MATIC (', donationUSD, ' $)',
                '</tspan></text><text class="cls-5" transform="translate(54 516)"> Donate</text><text class="cls-6" transform="translate(54 560)"> Block Number : ',
                blockNumber,
                '</text><text class="cls-6" transform="translate(54 708)"> this card has ',
                cardPower,
                ' power in chat room.</text><text class="cls-7" transform="translate(54 806)"> First Goal: ',
                notification,
                ' of 8000</text><text class="cls-8" transform="translate(54 223)"> ',
                bytes(tag).length == 0 ?'I Love NFT' : tag,
                '</text><text class="cls-8" transform="translate(54.94 138.23)"> Minter.Rocks</text><circle class="cls-9" cx="131.66" cy="385.4" r="15"/><circle class="cls-9" cx="223.68" cy="322.15" r="4.36"/><circle class="cls-10" cx="309.36" cy="336.47" r="12.64"/><circle class="cls-10" cx="60.97" cy="363.44" r="6.97"/><circle class="cls-11" cx="172.69" cy="346.76" r="5.86"/><circle class="cls-11" cx="366.05" cy="375.72" r="7.24"/><circle class="cls-12" cx="235.63" cy="378.39" r="7.59"/><circle class="cls-12" cx="430.01" cy="349.11" r="10.01"/><circle class="cls-12" cx="97.76" cy="320.03" r="3.8"/></svg>'
            ))
        );
    }
}