//SPDX-License-Identifier: UNLICENSED
//llydia cross 2021
pragma solidity ^0.8.0;

import '../IERC721.sol';

interface IWallet is IERC721Receiver {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function send(address payable to, uint256 amount) external;

    function availableBalance() external view returns (uint256);

    function call(
        address to,
        bytes calldata data
    ) external returns (bool, bytes memory);

    function call(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool, bytes memory);

    function staticCall(
        address to,
        bytes calldata data
    ) external view returns (bool, bytes memory);

    function delegateCall(
        address to,
        bytes calldata data
    ) external returns (bool, bytes memory);

    function transfer(
        address erc721Destination,
        address to,
        uint256 tokenId
    ) external;
}
