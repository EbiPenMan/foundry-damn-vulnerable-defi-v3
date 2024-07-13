// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

error CallerNotTimelock();
error NewDelayAboveMax();
error NotReadyForExecution(bytes32 operationId);
error InvalidTargetsCount();
error InvalidDataElementsCount();
error InvalidValuesCount();
error OperationAlreadyKnown(bytes32 operationId);
error CallerNotSweeper();
error InvalidWithdrawalAmount();
error InvalidWithdrawalTime();
