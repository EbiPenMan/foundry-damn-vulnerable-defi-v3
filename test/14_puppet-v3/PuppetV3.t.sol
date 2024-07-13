// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "solmate/src/tokens/ERC20.sol";
import { INonfungiblePositionManager } from "../../build-uniswap/v3/INonfungiblePositionManager.sol";

import { IUniswapV3Factory } from "../../build-uniswap/v3/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "../../build-uniswap/v3/IUniswapV3Pool.sol";

import { WETH } from "../../src/WETH.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { PuppetV3Pool } from "../../src/14_puppet-v3/PuppetV3Pool.sol";

contract PuppetV3Test is Test {
    INonfungiblePositionManager public uniswapPositionManager;
    IUniswapV3Factory public uniswapFactory;
    IUniswapV3Pool public uniswapPool;
    DamnValuableToken public token;
    WETH public weth;
    PuppetV3Pool public lendingPool;
    address public deployer;
    address public player;
    uint256 public initialBlockTimestamp;

    // Initial liquidity amounts for Uniswap v3 pool
    uint256 public constant UNISWAP_INITIAL_TOKEN_LIQUIDITY = 100e18;
    uint256 public constant UNISWAP_INITIAL_WETH_LIQUIDITY = 100e18;

    uint256 public constant PLAYER_INITIAL_TOKEN_BALANCE = 110e18;
    uint256 public constant PLAYER_INITIAL_ETH_BALANCE = 1e18;
    uint256 public constant DEPLOYER_INITIAL_ETH_BALANCE = 200e18;

    uint256 public constant LENDING_POOL_INITIAL_TOKEN_BALANCE = 1_000_000e18;

    function setUp() public {
        // Initialize deployer account
        // using private key of account #1 in Anvil's node
        deployer = vm.addr(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        vm.deal(deployer, DEPLOYER_INITIAL_ETH_BALANCE);

        // Initialize player account
        // using private key of account #2 in Anvil's node
        player = vm.addr(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Get a reference to the Uniswap V3 Factory contract
        deployCodeTo("build-uniswap/v3/UniswapV3Factory.json", address(0x1F98431c8aD98523631AE4a59f267346ea31F984));
        uniswapFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

        // Get a reference to WETH9
        vm.prank(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        weth = new WETH();

        // Deployer wraps ETH in WETH
        vm.prank(deployer);
        weth.deposit{ value: UNISWAP_INITIAL_WETH_LIQUIDITY }();
        assertEq(weth.balanceOf(deployer), UNISWAP_INITIAL_WETH_LIQUIDITY);

        // Deploy DVT token. This is the token to be traded against WETH in the Uniswap v3 pool.
        vm.prank(deployer);
        token = new DamnValuableToken();

        // Create the Uniswap v3 pool
        bytes memory uniswapPositionManagerArgs = abi.encode(address(uniswapFactory), address(weth), address(0));
        deployCodeTo(
            "build-uniswap/v3/NonfungiblePositionManager.json",
            uniswapPositionManagerArgs,
            address(0xC36442b4a4522E871399CD717aBDD847Ab11FE88)
        );
        uniswapPositionManager = INonfungiblePositionManager(address(0xC36442b4a4522E871399CD717aBDD847Ab11FE88));
        uint24 fee = 3000; // 0.3%
        address token0 = address(weth);
        address token1 = address(token);
        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);

        uniswapPositionManager.createAndInitializePoolIfNecessary(
            token0, // token0
            token1, // token1
            fee,
            encodePriceSqrt(1, 1)
        );

        address uniswapPoolAddress = uniswapFactory.getPool(address(weth), address(token), fee);
        uniswapPool = IUniswapV3Pool(uniswapPoolAddress);
        uniswapPool.increaseObservationCardinalityNext(40);

        // Deployer adds liquidity at current price to Uniswap V3 exchange

        vm.startPrank(deployer);
        weth.approve(address(uniswapPositionManager), type(uint256).max);
        token.approve(address(uniswapPositionManager), type(uint256).max);

        uint256 amount0Desired = UNISWAP_INITIAL_WETH_LIQUIDITY;
        uint256 amount1Desired = UNISWAP_INITIAL_TOKEN_LIQUIDITY;

        (amount0Desired, amount0Desired) =
            token0 == address(weth) ? (amount0Desired, amount0Desired) : (amount0Desired, amount0Desired);

        uniswapPositionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                tickLower: -60,
                tickUpper: 60,
                fee: fee,
                recipient: deployer,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp * 2
            })
        );

        // Deploy the lending pool
        lendingPool = new PuppetV3Pool(ERC20(address(weth)), ERC20(token), IUniswapV3Pool(uniswapPool));

        // Setup initial token balances of lending pool and player
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), LENDING_POOL_INITIAL_TOKEN_BALANCE);

        // Some time passes
        vm.warp(block.timestamp + 3 days);

        // Ensure oracle in lending pool is working as expected. At this point, DVT/WETH price should be 1:1.
        // To borrow 1 DVT, must deposit 3 ETH
        assertEq(lendingPool.calculateDepositOfWETHRequired(1e18), 3e18);

        // To borrow all DVT in lending pool, user must deposit three times its value
        assertEq(
            lendingPool.calculateDepositOfWETHRequired(LENDING_POOL_INITIAL_TOKEN_BALANCE),
            LENDING_POOL_INITIAL_TOKEN_BALANCE * 3
        );

        // Ensure player doesn't have that much ETH
        assertLt(player.balance, LENDING_POOL_INITIAL_TOKEN_BALANCE * 3);

        // solhint-disable-next-line reentrancy
        initialBlockTimestamp = block.timestamp;
        vm.stopPrank();
    }

    function encodePriceSqrt(uint256 reserve0, uint256 reserve1) internal pure returns (uint160) {
        return uint160(sqrt(uint256(reserve1) * (2 ** 192) / (reserve0)));
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
        assertLt(block.timestamp - initialBlockTimestamp, 115, "Too much time passed");

        // Player has taken all tokens out of the pool
        assertEq(token.balanceOf(address(lendingPool)), 0);
        assertGe(token.balanceOf(player), LENDING_POOL_INITIAL_TOKEN_BALANCE);
    }
}
