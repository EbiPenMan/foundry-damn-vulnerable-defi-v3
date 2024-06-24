// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import "../../build-uniswap/v3/INonfungiblePositionManager.sol";

import "../../build-uniswap/v3/IUniswapV3Factory.sol";
import "../../build-uniswap/v3/IUniswapV3Pool.sol";

import "../../src/WETH.sol";
import "../../src/DamnValuableToken.sol";
import "../../src/14_puppet-v3/PuppetV3Pool.sol";

contract PuppetV3Test is Test {
    INonfungiblePositionManager uniswapPositionManager;
    IUniswapV3Factory uniswapFactory;
    IUniswapV3Pool uniswapPool;
    DamnValuableToken token;
    WETH weth;
    PuppetV3Pool lendingPool;
    address deployer;
    address player;
    uint256 initialBlockTimestamp;

    // Initial liquidity amounts for Uniswap v3 pool
    uint256 constant UNISWAP_INITIAL_TOKEN_LIQUIDITY = 100e18;
    uint256 constant UNISWAP_INITIAL_WETH_LIQUIDITY = 100e18;

    uint256 constant PLAYER_INITIAL_TOKEN_BALANCE = 110e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 1e18;
    uint256 constant DEPLOYER_INITIAL_ETH_BALANCE = 200e18;

    uint256 constant LENDING_POOL_INITIAL_TOKEN_BALANCE = 1000000e18;

    function setUp() public {
        // Fork from mainnet state
        string memory MAINNET_FORKING_URL = "";
        vm.createFork(MAINNET_FORKING_URL);
        vm.selectFork(0);
        vm.rollFork(15450164);

        // Initialize player account
        player = vm.addr(2);
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Initialize deployer account
        deployer = vm.addr(1);
        vm.deal(deployer, DEPLOYER_INITIAL_ETH_BALANCE);

        // Get a reference to the Uniswap V3 Factory contract
        uniswapFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

        // Get a reference to WETH9
        weth = new WETH();

        // Deployer wraps ETH in WETH
        weth.deposit{value: UNISWAP_INITIAL_WETH_LIQUIDITY}();
        assertEq(weth.balanceOf(deployer), UNISWAP_INITIAL_WETH_LIQUIDITY);

        // Deploy DVT token. This is the token to be traded against WETH in the Uniswap v3 pool.
        token = new DamnValuableToken();

        // Create the Uniswap v3 pool
        uniswapPositionManager = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
        uint24 FEE = 3000; // 0.3%
        uniswapPositionManager.createAndInitializePoolIfNecessary(
            address(weth),  // token0
            address(token), // token1
            FEE,
            encodePriceSqrt(1, 1)
        );

        address uniswapPoolAddress = uniswapFactory.getPool(
            address(weth),
            address(token),
            FEE
        );
        uniswapPool = IUniswapV3Pool(uniswapPoolAddress);
        uniswapPool.increaseObservationCardinalityNext(40);

        // Deployer adds liquidity at current price to Uniswap V3 exchange
        weth.approve(address(uniswapPositionManager), type(uint256).max);
        token.approve(address(uniswapPositionManager), type(uint256).max);
        uniswapPositionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(weth),
                token1: address(token),
                tickLower: -60,
                tickUpper: 60,
                fee: FEE,
                recipient: deployer,
                amount0Desired: UNISWAP_INITIAL_WETH_LIQUIDITY,
                amount1Desired: UNISWAP_INITIAL_TOKEN_LIQUIDITY,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp * 2
            })
        );

        // Deploy the lending pool
        lendingPool = new PuppetV3Pool(
            ERC20(address(weth)),
            ERC20(token),
            IUniswapV3Pool(uniswapPool)
        );

        // Setup initial token balances of lending pool and player
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), LENDING_POOL_INITIAL_TOKEN_BALANCE);

        // Some time passes
        vm.warp(block.timestamp + 3 days);

        // Ensure oracle in lending pool is working as expected. At this point, DVT/WETH price should be 1:1.
        // To borrow 1 DVT, must deposit 3 ETH
        assertEq(
            lendingPool.calculateDepositOfWETHRequired(1e18),
            3e18
        );

        // To borrow all DVT in lending pool, user must deposit three times its value
        assertEq(
            lendingPool.calculateDepositOfWETHRequired(LENDING_POOL_INITIAL_TOKEN_BALANCE),
            LENDING_POOL_INITIAL_TOKEN_BALANCE * 3
        );

        // Ensure player doesn't have that much ETH
        assertLt(player.balance, LENDING_POOL_INITIAL_TOKEN_BALANCE * 3);

        initialBlockTimestamp = block.timestamp;
    }

    function encodePriceSqrt(uint256 reserve0, uint256 reserve1) internal pure returns (uint160) {
        return uint160(
            sqrt(
                uint256(reserve1) * (2**192) / (reserve0)
            )
        );
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testPuppetV3() public {
        _execution();

        // SUCCESS CONDITIONS

        // Block timestamp must not have changed too much
        // assertLt(block.timestamp - initialBlockTimestamp, 115, "Too much time passed");

        // // Player has taken all tokens out of the pool        
        // assertEq(
        //     token.balanceOf(address(lendingPool)),
        //     0
        // );
        // assertGe(
        //     token.balanceOf(player),
        //     LENDING_POOL_INITIAL_TOKEN_BALANCE
        // );
    }
}
