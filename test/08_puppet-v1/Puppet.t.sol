// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { PuppetPool } from "../../src/08_puppet-v1/PuppetPool.sol";
import { IUniswapV1Exchange } from "../../build-uniswap/v1/IUniswapV1Exchange.sol";
import { IUniswapV1Factory } from "../../build-uniswap/v1/IUniswapV1Factory.sol";

contract PuppetChallengeTest is Test {
    address public deployer;
    address public player;
    DamnValuableToken internal token;
    IUniswapV1Exchange internal uniswapExchange;
    IUniswapV1Factory internal uniswapFactory;
    PuppetPool internal lendingPool;

    uint256 public constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 ether;
    uint256 public constant UNISWAP_INITIAL_ETH_RESERVE = 10 ether;
    uint256 public constant PLAYER_INITIAL_TOKEN_BALANCE = 1000 ether;
    uint256 public constant PLAYER_INITIAL_ETH_BALANCE = 25 ether;
    uint256 public constant POOL_INITIAL_TOKEN_BALANCE = 100_000 ether;

    function setUp() public {
        deployer = address(this);
        player = address(0x2);

        vm.deal(deployer, 100_000 ether);
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy token to be traded in Uniswap
        token = new DamnValuableToken();

        // Deploy a exchange that will be used as the factory template
        uniswapFactory = IUniswapV1Factory(deployCode("build-uniswap/v1/UniswapV1Factory.json"));
        uniswapExchange = IUniswapV1Exchange(deployCode("build-uniswap/v1/UniswapV1Exchange.json"));
        uniswapFactory.initializeFactory(address(uniswapExchange));

        // Create a new exchange for the token, and retrieve the deployed exchange's address
        uniswapFactory.createExchange(address(token));
        address exchangeAddress = uniswapFactory.getExchange(address(token));
        uniswapExchange = IUniswapV1Exchange(payable(exchangeAddress));

        // Deploy the lending pool
        lendingPool = new PuppetPool(address(token), exchangeAddress);

        // Add initial token and ETH liquidity to the pool
        token.approve(address(uniswapExchange), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapExchange.addLiquidity{ value: UNISWAP_INITIAL_ETH_RESERVE }(
            0, // min_liquidity
            UNISWAP_INITIAL_TOKEN_RESERVE,
            block.timestamp * 2 // deadline
        );

        // Ensure Uniswap exchange is working as expected
        assertEq(
            uniswapExchange.getTokenToEthInputPrice(1 ether),
            calculateTokenToEthInputPrice(1 ether, UNISWAP_INITIAL_TOKEN_RESERVE, UNISWAP_INITIAL_ETH_RESERVE)
        );

        // Setup initial token balances of pool and player accounts
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        // Ensure correct setup of pool. For example, to borrow 1 need to deposit 2
        assertEq(lendingPool.calculateDepositRequired(1 ether), 2 ether);
        assertEq(lendingPool.calculateDepositRequired(POOL_INITIAL_TOKEN_BALANCE), POOL_INITIAL_TOKEN_BALANCE * 2);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testPuppetV1() public {
        _execution();

        // SUCCESS CONDITIONS

        // Player executed a single transaction
        // assertEq(vm.getTransactionCount(player), 1);
        // assertEq(vm.getNonce(player), 1);

        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(address(lendingPool)), 0);
        assertGt(token.balanceOf(player), POOL_INITIAL_TOKEN_BALANCE);
    }

    function calculateTokenToEthInputPrice(
        uint256 tokensSold,
        uint256 tokensInReserve,
        uint256 etherInReserve
    )
        internal
        pure
        returns (uint256)
    {
        return (tokensSold * 997 * etherInReserve) / (tokensInReserve * 1000 + tokensSold * 997);
    }
}
