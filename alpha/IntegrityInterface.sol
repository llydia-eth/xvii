//SPDX-License-Identifier: UNLICENSED
//llydia cross 2021
pragma solidity ^0.8.0;

interface IntegrityInterface {
    /**
		@notice Verifys that a deployed contract matches the one we want.
	 */
    function getIntegrity()
        external
        returns (
            address from,
            address owner,
            uint256 tokenId,
            bytes memory versionType,
            bytes4 intefaceId
        );
}
