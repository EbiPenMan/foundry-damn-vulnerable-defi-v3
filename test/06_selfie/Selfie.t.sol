// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/DamnValuableTokenSnapshot.sol";
import "../../src/06_selfie/SimpleGovernance.sol";
import "../../src/06_selfie/SelfiePool.sol";

contract Selfie is Test {
    address deployer;
    address user;
    address player;

    DamnValuableTokenSnapshot internal token;
    SimpleGovernance internal governance;
    SelfiePool internal pool;

    uint256 internal constant TOKEN_INITIAL_SUPPLY = 2000000 * 10 ** 18;
    uint256 internal constant TOKENS_IN_POOL = 1500000 * 10 ** 18;

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
        pool = new SelfiePool(
            address(token),
            address(governance)
        );
        assertEq(address(pool.token()), address(token));
        assertEq(address(pool.governance()), address(governance));

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        token.snapshot();
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(pool.maxFlashLoan(address(token)), TOKENS_IN_POOL);
        assertEq(pool.flashFee(address(token), 0), 0);
        vm.stopPrank();
    }

    function _execution() private {
        /** CODE YOUR SOLUTION HERE */
    }

    function testSelfie() public {
        _execution();

        // SUCCESS CONDITIONS

        // Player has taken all tokens from the pool
        // assertEq(token.balanceOf(player), TOKENS_IN_POOL);
        // assertEq(token.balanceOf(address(pool)), 0);
    }
}
