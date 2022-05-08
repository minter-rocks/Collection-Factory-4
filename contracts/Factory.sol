// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
 *             .----------------. 
 *            | .--------------. |
 *            | |  _______     | |
 *            | | |_   __ \    | |
 *            | |   | |__) |   | |
 *            | |   |  __ /    | |
 *            | |  _| |  \ \_  | |
 *            | | |____| |___| | |
 *            | |              | |
 *            | '--------------' |
 *            '-- MINTER.ROCKS --' 
 */

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Gallery.sol";

/**
 * @title NFT Gallery Factory
 * @author Minter.Rocks
 * @notice create your own NFT gallery contract and convert your files to NFTs
 * in the simplest way possible.
 */
contract Factory {
    using Clones for address;

    /**
     * @notice the predeployed gallery contract abi which the Factory clones.
     */
    Gallery public galleryCont = new Gallery();

    event NewGallery(
        string creatorName,
        string tokenName,
        string tokenSymbol,
        uint256 totalSupply,
        address creatorAddress,
        address contractAddress,
        uint96 defaultRoyalty
    );

    /**
     * @notice Create a new NFT gallery.
     * @param creatorName enter your name as the creator of the new gallery.
     * @param tokenName name of gallery tokens.
     * @param tokenSymbol symbol of gallery tokens.
     * @param royaltyNumerator the numerator of default token royalties which denumerator.
     * is 10000. if you set a royaltyNumerator, you will earn a fraction of the tokens.
     * price, every time they tranfers in market places.
     * @param royaltyReciever the wallet address that receives the royalty.
     * @dev clones a predeployed gallery contract abi with a new address onchain.
     * @dev initializes the new created gallery as the creator desired.
     * @dev emits a NewGallery event.
     */
    function newGallery(
        string memory creatorName,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 totalSupply,
        uint96 royaltyNumerator,
        address royaltyReciever
    ) public {
        address galleryAddr = address(galleryCont).clone();
        Gallery(galleryAddr).initialize(
            creatorName,
            tokenName, 
            tokenSymbol,
            totalSupply,
            msg.sender,
            royaltyNumerator,
            royaltyReciever
        );
        emit NewGallery(
            creatorName, 
            tokenName, 
            tokenSymbol, 
            totalSupply,
            msg.sender,
            galleryAddr, 
            royaltyNumerator
        );
    }
}