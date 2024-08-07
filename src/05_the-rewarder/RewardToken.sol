// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { ERC20 } from "../openzeppelin-contracts-v4/ERC20.sol";
import { OwnableRoles } from "solady/src/auth/OwnableRoles.sol";

/**
 * @title RewardToken
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract RewardToken is ERC20, OwnableRoles {
    uint256 public constant MINTER_ROLE = _ROLE_0;

    constructor() ERC20("Reward Token", "RWT") {
        _initializeOwner(msg.sender);
        _grantRoles(msg.sender, MINTER_ROLE);
    }

    function mint(address to, uint256 amount) external onlyRoles(MINTER_ROLE) {
        _mint(to, amount);
    }
}
