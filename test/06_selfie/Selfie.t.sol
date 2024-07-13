// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { DamnValuableTokenSnapshot } from "../../src/DamnValuableTokenSnapshot.sol";
import { SimpleGovernance } from "../../src/06_selfie/SimpleGovernance.sol";
import { SelfiePool } from "../../src/06_selfie/SelfiePool.sol";

contract Selfie is Test {
    address public deployer;
    address public user;
    address public player;

    DamnValuableTokenSnapshot internal token;
    SimpleGovernance internal governance;
    SelfiePool internal pool;

    uint256 internal constant TOKEN_INITIAL_SUPPLY = 2_000_000 * 10 ** 18;
    uint256 internal constant TOKENS_IN_POOL = 1_500_000 * 10 ** 18;

    function setUp() public {
        deployer = address(this);
        user = address(0x1);
        player = address(0x2);

        vm.deal(deployer, 1 ether);
        vm.deal(player, 1 ether);

        // Deploy Damn Valuable Token Snapshot
        vm.startPrank(deployer);
        token = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);

        // Deploy governance contract
        governance = new SimpleGovernance(address(token));
        assertEq(governance.getActionCounter(), 1);

        // Deploy the pool
        pool = new SelfiePool(address(token), address(governance));
        assertEq(address(pool.TOKEN()), address(token));
        assertEq(address(pool.GOVERNANCE()), address(governance));

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        token.snapshot();
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(pool.maxFlashLoan(address(token)), TOKENS_IN_POOL);
        assertEq(pool.flashFee(address(token), 0), 0);
        vm.stopPrank();
    }

    function _execution() private {
        vm.startPrank(player);

        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.stopPrank();
    }

    function testSelfie() public {
        _execution();

        // SUCCESS CONDITIONS

        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(player), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}
