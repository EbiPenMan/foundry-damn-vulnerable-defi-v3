// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/DamnValuableToken.sol";
import "../../src/01_unstoppable/UnstoppableVault.sol";
import "../../src/01_unstoppable/ReceiverUnstoppable.sol";
import {ERC4626, ERC20} from "solmate/src/tokens/ERC4626.sol";

contract Unstoppable is Test {
    DamnValuableToken token;
    UnstoppableVault vault;
    ReceiverUnstoppable receiverContract;
    address deployer;
    address player;
    address someUser;

    uint256 constant TOKENS_IN_VAULT = 1000000 * 10 ** 18;
    uint256 constant INITIAL_PLAYER_TOKEN_BALANCE = 10 * 10 ** 18;

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
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), 50000 * 10 ** 18);

        // Transfer initial balance to player
        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);
        assertEq(token.balanceOf(player), INITIAL_PLAYER_TOKEN_BALANCE);

        // Deploy receiver contract and execute initial flash loan
        vm.startPrank(someUser);
        receiverContract = new ReceiverUnstoppable(address(vault));
        receiverContract.executeFlashLoan(100 * 10 ** 18);
        vm.stopPrank();
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testUnstoppable() public {
        // It is no longer possible to execute flash loans
        _execution();
        vm.prank(someUser);
        vm.expectRevert();
        receiverContract.executeFlashLoan(100 * 10 ** 18);
    }
}
