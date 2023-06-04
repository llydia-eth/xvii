//SPDX-License-Identifier: UNLICENSED
//llydia cross 2021
pragma solidity ^0.8.0;

import './InfinityMintValues.sol';

/// @title InfinityMint Random Number Abstract Contract
/// @author Llydia Cross
abstract contract RandomNumber {
    uint256 public randomnessFactor;
    bool public hasDeployed = false;
    uint256 public salt = 1;

    InfinityMintValues internal valuesController;

    constructor(address valuesContract) {
        valuesController = InfinityMintValues(valuesContract);
        randomnessFactor = valuesController.tryGetValue('randomessFactor');
    }

    function getNumber() external returns (uint256) {
        unchecked {
            ++salt;
        }

        return
            unsafeNumber(valuesController.tryGetValue('maxRandomNumber'), salt);
    }

    function getMaxNumber(uint256 maxNumber) external returns (uint256) {
        unchecked {
            ++salt;
        }

        return unsafeNumber(maxNumber, salt);
    }

    /// @notice cheap return number
    function unsafeNumber(uint256 maxNumber, uint256 _salt)
        public
        view
        virtual
        returns (uint256)
    {
        if (maxNumber <= 0) maxNumber = 1;
        return (_salt + salt + block.timestamp) % maxNumber;
    }
}
