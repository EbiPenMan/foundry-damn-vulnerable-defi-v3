// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { DamnValuableNFT } from "../../src/DamnValuableNFT.sol";
import { TrustfulOracle } from "../../src/07_compromised/TrustfulOracle.sol";
import { TrustfulOracleInitializer } from "../../src/07_compromised/TrustfulOracleInitializer.sol";
import { Exchange } from "../../src/07_compromised/Exchange.sol";

contract Compromised is Test {
    address public deployer;
    address public player;
    address[] public sources = [
        address(0xA73209FB1a42495120166736362A1DfA9F95A105),
        address(0xe92401A4d3af5E446d93D11EEc806b1462b39D15),
        address(0x81A5D6E50C214044bE44cA0CB057fe119097850c)
    ];

    uint256 public constant EXCHANGE_INITIAL_ETH_BALANCE = 999 ether;
    uint256 public constant INITIAL_NFT_PRICE = 999 ether;
    uint256 public constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 public constant TRUSTED_SOURCE_INITIAL_ETH_BALANCE = 2 ether;

    TrustfulOracle internal oracle;
    Exchange internal exchange;
    DamnValuableNFT internal nftToken;

    function setUp() public {
        deployer = address(this);
        player = address(0x2);

        vm.deal(deployer, 10_000 ether);
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);

        // Initialize balance of the trusted source addresses
        for (uint256 i = 0; i < sources.length; i++) {
            vm.deal(sources[i], TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
            assertEq(sources[i].balance, TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
        }

        string[] memory symbols = new string[](3);
        uint256[] memory initialPrices = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            symbols[i] = "DVNFT";
            initialPrices[i] = INITIAL_NFT_PRICE;
        }

        // Deploy the oracle and setup the trusted sources with initial prices
        TrustfulOracleInitializer oracleInitializer = new TrustfulOracleInitializer(sources, symbols, initialPrices);
        oracle = TrustfulOracle(address(oracleInitializer.oracle()));

        // Deploy the exchange and get an instance to the associated ERC721 token
        exchange = new Exchange{ value: EXCHANGE_INITIAL_ETH_BALANCE }(address(oracle));
        nftToken = DamnValuableNFT(exchange.TOKEN());
        assertEq(nftToken.owner(), address(0)); // ownership renounced
        assertEq(nftToken.rolesOf(address(exchange)), nftToken.MINTER_ROLE());
    }

    function _execution() private {
        /**
         * CODE YOUR SOLUTION HERE
         */
    }

    function testCompromised() public {
        _execution();

        // SUCCESS CONDITIONS

        // Exchange must have lost all ETH
        assertEq(address(exchange).balance, 0);

        // Player's ETH balance must have significantly increased
        assertGt(player.balance, EXCHANGE_INITIAL_ETH_BALANCE);

        // Player must not own any NFT
        assertEq(nftToken.balanceOf(player), 0);

        // NFT price shouldn't have changed
        assertEq(oracle.getMedianPrice("DVNFT"), INITIAL_NFT_PRICE);
    }
}
