// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/WETH.sol";
import "../../build-uniswap/v2/IUniswapV2Pair.sol";
import "../../build-uniswap/v2/IUniswapV2Factory.sol";
import "../../build-uniswap/v2/IUniswapV2Router02.sol";
import "../../src/10_free-rider/FreeRiderNFTMarketplace.sol";
import "../../src/10_free-rider/FreeRiderRecovery.sol";
import "../../src/DamnValuableToken.sol";
import "../../src/DamnValuableNFT.sol";

contract FreeRiderChallengeTest is Test {
    address private deployer;
    address private player;
    address private devs;
    WETH private weth;
    DamnValuableToken private token;
    IUniswapV2Factory private uniswapFactory;
    IUniswapV2Router02 private uniswapRouter;
    IUniswapV2Pair private uniswapPair;
    FreeRiderNFTMarketplace private marketplace;
    DamnValuableNFT private nft;
    FreeRiderRecovery private devsContract;

    // The NFT marketplace will have 6 tokens, at 15 ETH each
    uint256 private constant NFT_PRICE = 15 ether;
    uint256 private constant AMOUNT_OF_NFTS = 6;
    uint256 private constant MARKETPLACE_INITIAL_ETH_BALANCE = 90 ether;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 private constant BOUNTY = 45 ether;
    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 15000 ether;
    uint256 private constant UNISWAP_INITIAL_WETH_RESERVE = 9000 ether;

    function setUp() public {
        deployer = address(this);
        player = address(0x1);
        devs = address(0x2);

        // Player starts with limited ETH balance
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        assertEq(player.balance, PLAYER_INITIAL_ETH_BALANCE);

        // Deploy WETH
        weth = new WETH();

        // Deploy token to be traded against WETH in Uniswap v2
        token = new DamnValuableToken();

        // Deploy Uniswap Factory and Router
        uniswapFactory = IUniswapV2Factory(deployBytecodeWithArgs("UniswapV2Factory.json", abi.encode(address(0))));
        uniswapRouter = IUniswapV2Router02(deployBytecodeWithArgs("UniswapV2Router02.json", abi.encode(address(uniswapFactory), address(weth))));

        // Approve tokens, and then create Uniswap v2 pair against WETH and add liquidity
        token.approve(address(uniswapRouter), UNISWAP_INITIAL_TOKEN_RESERVE);

        //TODO

        // uniswapRouter.addLiquidityETH{value: UNISWAP_INITIAL_WETH_RESERVE}(
        //     address(token),                                          // token to be traded against WETH
        //     UNISWAP_INITIAL_TOKEN_RESERVE,                           // amountTokenDesired
        //     0,                                                      // amountTokenMin
        //     0,                                                      // amountETHMin
        //     deployer,                                               // to
        //     block.timestamp * 2                                      // deadline
        // );

        // Get a reference to the created Uniswap pair
        // address pair = uniswapFactory.getPair(address(token), address(weth));
        // uniswapPair = IUniswapV2Pair(pair);
        // assertEq(uniswapPair.token0(), address(weth));
        // assertEq(uniswapPair.token1(), address(token));
        // assertGt(uniswapPair.balanceOf(deployer), 0);

        // // Deploy the marketplace and get the associated ERC721 token
        // // The marketplace will automatically mint AMOUNT_OF_NFTS to the deployer
        // marketplace = new FreeRiderNFTMarketplace(AMOUNT_OF_NFTS);
        // payable(address(marketplace)).transfer(MARKETPLACE_INITIAL_ETH_BALANCE);

        // // Deploy NFT contract
        // nft = DamnValuableNFT(address(marketplace.token()));
        // assertEq(nft.owner(), address(0)); // ownership renounced
        // assertEq(nft.rolesOf(address(marketplace)), nft.MINTER_ROLE());

        // // Ensure deployer owns all minted NFTs. Then approve the marketplace to trade them.
        // for (uint256 id = 0; id < AMOUNT_OF_NFTS; id++) {
        //     assertEq(nft.ownerOf(id), deployer);
        // }
        // nft.setApprovalForAll(address(marketplace), true);

        // // Open offers in the marketplace
        // uint256[] memory ids = new uint256[](AMOUNT_OF_NFTS);
        // uint256[] memory prices = new uint256[](AMOUNT_OF_NFTS);
        // for (uint256 i = 0; i < AMOUNT_OF_NFTS; i++) {
        //     ids[i] = i;
        //     prices[i] = NFT_PRICE;
        // }
        // marketplace.offerMany(ids, prices);
        // assertEq(marketplace.offersCount(), 6);

        // // Deploy devs' contract, adding the player as the beneficiary
        // devsContract = new FreeRiderRecovery(player, address(nft));
        // payable(address(devsContract)).transfer(BOUNTY);
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testFreeRider() public {
        _execution();

        // SUCCESS CONDITIONS

        // for (uint256 tokenId = 0; tokenId < AMOUNT_OF_NFTS; tokenId++) {
        //     nft.transferFrom(address(devsContract), devs, tokenId);
        //     assertEq(nft.ownerOf(tokenId), devs);
        // }

        // assertEq(marketplace.offersCount(), 0);
        // assertLt(address(marketplace).balance, MARKETPLACE_INITIAL_ETH_BALANCE);
        // assertGt(player.balance, BOUNTY);
        // assertEq(address(devsContract).balance, 0);
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
