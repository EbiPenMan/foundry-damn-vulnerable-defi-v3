// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/DamnValuableToken.sol";
import "../../src/15_abi-smuggling/SelfAuthorizedVault.sol";

contract AbiSmugglingTest is Test {
    address deployer;
    address player;
    address recovery;
    DamnValuableToken token;
    SelfAuthorizedVault vault;

    uint256 constant VAULT_TOKEN_BALANCE = 1000000e18;

    function setUp() public {
        deployer = address(1);
        player = address(2);
        recovery = address(3);

        vm.startPrank(deployer);
        token = new DamnValuableToken();
        vault = new SelfAuthorizedVault();

        // Set permissions
        bytes32 deployerPermission = vault.getActionId(bytes4(0x85fb709d), deployer, address(vault));
        bytes32 playerPermission = vault.getActionId(bytes4(0xd9caed12), player, address(vault));

        bytes32[] memory ids = new bytes32[](2);
        ids[0] = deployerPermission;
        ids[1] = playerPermission;

        vault.setPermissions(ids);

        // Deposit tokens into the vault
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);
        vm.stopPrank();

        assertEq(token.balanceOf(address(vault)), VAULT_TOKEN_BALANCE);
        assertEq(token.balanceOf(player), 0);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testAbiSmuggling() public {
        _execution();

        // SUCCESS CONDITIONS

        // assertEq(token.balanceOf(address(vault)), 0);
        // assertEq(token.balanceOf(player), 0);
        // assertEq(token.balanceOf(recovery), VAULT_TOKEN_BALANCE);
    }
}
