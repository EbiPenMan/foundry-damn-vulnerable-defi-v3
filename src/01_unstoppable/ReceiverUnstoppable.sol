// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import { Owned } from "solmate/src/auth/Owned.sol";
import { UnstoppableVault, ERC20 } from "../01_unstoppable/UnstoppableVault.sol";

/**
 * @title ReceiverUnstoppable
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract ReceiverUnstoppable is Owned, IERC3156FlashBorrower {
    UnstoppableVault private immutable POOL;

    error UnexpectedFlashLoan();

    constructor(address poolAddress) Owned(msg.sender) {
        POOL = UnstoppableVault(poolAddress);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata
    )
        external
        returns (bytes32)
    {
        if (initiator != address(this) || msg.sender != address(POOL) || token != address(POOL.asset()) || fee != 0) {
            revert UnexpectedFlashLoan();
        }

        ERC20(token).approve(address(POOL), amount);

        return keccak256("IERC3156FlashBorrower.onFlashLoan");
    }

    function executeFlashLoan(uint256 amount) external onlyOwner {
        address asset = address(POOL.asset());
        POOL.flashLoan(this, asset, amount, bytes(""));
    }
}
