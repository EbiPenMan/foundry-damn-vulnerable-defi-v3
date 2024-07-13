// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ERC20Snapshot } from "../openzeppelin-contracts-v4/ERC20Snapshot.sol";
import { IERC3156FlashLender } from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import { SimpleGovernance } from "./SimpleGovernance.sol";

/**
 * @title SelfiePool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SelfiePool is ReentrancyGuard, IERC3156FlashLender {
    ERC20Snapshot public immutable TOKEN;
    SimpleGovernance public immutable GOVERNANCE;
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    error RepayFailed();
    error CallerNotGovernance();
    error UnsupportedCurrency();
    error CallbackFailed();

    event FundsDrained(address indexed receiver, uint256 amount);

    modifier onlyGovernance() {
        if (msg.sender != address(GOVERNANCE)) {
            revert CallerNotGovernance();
        }
        _;
    }

    constructor(address _token, address _governance) {
        TOKEN = ERC20Snapshot(_token);
        GOVERNANCE = SimpleGovernance(_governance);
    }

    function maxFlashLoan(address _token) external view returns (uint256) {
        if (address(TOKEN) == _token) {
            return TOKEN.balanceOf(address(this));
        }
        return 0;
    }

    function flashFee(address _token, uint256) external view returns (uint256) {
        if (address(TOKEN) != _token) {
            revert UnsupportedCurrency();
        }
        return 0;
    }

    function flashLoan(
        IERC3156FlashBorrower _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    )
        external
        nonReentrant
        returns (bool)
    {
        if (_token != address(TOKEN)) {
            revert UnsupportedCurrency();
        }

        TOKEN.transfer(address(_receiver), _amount);
        if (_receiver.onFlashLoan(msg.sender, _token, _amount, 0, _data) != CALLBACK_SUCCESS) {
            revert CallbackFailed();
        }

        if (!TOKEN.transferFrom(address(_receiver), address(this), _amount)) {
            revert RepayFailed();
        }

        return true;
    }

    function emergencyExit(address receiver) external onlyGovernance {
        uint256 amount = TOKEN.balanceOf(address(this));
        TOKEN.transfer(receiver, amount);

        emit FundsDrained(receiver, amount);
    }
}
