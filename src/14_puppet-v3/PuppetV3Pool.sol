// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { ERC20 } from "solmate/src/tokens/ERC20.sol";
import { IUniswapV3Pool } from "../../build-uniswap/v3/IUniswapV3Pool.sol";
import { TransferHelper } from "../../build-uniswap/v3/TransferHelper.sol";
import { OracleLibrary } from "../../build-uniswap/v3/OracleLibrary.sol";

/**
 * @title PuppetV3Pool
 * @notice A simple lending pool using Uniswap v3 as TWAP oracle.
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract PuppetV3Pool {
    uint256 public constant DEPOSIT_FACTOR = 3;
    uint32 public constant TWAP_PERIOD = 10 minutes;

    ERC20 public immutable WETH;
    ERC20 public immutable TOKEN;
    IUniswapV3Pool public immutable UNISWAP_V3_POOL;

    mapping(address add => uint256 deposit) public deposits;

    event Borrowed(address indexed borrower, uint256 depositAmount, uint256 borrowAmount);

    constructor(ERC20 _weth, ERC20 _token, IUniswapV3Pool _uniswapV3Pool) {
        WETH = _weth;
        TOKEN = _token;
        UNISWAP_V3_POOL = _uniswapV3Pool;
    }

    /**
     * @notice Allows borrowing `borrowAmount` of tokens by first depositing three times their value in WETH.
     *         Sender must have approved enough WETH in advance.
     *         Calculations assume that WETH and the borrowed token have the same number of decimals.
     * @param borrowAmount amount of tokens the user intends to borrow
     */
    function borrow(uint256 borrowAmount) external {
        // Calculate how much WETH the user must deposit
        uint256 depositOfWETHRequired = calculateDepositOfWETHRequired(borrowAmount);

        // Pull the WETH
        WETH.transferFrom(msg.sender, address(this), depositOfWETHRequired);

        // internal accounting
        deposits[msg.sender] += depositOfWETHRequired;

        TransferHelper.safeTransfer(address(TOKEN), msg.sender, borrowAmount);

        emit Borrowed(msg.sender, depositOfWETHRequired, borrowAmount);
    }

    function calculateDepositOfWETHRequired(uint256 amount) public view returns (uint256) {
        uint256 quote = _getOracleQuote(_toUint128(amount));
        return quote * DEPOSIT_FACTOR;
    }

    function _getOracleQuote(uint128 amount) private view returns (uint256) {
        (int24 arithmeticMeanTick,) = OracleLibrary.consult(address(UNISWAP_V3_POOL), TWAP_PERIOD);
        return OracleLibrary.getQuoteAtTick(
            arithmeticMeanTick,
            amount, // baseAmount
            address(TOKEN), // baseToken
            address(WETH) // quoteToken
        );
    }

    function _toUint128(uint256 amount) private pure returns (uint128 n) {
        require(amount == (n = uint128(amount)), "invalid input");
    }
}
