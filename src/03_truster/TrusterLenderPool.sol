// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { DamnValuableToken } from "../DamnValuableToken.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterLenderPool is ReentrancyGuard {
    using Address for address;

    DamnValuableToken public immutable TOKEN;

    error RepayFailed();

    constructor(DamnValuableToken _token) {
        TOKEN = _token;
    }

    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    )
        external
        nonReentrant
        returns (bool)
    {
        uint256 balanceBefore = TOKEN.balanceOf(address(this));

        TOKEN.transfer(borrower, amount);
        target.functionCall(data);

        if (TOKEN.balanceOf(address(this)) < balanceBefore) {
            revert RepayFailed();
        }

        return true;
    }
}
