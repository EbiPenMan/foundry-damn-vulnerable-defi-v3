// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { TrusterLenderPool } from "../../src/03_truster/TrusterLenderPool.sol";

contract Truster is Test {
    DamnValuableToken public token;
    TrusterLenderPool public pool;
    address public deployer;
    address public player;

    uint256 public constant TOKENS_IN_POOL = 1_000_000 * 10 ** 18;

    function setUp() public {
        deployer = address(0x1);
        player = address(0x2);

        // Deploy token and pool contracts
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(DamnValuableToken(token));
        assertEq(address(pool.TOKEN()), address(token));

        // Transfer tokens to the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(player), 0);
    }

    function _execution() private {
        vm.startPrank(player);

        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.stopPrank();
    }

    function testTruster() public {
        _execution();

        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(player), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}
