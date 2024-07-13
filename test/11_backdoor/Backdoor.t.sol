// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { GnosisSafe } from "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import { GnosisSafeProxyFactory } from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { WalletRegistry } from "../../src/11_backdoor/WalletRegistry.sol";

contract BackdoorChallengeTest is Test {
    address private deployer;
    address private player;
    address[] private users;
    GnosisSafe private masterCopy;
    GnosisSafeProxyFactory private walletFactory;
    DamnValuableToken private token;
    WalletRegistry private walletRegistry;

    uint256 private constant AMOUNT_TOKENS_DISTRIBUTED = 40 ether;

    function setUp() public {
        deployer = address(this);
        player = address(0x1);
        address alice = address(0x2);
        address bob = address(0x3);
        address charlie = address(0x4);
        address david = address(0x5);
        users = [alice, bob, charlie, david];

        // Deploy Gnosis Safe master copy and factory contracts
        masterCopy = new GnosisSafe();
        walletFactory = new GnosisSafeProxyFactory();
        token = new DamnValuableToken();

        // Deploy the registry
        walletRegistry = new WalletRegistry(address(masterCopy), address(walletFactory), address(token), users);
        assertEq(walletRegistry.owner(), deployer);

        for (uint256 i = 0; i < users.length; i++) {
            // Users are registered as beneficiaries
            assertTrue(walletRegistry.beneficiaries(users[i]));

            // User cannot add beneficiaries
            vm.prank(users[i]);
            vm.expectRevert(0x82b42900); // `Unauthorized()`
            walletRegistry.addBeneficiary(users[i]);
        }

        // Transfer tokens to be distributed to the registry
        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testBackdoor() public {
        _execution();

        // SUCCESS CONDITIONS
        assertEq(vm.getNonce(player), 1);

        for (uint256 i = 0; i < users.length; i++) {
            address wallet = walletRegistry.wallets(users[i]);

            // User must have registered a wallet
            assertTrue(wallet != address(0), "User did not register a wallet");

            // User is no longer registered as a beneficiary
            assertFalse(walletRegistry.beneficiaries(users[i]));
        }

        // Player must own all tokens
        assertEq(token.balanceOf(player), AMOUNT_TOKENS_DISTRIBUTED);
    }
}
