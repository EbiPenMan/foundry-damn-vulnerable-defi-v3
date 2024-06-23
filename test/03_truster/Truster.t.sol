// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/DamnValuableToken.sol";
import "../../src/03_truster/TrusterLenderPool.sol";

contract Truster is Test {
    DamnValuableToken token;
    TrusterLenderPool pool;
    address deployer;
    address player;

    uint256 constant TOKENS_IN_POOL = 1000000 * 10 ** 18;

    function setUp() public {
        deployer = address(this);
        player = address(0x1);

        // Deploy token and pool contracts
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(DamnValuableToken(token));
        assertEq(address(pool.token()), address(token));

        // Transfer tokens to the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(player), 0);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testTruster() public {
        _execution();

        // Player has taken all tokens from the pool
        // assertEq(token.balanceOf(player), TOKENS_IN_POOL);
        // assertEq(token.balanceOf(address(pool)), 0);
    }
}
