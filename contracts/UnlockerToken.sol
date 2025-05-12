// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UnlockerToken is ERC20, Ownable {
    constructor(
        string memory name_,
        string memory symbol_,
        address owner_,
        uint256 initialSupply_
    ) ERC20(name_, symbol_) Ownable(owner_) {
        _mint(owner_, initialSupply_);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
