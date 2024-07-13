// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { TrustfulOracle } from "./TrustfulOracle.sol";
import { DamnValuableNFT } from "../DamnValuableNFT.sol";

/**
 * @title Exchange
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract Exchange is ReentrancyGuard {
    using Address for address payable;

    DamnValuableNFT public immutable TOKEN;
    TrustfulOracle public immutable ORACLE;

    error InvalidPayment();
    error SellerNotOwner(uint256 id);
    error TransferNotApproved();
    error NotEnoughFunds();

    event TokenBought(address indexed buyer, uint256 tokenId, uint256 price);
    event TokenSold(address indexed seller, uint256 tokenId, uint256 price);

    constructor(address _oracle) payable {
        TOKEN = new DamnValuableNFT();
        TOKEN.renounceOwnership();
        ORACLE = TrustfulOracle(_oracle);
    }

    function buyOne() external payable nonReentrant returns (uint256 id) {
        if (msg.value == 0) {
            revert InvalidPayment();
        }

        // Price should be in [wei / NFT]
        uint256 price = ORACLE.getMedianPrice(TOKEN.symbol());
        if (msg.value < price) {
            revert InvalidPayment();
        }

        id = TOKEN.safeMint(msg.sender);
        unchecked {
            payable(msg.sender).sendValue(msg.value - price);
        }

        emit TokenBought(msg.sender, id, price);
    }

    function sellOne(uint256 id) external nonReentrant {
        if (msg.sender != TOKEN.ownerOf(id)) {
            revert SellerNotOwner(id);
        }

        if (TOKEN.getApproved(id) != address(this)) {
            revert TransferNotApproved();
        }

        // Price should be in [wei / NFT]
        uint256 price = ORACLE.getMedianPrice(TOKEN.symbol());
        if (address(this).balance < price) {
            revert NotEnoughFunds();
        }

        TOKEN.transferFrom(msg.sender, address(this), id);
        TOKEN.burn(id);

        payable(msg.sender).sendValue(price);

        emit TokenSold(msg.sender, id, price);
    }

    receive() external payable { }
}
