// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { FixedPointMathLib } from "solady/src/utils/FixedPointMathLib.sol";
import { SafeTransferLib } from "solady/src/utils/SafeTransferLib.sol";
import { RewardToken } from "./RewardToken.sol";
import { AccountingToken } from "./AccountingToken.sol";

/**
 * @title TheRewarderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TheRewarderPool {
    using FixedPointMathLib for uint256;

    // Minimum duration of each round of rewards in seconds
    uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;

    uint256 public constant REWARDS = 100 ether;

    // Token deposited into the pool by users
    address public immutable LIQUIDITY_TOKEN;

    // Token used for internal accounting and snapshots
    // Pegged 1:1 with the liquidity token
    AccountingToken public immutable ACCOUNTING_TOKEN;

    // Token in which rewards are issued
    RewardToken public immutable REWARD_TOKEN;

    uint128 public lastSnapshotIdForRewards;
    uint64 public lastRecordedSnapshotTimestamp;
    uint64 public roundNumber; // Track number of rounds
    mapping(address key => uint64 timestampValue) public lastRewardTimestamps;

    error InvalidDepositAmount();

    constructor(address _token) {
        // Assuming all tokens have 18 decimals
        LIQUIDITY_TOKEN = _token;
        ACCOUNTING_TOKEN = new AccountingToken();
        REWARD_TOKEN = new RewardToken();

        _recordSnapshot();
    }

    /**
     * @notice Deposit `amount` liquidity tokens into the pool, minting accounting tokens in exchange.
     *         Also distributes rewards if available.
     * @param amount amount of tokens to be deposited
     */
    function deposit(uint256 amount) external {
        if (amount == 0) {
            revert InvalidDepositAmount();
        }

        ACCOUNTING_TOKEN.mint(msg.sender, amount);
        distributeRewards();

        SafeTransferLib.safeTransferFrom(LIQUIDITY_TOKEN, msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external {
        ACCOUNTING_TOKEN.burn(msg.sender, amount);
        SafeTransferLib.safeTransfer(LIQUIDITY_TOKEN, msg.sender, amount);
    }

    function distributeRewards() public returns (uint256 rewards) {
        if (isNewRewardsRound()) {
            _recordSnapshot();
        }

        uint256 totalDeposits = ACCOUNTING_TOKEN.totalSupplyAt(lastSnapshotIdForRewards);
        uint256 amountDeposited = ACCOUNTING_TOKEN.balanceOfAt(msg.sender, lastSnapshotIdForRewards);

        if (amountDeposited > 0 && totalDeposits > 0) {
            rewards = amountDeposited.mulDiv(REWARDS, totalDeposits);
            if (rewards > 0 && !_hasRetrievedReward(msg.sender)) {
                REWARD_TOKEN.mint(msg.sender, rewards);
                lastRewardTimestamps[msg.sender] = uint64(block.timestamp);
            }
        }
    }

    function _recordSnapshot() private {
        lastSnapshotIdForRewards = uint128(ACCOUNTING_TOKEN.snapshot());
        lastRecordedSnapshotTimestamp = uint64(block.timestamp);
        unchecked {
            ++roundNumber;
        }
    }

    function _hasRetrievedReward(address account) private view returns (bool) {
        return (
            lastRewardTimestamps[account] >= lastRecordedSnapshotTimestamp
                && lastRewardTimestamps[account] <= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION
        );
    }

    function isNewRewardsRound() public view returns (bool) {
        return block.timestamp >= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION;
    }
}
