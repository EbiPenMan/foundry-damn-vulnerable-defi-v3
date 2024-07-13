// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { NaiveReceiverLenderPool } from "../../src/02_naive-receiver/NaiveReceiverLenderPool.sol";
import { FlashLoanReceiver } from "../../src/02_naive-receiver/FlashLoanReceiver.sol";

contract NaiveReceiver is Test {
    NaiveReceiverLenderPool public pool;
    FlashLoanReceiver public receiver;
    address public deployer;
    address public user;
    address public player;

    uint256 public constant ETHER_IN_POOL = 1000 ether;
    uint256 public constant ETHER_IN_RECEIVER = 10 ether;

    function setUp() public {
        deployer = address(this);
        user = address(0x1);
        player = address(0x2);

        // Deploy Lender Pool contract
        pool = new NaiveReceiverLenderPool();
        vm.deal(deployer, ETHER_IN_POOL);
        (bool success,) = address(pool).call{ value: ETHER_IN_POOL }("");
        require(success, "Funding pool failed");

        assertEq(address(pool).balance, ETHER_IN_POOL);
        assertEq(pool.maxFlashLoan(pool.ETH()), ETHER_IN_POOL);
        assertEq(pool.flashFee(pool.ETH(), 0), 1 ether);

        // Deploy Flash Loan Receiver contract
        receiver = new FlashLoanReceiver(address(pool));
        vm.deal(deployer, ETHER_IN_RECEIVER);
        (success,) = address(receiver).call{ value: ETHER_IN_RECEIVER }("");
        require(success, "Funding receiver failed");

        address eth = pool.ETH();

        vm.expectRevert();
        receiver.onFlashLoan(deployer, eth, ETHER_IN_RECEIVER, 1 ether, "0x");
        assertEq(address(receiver).balance, ETHER_IN_RECEIVER);
    }

    function _execution() private {
        vm.startPrank(player);

        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.stopPrank();
    }

    function testNaiveReceiver() public {
        _execution();

        // All ETH has been drained from the receiver
        assertEq(address(receiver).balance, 0);
        assertEq(address(pool).balance, ETHER_IN_POOL + ETHER_IN_RECEIVER);
    }
}
