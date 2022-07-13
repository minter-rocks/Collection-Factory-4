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
import "./Collection4.sol";

/**
 * @title NFT Collection Factory
 * @author Minter.Rocks
 * @notice create your own NFT collection contract and convert your files to NFTs
 * in the simplest way possible.
 */
contract Factory {
    using Clones for address;

    /**
     * @notice the predeployed collection contract abi which the Factory clones.
     */
    Collection public collectionCont = new Collection();

    event NewCollection(
        string creatorName,
        string tokenName,
        string tokenSymbol,
        uint256 totalSupply,
        address creatorAddress,
        address contractAddress,
        uint96 defaultRoyalty
    );

    /**
     * @notice Create a new NFT collection.
     * @param creatorName enter your name as the creator of the new collection.
     * @param tokenName name of collection tokens.
     * @param tokenSymbol symbol of collection tokens.
     * @param baseURI the base uri of the collection on IPFS.
     * @param totalSupply maximum number of tokens can be minted.
     * @param royaltyNumerator the numerator of default token royalties which denumerator.
     * is 10000. if you set a royaltyNumerator, you will earn a fraction of the tokens.
     * price, every time they tranfers in market places.
     * @param royaltyReciever the wallet address that receives the royalty.
     * @dev clones a predeployed collection contract abi with a new address onchain.
     * @dev initializes the new created collection as the creator desired.
     * @dev emits a NewCollection event.
     */
    function newCollection(
        string memory creatorName,
        string memory tokenName,
        string memory tokenSymbol,
        string memory baseURI,
        uint256 totalSupply,
        uint96 royaltyNumerator,
        address royaltyReciever
    ) public {
        address collectionAddr = address(collectionCont).clone();
        Collection(collectionAddr).initialize(
            creatorName,
            tokenName, 
            tokenSymbol,
            baseURI,
            totalSupply,
            msg.sender,
            royaltyNumerator,
            royaltyReciever
        );
        emit NewCollection(
            creatorName, 
            tokenName, 
            tokenSymbol, 
            totalSupply,
            msg.sender,
            collectionAddr, 
            royaltyNumerator
        );
    }
}