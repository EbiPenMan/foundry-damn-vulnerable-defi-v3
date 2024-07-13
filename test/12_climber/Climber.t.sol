// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { ClimberVault } from "../../src/12_climber/ClimberVault.sol";
import { ClimberTimelock } from "../../src/12_climber/ClimberTimelock.sol";
import { CallerNotTimelock } from "../../src/12_climber/ClimberErrors.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ClimberChallengeTest is Test {
    address private deployer;
    address private proposer;
    address private sweeper;
    address private player;
    ClimberVault private vault;
    ClimberTimelock private timelock;
    DamnValuableToken private token;

    uint256 private constant VAULT_TOKEN_BALANCE = 10_000_000 ether;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint64 private constant TIMELOCK_DELAY = 60 * 60;

    function setUp() public {
        deployer = address(this);
        proposer = address(0x1);
        sweeper = address(0x2);
        player = address(0x3);

        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy the vault behind a proxy using the UUPS pattern
        address vaultImpl = address(new ClimberVault());

        bytes memory data = abi.encodeCall(ClimberVault.initialize, (deployer, proposer, sweeper));
        address proxy = address(new ERC1967Proxy(vaultImpl, data));
        vault = ClimberVault(proxy);

        assertEq(vault.getSweeper(), sweeper);
        assertTrue(vault.getLastWithdrawalTimestamp() > 0);
        assertTrue(vault.owner() != address(0));
        assertTrue(vault.owner() != deployer);

        // Instantiate timelock
        address timelockAddress = vault.owner();
        timelock = ClimberTimelock(payable(timelockAddress));

        // Ensure timelock delay is correct and cannot be changed
        assertEq(timelock.delay(), TIMELOCK_DELAY);
        vm.expectRevert(CallerNotTimelock.selector);
        timelock.updateDelay(TIMELOCK_DELAY + 1);

        // Ensure timelock roles are correctly initialized
        assertTrue(timelock.hasRole(keccak256("PROPOSER_ROLE"), proposer));
        assertTrue(timelock.hasRole(keccak256("ADMIN_ROLE"), deployer));
        assertTrue(timelock.hasRole(keccak256("ADMIN_ROLE"), timelockAddress));

        // Deploy token and transfer initial token balance to the vault
        token = new DamnValuableToken();
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testClimber() public {
        _execution();

        // SUCCESS CONDITIONS

        assertEq(token.balanceOf(address(vault)), 0);
        assertEq(token.balanceOf(player), VAULT_TOKEN_BALANCE);
    }
}
