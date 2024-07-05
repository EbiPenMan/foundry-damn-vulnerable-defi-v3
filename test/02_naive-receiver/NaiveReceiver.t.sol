// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/02_naive-receiver/NaiveReceiverLenderPool.sol";
import "../../src/02_naive-receiver/FlashLoanReceiver.sol";

contract NaiveReceiver is Test {
    NaiveReceiverLenderPool pool;
    FlashLoanReceiver receiver;
    address deployer;
    address user;
    address player;

    uint256 constant ETHER_IN_POOL = 1000 ether;
    uint256 constant ETHER_IN_RECEIVER = 10 ether;

    function setUp() public {
        deployer = address(this);
        user = address(0x1);
        player = address(0x2);

        // Deploy Lender Pool contract
        pool = new NaiveReceiverLenderPool();
        vm.deal(deployer, ETHER_IN_POOL);
        (bool success, ) = address(pool).call{value: ETHER_IN_POOL}("");
        require(success, "Funding pool failed");

        assertEq(address(pool).balance, ETHER_IN_POOL);
        assertEq(pool.maxFlashLoan(pool.ETH()), ETHER_IN_POOL);
        assertEq(pool.flashFee(pool.ETH(), 0), 1 ether);

        // Deploy Flash Loan Receiver contract
        receiver = new FlashLoanReceiver(address(pool));
        vm.deal(deployer, ETHER_IN_RECEIVER);
        (success, ) = address(receiver).call{value: ETHER_IN_RECEIVER}("");
        require(success, "Funding receiver failed");

        address eth = pool.ETH();

        vm.expectRevert();
        receiver.onFlashLoan(deployer, eth, ETHER_IN_RECEIVER, 1 ether, "0x");
        assertEq(address(receiver).balance, ETHER_IN_RECEIVER);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testNaiveReceiver() public {
        _execution();
        
        // All ETH has been drained from the receiver
        assertEq(address(receiver).balance, 0);
        assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER);
    }
}
