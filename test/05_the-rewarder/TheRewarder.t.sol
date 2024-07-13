// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { TheRewarderPool } from "../../src/05_the-rewarder/TheRewarderPool.sol";
import { RewardToken } from "../../src/05_the-rewarder/RewardToken.sol";
import { FlashLoanerPool } from "../../src/05_the-rewarder/FlashLoanerPool.sol";
import { AccountingToken } from "../../src/05_the-rewarder/AccountingToken.sol";

contract TheRewarde is Test {
    DamnValuableToken public liquidityToken;
    FlashLoanerPool public flashLoanPool;
    TheRewarderPool public rewarderPool;
    RewardToken public rewardToken;
    AccountingToken public accountingToken;
    address public deployer;
    address public alice;
    address public bob;
    address public charlie;
    address public david;
    address public player;
    address[] public users;

    uint256 public constant TOKENS_IN_LENDER_POOL = 1_000_000 ether;

    function setUp() public {
        deployer = address(this);
        alice = address(0x1);
        bob = address(0x2);
        charlie = address(0x3);
        david = address(0x4);
        player = address(0x5);
        users = [alice, bob, charlie, david];

        // Deploy contracts
        liquidityToken = new DamnValuableToken();
        flashLoanPool = new FlashLoanerPool(address(liquidityToken));
        rewarderPool = new TheRewarderPool(address(liquidityToken));
        rewardToken = RewardToken(rewarderPool.REWARD_TOKEN());
        accountingToken = AccountingToken(rewarderPool.ACCOUNTING_TOKEN());

        // Set initial token balance of the pool offering flash loans
        liquidityToken.transfer(address(flashLoanPool), TOKENS_IN_LENDER_POOL);

        // Check roles in accounting token
        assertEq(accountingToken.owner(), address(rewarderPool));
        uint256 minterRole = accountingToken.MINTER_ROLE();
        uint256 snapshotRole = accountingToken.SNAPSHOT_ROLE();
        uint256 burnerRole = accountingToken.BURNER_ROLE();
        assertTrue(accountingToken.hasAllRoles(address(rewarderPool), minterRole | snapshotRole | burnerRole));

        // Alice, Bob, Charlie, and David deposit tokens
        uint256 depositAmount = 100 ether;
        for (uint256 i = 0; i < users.length; i++) {
            liquidityToken.transfer(users[i], depositAmount);
            vm.startPrank(users[i]);
            liquidityToken.approve(address(rewarderPool), depositAmount);
            rewarderPool.deposit(depositAmount);
            vm.stopPrank();
            assertEq(accountingToken.balanceOf(users[i]), depositAmount);
        }
        assertEq(accountingToken.totalSupply(), depositAmount * users.length);
        assertEq(rewardToken.totalSupply(), 0);

        // Advance time 5 days so that depositors can get rewards
        vm.warp(block.timestamp + 5 days);

        // Each depositor gets reward tokens
        uint256 rewardsInRound = rewarderPool.REWARDS();
        for (uint256 i = 0; i < users.length; i++) {
            vm.prank(users[i]);
            rewarderPool.distributeRewards();
            assertEq(rewardToken.balanceOf(users[i]), rewardsInRound / users.length);
        }
        assertEq(rewardToken.totalSupply(), rewardsInRound);

        // Player starts with zero DVT tokens in balance
        assertEq(liquidityToken.balanceOf(player), 0);

        // Two rounds must have occurred so far
        assertEq(rewarderPool.roundNumber(), 2);
    }

    function _execution() private {
        vm.startPrank(player);

        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.stopPrank();
    }

    function testTheRewarder() public {
        _execution();

        // Only one round must have taken place
        assertEq(rewarderPool.roundNumber(), 3);

        uint256 delta;
        // Users should get negligible rewards this round
        for (uint256 i = 0; i < users.length; i++) {
            vm.prank(users[i]);
            rewarderPool.distributeRewards();
            uint256 userRewards = rewardToken.balanceOf(users[i]);
            delta = userRewards - (rewarderPool.REWARDS() / users.length);
            assertLt(delta, 10 ** 16);
        }

        // Rewards must have been issued to the player account
        assertGt(rewardToken.totalSupply(), rewarderPool.REWARDS());
        uint256 playerRewards = rewardToken.balanceOf(player);
        console.log("rewardToken.playerRewards: ", playerRewards);
        assertGt(playerRewards, 0);

        // The amount of rewards earned should be close to total available amount
        delta = rewarderPool.REWARDS() - playerRewards;
        assertLt(delta, 10 ** 17);

        // Balance of DVT tokens in player and lending pool hasn't changed
        assertEq(liquidityToken.balanceOf(player), 0);
        assertEq(liquidityToken.balanceOf(address(flashLoanPool)), TOKENS_IN_LENDER_POOL);
    }
}
