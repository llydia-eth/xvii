//SPDX-License-Identifier: UNLICENSED
//llydia cross 2021
pragma solidity ^0.8.0;

import './Wallet.sol';
import '../IntegrityInterface.sol';

contract TokenWallet is Wallet {
    /// @notice the version type of wallet this is
    bytes public walletType = 'wallet';
    /// @notice the location of the main ERC721 contract this wallet was spawned from;
    address public erc721;
    /// @notice the main ERC721 contract this wallet is attached too
    uint32 public currentTokenId;

    /// @notice Creates new wallet contract, tokenId refers to the ERC721 contract this wallet was spawned from.
    /// @dev makes the owner field the owner of the contract not the deployer.
    /// @param tokenId the tokenId from the main ERC721 contract
    /// @param erc721Destination the main ERC721 contract
    constructor(uint32 tokenId, address erc721Destination) Authentication() {
        //this only refers to being allowed to deposit into the wallet
        currentTokenId = tokenId;
        erc721 = erc721Destination;
    }

    /// @notice used by InfinityMintLinker to verify this contract is the one it says and is apart of the InfinityMint ecosystem
    function getIntegrity()
        public
        view
        virtual
        returns (address, address, uint256, bytes memory, bytes4)
    {
        return (
            address(this),
            deployer,
            currentTokenId,
            walletType, //no version type with wallet
            type(IntegrityInterface).interfaceId
        );
    }

    /**
		@notice This can be called by the new token owner at any time and it will match the current owner of the contract to the tokenId,
		in all cases the wallet will still be attached to the owner of the tokenId and when its not it will simply move over permissions of
		the contract to the new owner
	 */
    function transferOwnershipToCurrentOwner() public onlyOnce {
        address owner = IERC721(erc721).ownerOf(currentTokenId);
        require(deployer != owner, 'owner of the token is the deployer');
        require(sender() == owner, 'sender must be the new owner');
        transferOwnership(owner);
    }
}
