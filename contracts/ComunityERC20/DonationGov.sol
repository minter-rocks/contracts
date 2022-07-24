// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "../2_donation/IDonation.sol";

contract DonationGov is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, ERC20Permit, ERC20Votes {

    // on polygon
    IDonation constant don = IDonation(0xB42cE907d99b74578b9913A560B9c5C1A237356b);

    constructor() ERC20("DonationGov", "DG") ERC20Permit("DonationGov") {}

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return super.balanceOf(account) + don.userPower(account);
    }

    function totalSupply() public view virtual override returns (uint256) {
        return super.totalSupply() + don.totalPower();
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}