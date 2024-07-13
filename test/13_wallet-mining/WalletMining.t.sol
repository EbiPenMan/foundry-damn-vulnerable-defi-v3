// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { AuthorizerUpgradeable } from "../../src/13_wallet-mining/AuthorizerUpgradeable.sol";
import { WalletDeployer } from "../../src/13_wallet-mining/WalletDeployer.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract WalletMiningTest is Test {
    address public deployer;
    address public ward;
    address public player;
    DamnValuableToken public token;
    AuthorizerUpgradeable public authorizer;
    WalletDeployer public walletDeployer;
    uint256 public initialWalletDeployerTokenBalance;

    address public constant DEPOSIT_ADDRESS = 0x9B6fb606A9f5789444c17768c6dFCF2f83563801;
    uint256 public constant DEPOSIT_TOKEN_AMOUNT = 20_000_000 * 10 ** 18;

    function setUp() public {
        deployer = address(1);
        ward = address(2);
        player = address(3);

        // Deploy Damn Valuable Token contract
        token = new DamnValuableToken();

        // Deploy authorizer with the corresponding proxy
        address authorizerImpl = address(new AuthorizerUpgradeable());

        address[] memory _wards = new address[](1);
        address[] memory _aims = new address[](1);
        _wards[0] = ward;
        _aims[0] = DEPOSIT_ADDRESS;

        bytes memory data = abi.encodeCall(AuthorizerUpgradeable.init, (deployer, _wards, _aims));
        address proxy = address(new ERC1967Proxy(authorizerImpl, data));
        authorizer = AuthorizerUpgradeable(proxy);

        assertEq(authorizer.owner(), deployer);
        assertTrue(authorizer.can(ward, DEPOSIT_ADDRESS));
        assertFalse(authorizer.can(player, DEPOSIT_ADDRESS));

        // Deploy Safe Deployer contract
        vm.prank(deployer);
        walletDeployer = new WalletDeployer(address(token));
        assertEq(walletDeployer.CHIEF(), deployer);
        assertEq(walletDeployer.GEM(), address(token));

        // Set Authorizer in Safe Deployer
        vm.prank(deployer);
        walletDeployer.rule(address(authorizer));
        assertEq(walletDeployer.mom(), address(authorizer));

        walletDeployer.can(ward, DEPOSIT_ADDRESS);

        // TODO check expectRevert not work on staticcall assembly inline revert
        // vm.expectRevert();
        // walletDeployer.can(player, DEPOSIT_ADDRESS);

        // Fund Safe Deployer with tokens
        initialWalletDeployerTokenBalance = walletDeployer.PAY() * 43;
        token.transfer(address(walletDeployer), initialWalletDeployerTokenBalance);

        // // Ensure these accounts start empty
        assertFalse(isContract(DEPOSIT_ADDRESS));
        assertFalse(isContract(address(walletDeployer.FACT())));
        assertFalse(isContract(address(walletDeployer.COPY())));

        // Deposit large amount of DVT tokens to the deposit address
        token.transfer(DEPOSIT_ADDRESS, DEPOSIT_TOKEN_AMOUNT);

        // Ensure initial balances are set correctly
        assertEq(token.balanceOf(DEPOSIT_ADDRESS), DEPOSIT_TOKEN_AMOUNT);
        assertEq(token.balanceOf(address(walletDeployer)), initialWalletDeployerTokenBalance);
        assertEq(token.balanceOf(player), 0);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testWalletMining() public {
        _execution();

        // SUCCESS CONDITIONS

        assertTrue(isContract(address(walletDeployer.FACT())));
        assertTrue(isContract(address(walletDeployer.COPY())));
        assertTrue(isContract(address(DEPOSIT_ADDRESS)));

        // The deposit address and the Safe Deployer contract must not hold tokens
        assertEq(token.balanceOf(DEPOSIT_ADDRESS), 0);
        assertEq(token.balanceOf(address(walletDeployer)), 0);

        // Player must own all tokens
        assertEq(token.balanceOf(player), initialWalletDeployerTokenBalance + DEPOSIT_TOKEN_AMOUNT);
    }

    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
