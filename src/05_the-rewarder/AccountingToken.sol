// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { ERC20Snapshot, ERC20 } from "../openzeppelin-contracts-v4/ERC20Snapshot.sol";
import { OwnableRoles } from "solady/src/auth/OwnableRoles.sol";

/**
 * @title AccountingToken
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 * @notice A limited pseudo-ERC20 token to keep track of deposits and withdrawals
 *         with snapshotting capabilities.
 */
contract AccountingToken is ERC20Snapshot, OwnableRoles {
    uint256 public constant MINTER_ROLE = _ROLE_0;
    uint256 public constant SNAPSHOT_ROLE = _ROLE_1;
    uint256 public constant BURNER_ROLE = _ROLE_2;

    error NotImplemented();

    constructor() ERC20("rToken", "rTKN") {
        _initializeOwner(msg.sender);
        _grantRoles(msg.sender, MINTER_ROLE | SNAPSHOT_ROLE | BURNER_ROLE);
    }

    function mint(address to, uint256 amount) external onlyRoles(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRoles(BURNER_ROLE) {
        _burn(from, amount);
    }

    function snapshot() external onlyRoles(SNAPSHOT_ROLE) returns (uint256) {
        return _snapshot();
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert NotImplemented();
    }

    function approve(address, uint256) public pure override returns (bool) {
        revert NotImplemented();
    }
}
