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
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);  //each emit creates an event
}

contract Cryptos is ERC20Interface {
    string public name = "Ali";
    string public symbol = "Ak";
    uint public decimals = 0; // 18 is very common
    uint public override totalSupply;

    address public founder;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens);
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
        return allowed[tokenOwner][spender];    //here we can see amount of tokens a spender can spend on behalf of owner, owner sets a limit
    }

    function approve(address spender, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);   //tokens which sender allowed for spender to spend, grant permission to an address to spend said tokens
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
         //takes 3 inputs, return a boolean value, showing success/failure
         //first owner should approve the spender to be able to spend his tokens
         //then the spender can use this function to spend owners tokens from owner's account to another address
        
        require(tokens <= balances[from]);    //tokens being trans not greater than balance of address from where being taken
        require(tokens <= allowed[from][msg.sender]);  //is within allowance of token sender, his limit he allowed

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][msg.sender] -= tokens;

        emit Transfer(from, to, tokens);
        return true;
    }
}
