// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LuxCoin is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10**18; // 10 million tokens MAX
    uint256 public constant INITIAL_SUPPLY = 4_500_000 * 10**18; // 4.5 million tokens initially minted

    // Wallet addresses for different funds
    address public marketingWallet;
    address public developmentFundWallet;

    // Percentages of the initial supply - from the Tokenomics Plan
    uint256 public constant MARKETING_PERCENTAGE = 15;
    uint256 public constant DEVELOPMENT_FUND_PERCENTAGE = 20;

    
    constructor() ERC20("LuxCoin", "LUX") Ownable() {
       
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting would exceed max supply");
        _mint(msg.sender, amount);
    }

    function distributeInitialFunds() external onlyOwner {
        uint256 marketingAmount = (MAX_SUPPLY * MARKETING_PERCENTAGE) / 100;
        uint256 developmentFundAmount = (MAX_SUPPLY * DEVELOPMENT_FUND_PERCENTAGE) / 100;

        _transfer(msg.sender, marketingWallet, marketingAmount);
        _transfer(msg.sender, developmentFundWallet, developmentFundAmount);
    }

    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address(0), "Invalid marketing wallet address");
        marketingWallet = _marketingWallet;
    }

    function setDevelopmentFundWallet(address _developmentFundWallet) external onlyOwner {
        require(_developmentFundWallet != address(0), "Invalid development fund wallet address");
        developmentFundWallet = _developmentFundWallet;
    }
}
