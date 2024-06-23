// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/04_side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceTest is Test {
    SideEntranceLenderPool pool;
    address deployer;
    address player;

    uint256 constant ETHER_IN_POOL = 1000 ether;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 1 ether;

    function setUp() public {
        deployer = address(this);
        player = address(0x1);

        // Deploy pool and fund it
        pool = new SideEntranceLenderPool();
        vm.deal(deployer, ETHER_IN_POOL);
        pool.deposit{value: ETHER_IN_POOL}();
        assertEq(address(pool).balance, ETHER_IN_POOL);

        // Player starts with limited ETH in balance
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testSideEntrance() public {
        _execution();

        // Player took all ETH from the pool
        // assertEq(address(pool).balance, 0);
        // assertGt(player.balance, ETHER_IN_POOL);
    }
}
