

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ICO {
    address public tokenAddress = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;  // Replace with your ERC-20 token address
    address public owner;
    uint public tokenPrice;       // Price of 1 token in Wei
    uint public tokensSold;       // Total number of tokens sold
    uint public minPurchase;      // Minimum purchase amount in Wei
    uint public maxPurchase;      // Maximum purchase amount in Wei

    mapping(address => uint) public contributions;

    event TokensPurchased(address indexed buyer, uint amount, uint totalContributions);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint _tokenPrice, uint _minPurchase, uint _maxPurchase) {
        owner = msg.sender;
        tokenPrice = _tokenPrice;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }

    function buyTokens() external payable {
        require(msg.value >= minPurchase && msg.value <= maxPurchase, "Invalid purchase amount");

        uint tokensToBuy = msg.value / tokenPrice;
        require(tokensToBuy > 0, "Insufficient funds to buy tokens");

        require(ERC20Interface(tokenAddress).transfer(msg.sender, tokensToBuy), "Token transfer failed");

        tokensSold += tokensToBuy;
        contributions[msg.sender] += msg.value;

        emit TokensPurchased(msg.sender, tokensToBuy, contributions[msg.sender]);
    }

    function withdrawEther() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawExcessTokens() external onlyOwner {
        ERC20Interface token = ERC20Interface(tokenAddress);
        uint excessTokens = token.balanceOf(address(this)) - tokensSold;
        require(token.transfer(owner, excessTokens), "Token transfer failed");
    }
}
