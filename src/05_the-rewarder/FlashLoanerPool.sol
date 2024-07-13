// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { DamnValuableToken } from "../DamnValuableToken.sol";

/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 * @dev A simple pool to get flashloans of DVT
 */
contract FlashLoanerPool is ReentrancyGuard {
    using Address for address;

    DamnValuableToken public immutable LIQUIDITY_TOKEN;

    error NotEnoughTokenBalance();
    error CallerIsNotContract();
    error FlashLoanNotPaidBack();

    constructor(address liquidityTokenAddress) {
        LIQUIDITY_TOKEN = DamnValuableToken(liquidityTokenAddress);
    }

    function flashLoan(uint256 amount) external nonReentrant {
        uint256 balanceBefore = LIQUIDITY_TOKEN.balanceOf(address(this));

        if (amount > balanceBefore) {
            revert NotEnoughTokenBalance();
        }

        if (!_isContract(msg.sender)) {
            revert CallerIsNotContract();
        }

        LIQUIDITY_TOKEN.transfer(msg.sender, amount);

        msg.sender.functionCall(abi.encodeWithSignature("receiveFlashLoan(uint256)", amount));

        if (LIQUIDITY_TOKEN.balanceOf(address(this)) < balanceBefore) {
            revert FlashLoanNotPaidBack();
        }
    }

    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
