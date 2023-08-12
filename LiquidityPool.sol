// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public poolBalance;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        poolBalance = 100000000;  // example balance
        owner = msg.sender;
    }

    function deposit(uint256 amount) external onlyOwner {
        poolBalance += amount;
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(poolBalance >= amount, "Not enough funds in the pool");
        poolBalance -= amount;
    }
}

