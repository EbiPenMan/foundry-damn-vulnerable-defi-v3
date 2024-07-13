// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { DamnValuableToken, ERC20 } from "../../src/DamnValuableToken.sol";
import { UnstoppableVault } from "../../src/01_unstoppable/UnstoppableVault.sol";
import { ReceiverUnstoppable } from "../../src/01_unstoppable/ReceiverUnstoppable.sol";

contract Unstoppable is Test {
    DamnValuableToken public token;
    UnstoppableVault public vault;
    ReceiverUnstoppable public receiverContract;
    address public deployer;
    address public player;
    address public someUser;

    uint256 public constant TOKENS_IN_VAULT = 1_000_000 * 10 ** 18;
    uint256 public constant INITIAL_PLAYER_TOKEN_BALANCE = 10 * 10 ** 18;

    function setUp() public {
        deployer = address(this);
        player = address(0x1);
        someUser = address(0x2);

        // Deploy token and vault contracts
        token = new DamnValuableToken();
        vault = new UnstoppableVault(
            ERC20(token),
            deployer, // owner
            deployer // fee recipient
        );
        assertEq(address(vault.asset()), address(token));

        // Approve and deposit tokens to the vault
        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, deployer);

        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT);
        assertEq(vault.totalAssets(), TOKENS_IN_VAULT);
        assertEq(vault.totalSupply(), TOKENS_IN_VAULT);
        assertEq(vault.maxFlashLoan(address(token)), TOKENS_IN_VAULT);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT - 1), 0);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), 50_000 * 10 ** 18);

        // Transfer initial balance to player
        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);
        assertEq(token.balanceOf(player), INITIAL_PLAYER_TOKEN_BALANCE);

        // Deploy receiver contract and execute initial flash loan
        vm.startPrank(someUser);

        // solhint-disable-next-line reentrancy
        receiverContract = new ReceiverUnstoppable(address(vault));
        receiverContract.executeFlashLoan(100 * 10 ** 18);
        vm.stopPrank();
    }

    function _execution() private {
        vm.startPrank(player);

        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.stopPrank();
    }

    function testUnstoppable() public {
        // It is no longer possible to execute flash loans
        _execution();
        vm.prank(someUser);
        vm.expectRevert();
        receiverContract.executeFlashLoan(100 * 10 ** 18);
    }
}
