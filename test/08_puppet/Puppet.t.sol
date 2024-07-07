// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/StdJson.sol";
import "../../src/DamnValuableToken.sol";
import "../../src/08_puppet/PuppetPool.sol";
import "../../build-uniswap/v1/IUniswapV1Exchange.sol";
import "../../build-uniswap/v1/IUniswapV1Factory.sol";

contract PuppetChallengeTest is Test {
    address deployer;
    address player;
    DamnValuableToken internal token;
    IUniswapV1Exchange internal uniswapExchange;
    IUniswapV1Factory internal uniswapFactory;
    PuppetPool internal lendingPool;

    uint256 constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 ether;
    uint256 constant UNISWAP_INITIAL_ETH_RESERVE = 10 ether;
    uint256 constant PLAYER_INITIAL_TOKEN_BALANCE = 1000 ether;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 25 ether;
    uint256 constant POOL_INITIAL_TOKEN_BALANCE = 100000 ether;

    function setUp() public {
        deployer = address(this);
        player = address(0x2);

        vm.deal(deployer, 100000 ether);
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy token to be traded in Uniswap
        token = new DamnValuableToken();

        // Deploy a exchange that will be used as the factory template
        uniswapFactory = IUniswapV1Factory(deployBytecode("UniswapV1Factory.json"));
        uniswapExchange = IUniswapV1Exchange(deployBytecode("UniswapV1Exchange.json"));
        uniswapFactory.initializeFactory(address(uniswapExchange));

        // Create a new exchange for the token, and retrieve the deployed exchange's address
        uniswapFactory.createExchange(address(token));
        address exchangeAddress = uniswapFactory.getExchange(address(token));
        uniswapExchange = IUniswapV1Exchange(payable(exchangeAddress));

        // Deploy the lending pool
        lendingPool = new PuppetPool(address(token), exchangeAddress);

        // Add initial token and ETH liquidity to the pool
        token.approve(address(uniswapExchange), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapExchange.addLiquidity{value: UNISWAP_INITIAL_ETH_RESERVE}(
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

    function testPuppet() public {
        _execution();

        // SUCCESS CONDITIONS

        // Player executed a single transaction
        // assertEq(vm.getTransactionCount(player), 1);
        assertEq(vm.getNonce(player), 1);
        

        // Player has taken all tokens from the pool
        assertEq(token.balanceOf(address(lendingPool)), 0);
        assertGt(token.balanceOf(player), POOL_INITIAL_TOKEN_BALANCE);
    }

    function calculateTokenToEthInputPrice(uint256 tokensSold, uint256 tokensInReserve, uint256 etherInReserve)
        internal
        pure
        returns (uint256)
    {
        return (tokensSold * 997 * etherInReserve) / (tokensInReserve * 1000 + tokensSold * 997);
    }

    function deployBytecode(string memory fileName) public returns (address contractAddress) {
        // Load the bytecode from JSON file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/build-uniswap/v1/", fileName);
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
}
