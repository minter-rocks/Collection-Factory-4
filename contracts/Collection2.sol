// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**                                   .----------------. 
 *                                   | .--------------. |
 *                                   | |  _______     | |
 *                                   | | |_   __ \    | |
 *                                   | |   | |__) |   | |
 *                                   | |   |  __ /    | |
 *                                   | |  _| |  \ \_  | |
 *                                   | | |____| |___| | |
 *                                   | |              | |
 *                                   | '--------------' |
 *                                   '------------------' 
 *
 *   ███╗   ███╗██╗███╗   ██╗████████╗███████╗██████╗    ██████╗  ██████╗  ██████╗██╗  ██╗███████╗
 *   ████╗ ████║██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗   ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝
 *   ██╔████╔██║██║██╔██╗ ██║   ██║   █████╗  ██████╔╝   ██████╔╝██║   ██║██║     █████╔╝ ███████╗
 *   ██║╚██╔╝██║██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗   ██╔══██╗██║   ██║██║     ██╔═██╗ ╚════██║
 *   ██║ ╚═╝ ██║██║██║ ╚████║   ██║   ███████╗██║  ██║██╗██║  ██║╚██████╔╝╚██████╗██║  ██╗███████║
 *   ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝
 */

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/**
 * @title NFT Collection contract version_2
 * @notice the contract is ERC721 enumerable.
 * @notice tokenIds are starting from 0 to (maxSupply - 1).
 * @notice tokenURIs are all in the same format baseURI/tokenId.
 * @notice totalSupply is limited and set once at initializing time.
 * @notice safeMint restricted to the owner.
 * @notice safeMint can be auto increment or you can specify the tokenId.
 * @notice there is a default royalty which can be set once at initializing time and 
 * also every token can have its particular royalty and does not use default royalty.
 * @notice owner of the contract can delete default royalty and token royalties and only 
 * set royalty for a specific token if they own it.
 * @notice every token owner can log a comment in the contract by its token and address.
 */
contract Collection is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721BurnableUpgradeable, ERC721RoyaltyUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;

    /**
     * @notice creator of the Collection.
     */
    string public _creator_;

    /**
     * @notice change the creator name.
     * @param _creatorName new name of the creator.
     * @notice only owner of the contract can call this function.
     */
    function setCreatorName(string memory _creatorName) public onlyOwner {
        _creator_ = _creatorName;
    }

    /**
     * @notice the base uri of the collection on IPFS.
     */
    string private _baseURI_;

    /**
     * @notice override -baseURI function to define functionality.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseURI_;
    }

    /**
     * @notice maximum number of tokens can be minted.
     */
    uint256 public maxSupply;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice initialize the Collection called by the Factory.
     * @dev can be called only one time.
     * @param _creator creator of the Collection.
     * @param _name name of Collection tokens.
     * @param _symbol symbol of Collection tokens.
     * @param _uri the base uri of the collection on IPFS.
     * @param _maxSupply maximum number of tokens can be minted.
     * @param _owner address of the creator of the Collection.
     * @param _royaltyNumerator the numerator of default token royalties which denumerator is 10000.
     * @param _royaltyReciever the wallet address that receives the royalty.
     */
    function initialize(
        string memory _creator,
        string memory _name, 
        string memory _symbol,
        string memory _uri,
        uint256 _maxSupply,
        address _owner,
        uint96 _royaltyNumerator,
        address _royaltyReciever
    ) initializer public {
        _creator_ = _creator;
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __Ownable_init(_owner);
        _baseURI_ = _uri;
        maxSupply = _maxSupply;
        if (_royaltyNumerator > 0) {
            require(_royaltyReciever != address(0), "Collection: Invalid Royalty receiver");
            _setDefaultRoyalty(_royaltyReciever, _royaltyNumerator);
        }
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @param tokenId desired id selected for the token.
     * @dev the tokenId should be not minted before.
     * @notice only owner of the contract can call this function.
     */
    function safeMint(
        address to, 
        uint256 tokenId
    ) public onlyOwner {
        _safeMint(to, tokenId);
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @dev the tokenId will be earned automatically.
     * @notice only owner of the contract can call this function.
     */
    function safeMint(address to) public onlyOwner {
        uint256 tokenId;
        do {
            tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
        } while (_exists(tokenId));

        _safeMint(to, tokenId);
    }

    /**
     * @notice set the royalty for the specified token.
     * @param tokenId tokenId that you want to reset its royalty.
     * @param receiver the wallet address that receives the royalty.
     * @param feeNumerator the numerator of the token royalty which denumerator is 10000.
     * @notice you must be the owner of the contract and also owner of the token.
     */
    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        require(msg.sender == ownerOf(tokenId), "Collection: you must be the owner of the token to set the royalty");
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @notice Delete default royalty of Collection tokens.
     * @notice It can't be set again after that was removed.
     * @notice only owner of the contract can call this function.
     */
    function deleteDefaultRoyalty() public onlyOwner {
        _deleteDefaultRoyalty();
    }

    /**
     * @notice reset the royalty of the specified token.
     * @param tokenId tokenId that you want to reset its royalty.
     * @notice only owner of the contract can call this function.
     */
    function resetTokenRoyalty(uint256 tokenId) public onlyOwner {
        _resetTokenRoyalty(tokenId);
    }

    /**
     * @notice override mint function to change functionality.
     * @notice tokenIds limited to maxSupply.
     */
    function _mint(address to, uint256 tokenId) internal override {
        require (tokenId < maxSupply, "Collection: Invalid token Id");
        super._mint(to, tokenId);
    }

    event Comment(uint256 indexed tokenId, address userAddr, string text);
    /**
     * @notice comments as event.
     */
    function comment(uint256 tokenId, string memory text) public {
        require(msg.sender == ownerOf(tokenId), "Collection: Invalid token Id");
        emit Comment(tokenId, msg.sender, text);
    }


    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721RoyaltyUpgradeable)
    {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721RoyaltyUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}