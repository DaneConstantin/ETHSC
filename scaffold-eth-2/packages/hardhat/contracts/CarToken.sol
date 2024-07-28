// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CarToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**18; // 10 million tokens MAX
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**18; // 1 million tokens initially minted
    constructor() ERC20("CarToken", "MCRT") Ownable() {
       
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting would exceed max supply");
        _mint(msg.sender, amount);
    }
}
