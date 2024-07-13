// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title AuthorizerUpgradeable
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AuthorizerUpgradeable is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    mapping(address usr => mapping(address aim => uint256 allowance)) private wards;

    event Rely(address indexed usr, address aim);

    function init(address owner, address[] memory _wards, address[] memory _aims) external initializer {
        __Ownable_init(owner);
        __UUPSUpgradeable_init();

        for (uint256 i = 0; i < _wards.length;) {
            _rely(_wards[i], _aims[i]);
            unchecked {
                i++;
            }
        }
    }

    function _rely(address usr, address aim) private {
        wards[usr][aim] = 1;
        emit Rely(usr, aim);
    }

    function can(address usr, address aim) external view returns (bool) {
        return wards[usr][aim] == 1;
    }

    // function upgradeToAndCall(address imp, bytes memory wat) external payable override {
    //     _authorizeUpgrade(imp);
    //     super.upgradeToAndCall(imp, wat);
    // }

    function _authorizeUpgrade(address imp) internal override onlyOwner { }
}
