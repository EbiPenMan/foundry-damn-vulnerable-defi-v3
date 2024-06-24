// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/DamnValuableToken.sol";
import "../../src/09_puppet-v2/PuppetV2Pool.sol";
import "../../src/WETH.sol";
import "../../build-uniswap/v2/IUniswapV2Pair.sol";
import "../../build-uniswap/v2/IUniswapV2Factory.sol";
import "../../build-uniswap/v2/IUniswapV2Router02.sol";

contract PuppetV2ChallengeTest is Test {
    address deployer;
    address player;
    DamnValuableToken internal token;
    WETH internal weth;
    IUniswapV2Factory internal uniswapFactory;
    IUniswapV2Router02 internal uniswapRouter;
    IUniswapV2Pair internal uniswapExchange;
    PuppetV2Pool internal lendingPool;

    uint256 constant UNISWAP_INITIAL_TOKEN_RESERVE = 100 ether;
    uint256 constant UNISWAP_INITIAL_WETH_RESERVE = 10 ether;
    uint256 constant PLAYER_INITIAL_TOKEN_BALANCE = 10000 ether;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 20 ether;
    uint256 constant POOL_INITIAL_TOKEN_BALANCE = 1000000 ether;

    function setUp() public {
        deployer = payable(address(this));
        player = payable(address(0x2));

        vm.deal(deployer, 100000 ether);
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy tokens to be traded
        token = new DamnValuableToken();
        weth = new WETH();

        // Deploy Uniswap Factory and Router
        bytes memory v2FactoryArgs = abi.encode(address(0));
        uniswapFactory = IUniswapV2Factory(deployBytecodeWithArgs("UniswapV2Factory.json",v2FactoryArgs));

        bytes memory v2Router02Args = abi.encode(address(uniswapFactory), address(weth));
        uniswapRouter = IUniswapV2Router02(deployBytecodeWithArgs("UniswapV2Router02.json",v2Router02Args));

        // Create Uniswap pair against WETH and add liquidity
        token.approve(address(uniswapRouter), UNISWAP_INITIAL_TOKEN_RESERVE);
        // uniswapRouter.addLiquidityETH{value: UNISWAP_INITIAL_WETH_RESERVE}(
        //     address(token),
        //     UNISWAP_INITIAL_TOKEN_RESERVE, // amountTokenDesired
        //     0, // amountTokenMin
        //     0, // amountETHMin
        //     deployer, // to
        //     block.timestamp * 2 // deadline
        // );
        // address pairAddress = uniswapFactory.getPair(address(token), address(weth));
        // uniswapExchange = IUniswapV2Pair(pairAddress);

        // // Deploy the lending pool
        // lendingPool = new PuppetV2Pool(address(weth), address(token), pairAddress, address(uniswapFactory));

        // // Setup initial token balances of pool and player accounts
        // token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        // token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        // // Check pool's been correctly setup
        // assertEq(lendingPool.calculateDepositOfWETHRequired(1 ether), 0.3 ether);
        // assertEq(lendingPool.calculateDepositOfWETHRequired(POOL_INITIAL_TOKEN_BALANCE), 300000 ether);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testPuppetV2() public {
        _execution();

        // SUCCESS CONDITIONS

        // Player has taken all tokens from the pool
        // assertEq(token.balanceOf(address(lendingPool)), 0);
        // assertGt(token.balanceOf(player), POOL_INITIAL_TOKEN_BALANCE);
    }

    function deployBytecode(string memory fileName) public returns (address contractAddress) {
        // Load the bytecode from JSON file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/build-uniswap/v2/", fileName);
        string memory json = vm.readFile(path);

        // Parse bytecode
        bytes memory bytecode = stdJson.readBytes(json, ".evm.bytecode.object");

        assembly {
            contractAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            // if iszero(extcodesize(contractAddress)) {
            //     returndatacopy(0, 0, returndatasize())
            //     revert(0, returndatasize())
            // }
        }
        require(contractAddress != address(0), "Deployment failed");
    }

    function deployBytecodeWithArgs(string memory fileName, bytes memory constructorArgs)
        public
        returns (address contractAddress)
    {
        // Load the bytecode from JSON file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/build-uniswap/v2/", fileName);
        string memory json = vm.readFile(path);

        // Parse bytecode
        bytes memory bytecode = stdJson.readBytes(json, ".evm.bytecode.object");

        // Combine bytecode and constructorArgs
        bytes memory bytecodeWithArgs = abi.encodePacked(bytecode, constructorArgs);

        assembly {
            contractAddress := create(0, add(bytecode, 0x20), mload(bytecodeWithArgs))
            // if iszero(extcodesize(contractAddress)) {
            //     returndatacopy(0, 0, returndatasize())
            //     revert(0, returndatasize())
            // }
        }
        require(contractAddress != address(0), "Deployment failed");
    }
}
