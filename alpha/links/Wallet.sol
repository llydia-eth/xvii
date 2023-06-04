//SPDX-License-Identifier: UNLICENSED
//llydia cross 2021
pragma solidity ^0.8.0;

import './IWallet.sol';
import '../Authentication.sol';

contract Wallet is Authentication, IWallet, InfinityMintObject {
    /// @notice the value/balance of the current smart wallet
    uint256 private balance;

    /// @notice Fired when a deposit is made
    event Deposit(address indexed sender, uint256 amount, uint256 newTotal);
    /// @notice Fired with a withdraw is made
    event Withdraw(address indexed sender, uint256 amount, uint256 newTotal);
    /// @notice Fired with a transfer to another address is made
    event Transfer(address indexed sender, uint256 amount, uint256 newTotal);

    /// @notice Opts in this contract to receipt ERC721
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure virtual returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice Allows anyone to pay this contract address directly
    receive() external payable {
        balance += value();
        emit Deposit(sender(), value(), balance);
    }

    function staticCall(
        address to,
        bytes calldata data
    ) external view onlyApproved returns (bool, bytes memory) {
        return to.staticcall(data);
    }

    function delegateCall(
        address to,
        bytes calldata data
    ) external onlyDeployer onlyOnce returns (bool, bytes memory) {
        return to.delegatecall(data);
    }

    function send(
        address payable to,
        uint256 amount
    ) external onlyApproved onlyOnce {
        require(balance >= amount, 'Not enough funds to send');
        balance -= amount;
        to.transfer(amount);
        emit Transfer(sender(), amount, balance);
    }

    function call(
        address to,
        bytes calldata data
    ) external onlyApproved onlyOnce returns (bool, bytes memory) {
        uint256 startGas = gasleft();
        uint256 totalCost = _safeGasPrice() * startGas;
        require(
            balance >= totalCost,
            'Not enough funds to cover the cost of the call'
        );
        (bool success, bytes memory returnData) = to.call{ value: value() }(
            data
        );
        totalCost = _safeGasPrice() * (startGas - gasleft());
        payable(sender()).transfer(totalCost);
        balance - totalCost <= 0 ? balance = 0 : balance -= totalCost;
        return (success, returnData);
    }

    function _safeGasPrice() internal view returns (uint256) {
        return (tx.gasprice);
    }

    function call(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlyApproved onlyOnce returns (bool, bytes memory) {
        uint256 startGas = gasleft();
        uint256 totalCost = _safeGasPrice() * startGas;
        require(
            balance >= totalCost,
            'Not enough funds to cover the cost of the call'
        );
        (bool success, bytes memory returnData) = to.call{ value: value }(data);
        totalCost = _safeGasPrice() * (startGas - gasleft());
        payable(sender()).transfer(totalCost);
        balance - totalCost <= 0 ? balance = 0 : balance -= totalCost;
        return (success, returnData);
    }

    function availableBalance() external view override returns (uint256) {
        return balance;
    }

    function transfer(
        address erc721Destination,
        address to,
        uint256 tokenId
    ) external onlyApproved onlyOnce {
        IERC721(erc721Destination).safeTransferFrom(address(this), to, tokenId);
    }

    function deposit() external payable {
        balance += value();
        emit Deposit(sender(), value(), balance);
    }

    function empty() external onlyDeployer onlyOnce {
        require(balance > 0, 'No funds to withdraw');
        payable(sender()).transfer(balance);
        emit Withdraw(sender(), balance, 0);
        balance = 0;
    }

    function withdraw(uint256 amount) external onlyApproved onlyOnce {
        require(balance >= amount, 'Not enough funds');
        payable(sender()).transfer(amount);
        balance - amount <= 0 ? balance = 0 : balance -= amount;
        emit Withdraw(sender(), amount, balance);
    }
}
