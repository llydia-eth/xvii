//SPDX-License-Identifier: UNLICENSED
//llydia cross 2021
pragma solidity ^0.8.0;

import './InfinityMint.sol';
import './Asset.sol';
import './InfinityMintValues.sol';
import './Royalty.sol';
import './InfinityMintProject.sol';

/// @title InfinityMint API
/// @author Llydia Cross
/// @notice The purpose of this contract is to act as a service to provide data in a web3 or web2 context. You will find methods for data retrival here for previews, tokens, and stickers. and it is advised that you use get from here and not actual storage contract!
/// @dev
contract InfinityMintApi is InfinityMintObject {
    InfinityMint public erc721;
    InfinityMintStorage public storageController;
    Asset public assetController;
    InfinityMintValues public valuesController;
    Royalty public royaltyController;
    InfinityMintProject public projectController;

    constructor(
        address erc721Destination,
        address storageDestination,
        address assetDestination,
        address valuesDestination,
        address royaltyDestination,
        address projectDestination
    ) {
        erc721 = InfinityMint(erc721Destination);
        storageController = InfinityMintStorage(storageDestination);
        assetController = Asset(assetDestination);
        valuesController = InfinityMintValues(valuesDestination);
        royaltyController = Royalty(royaltyDestination);
        projectController = InfinityMintProject(projectDestination);
    }

    function getPrice() external view returns (uint256) {
        return royaltyController.tokenPrice();
    }

    function getCurrentProject()
        external
        view
        returns (
            bytes memory encodedUrl,
            bytes memory encodedTag,
            uint256 version
        )
    {
        return (
            projectController.getProject(),
            projectController.getCurrentTag(),
            projectController.getCurrentVersion()
        );
    }

    function getProject(
        uint256 version
    )
        external
        view
        returns (
            bytes memory encodedProject,
            bytes memory encodedTag,
            bytes memory encodedInitialProject
        )
    {
        return projectController.getVersion(version);
    }

    function isPreviewBlocked(address sender) external view returns (bool) {
        //returns true only if the current time stamp is less than the preview timestamp
        return block.timestamp < storageController.getPreviewTimestamp(sender);
    }

    /// @notice only returns a maximum of 256 tokens use offchain retrival services to obtain token information on owner!
    function allTokens(
        address owner
    ) public view returns (uint32[] memory tokens) {
        require(
            !valuesController.isTrue('disableRegisteredTokens'),
            'all tokens method is disabled'
        );

        return storageController.getAllRegisteredTokens(owner);
    }

    function getBytes(uint32 tokenId) external view returns (bytes memory) {
        if (tokenId < 0 || tokenId >= erc721.currentTokenId()) revert();

        InfinityObject memory data = storageController.get(tokenId);

        return encode(data);
    }

    /// @notice gets the balance of a wallet associated with a tokenId
    function getBalanceOfWallet(uint32 tokenId) public view returns (uint256) {
        address addr = getLink(tokenId, 0);
        if (addr == address(0x0)) return 0;
        (bool success, bytes memory returnData) = addr.staticcall(
            abi.encodeWithSignature('getBalance')
        );

        if (!success) return 0;

        return abi.decode(returnData, (uint256));
    }

    function setOption(string memory key, string memory option) external {
        require(erc721.balanceOf(sender()) > 0, 'must own at least one token');
        storageController.setOption(sender(), key, option);
    }

    function setTokenFlag(
        uint32 tokenId,
        string memory key,
        bool value
    ) external {
        require(
            erc721.isApprovedOrOwner(sender(), tokenId),
            'must be owner or approved'
        );
        storageController.setTokenFlag(tokenId, key, value);
    }

    function setFlag(string memory key, bool value) external {
        require(erc721.balanceOf(sender()) > 0, 'must own at least one token');
        storageController.setFlag(sender(), key, value);
    }

    function get(uint32 tokenId) external view returns (InfinityObject memory) {
        return storageController.get(tokenId);
    }

    function getWalletContract(uint32 tokenId) public view returns (address) {
        return
            getLink(tokenId, valuesController.tryGetValue('linkWalletIndex'));
    }

    function getLink(
        uint32 tokenId,
        uint256 index
    ) public view returns (address) {
        if (tokenId > storageController.get(tokenId).destinations.length)
            return address(0x0);

        return storageController.get(tokenId).destinations[index];
    }

    function getStickerContract(uint32 tokenId) public view returns (address) {
        return
            getLink(tokenId, valuesController.tryGetValue('linkStickersIndex'));
    }

    function getPreviewTimestamp(address addr) public view returns (uint256) {
        return storageController.getPreviewTimestamp(addr);
    }

    function getPreviewCount(address addr) public view returns (uint256 count) {
        //find previews
        InfinityMintObject.InfinityObject[] memory previews = storageController
            .findPreviews(addr, valuesController.tryGetValue('previewCount'));

        //since mappings initialize their values at defaults we need to check if we are owner
        count = 0;
        for (uint256 i = 0; i < previews.length; ) {
            if (previews[i].owner == addr) count++;

            unchecked {
                ++i;
            }
        }
    }

    function getPreviews(address addr) external view returns (uint32[] memory) {
        require(addr != address(0x0), 'cannot view previews for null address');

        //find previews
        InfinityMintObject.InfinityObject[] memory previews = storageController
            .findPreviews(addr, valuesController.tryGetValue('previewCount'));

        //since mappings initialize their values at defaults we need to check if we are owner
        uint256 count = 0;
        for (uint256 i = 0; i < previews.length; ) {
            if (previews[i].owner == addr) count++;
            unchecked {
                ++i;
            }
        }

        if (count > 0) {
            uint32[] memory rPreviews = new uint32[](count);
            count = 0;
            for (uint256 i = 0; i < previews.length; ) {
                rPreviews[count++] = uint32(i);
                unchecked {
                    ++i;
                }
            }

            return rPreviews;
        }

        return new uint32[](0);
    }

    function getPreview(
        uint32 index
    ) public view returns (InfinityObject memory) {
        return storageController.getPreviewAt(sender(), index);
    }

    function totalMints() external view returns (uint32) {
        return erc721.currentTokenId();
    }

    //the total amount of tokens
    function totalSupply() external view returns (uint256) {
        return valuesController.tryGetValue('maxSupply');
    }
}
