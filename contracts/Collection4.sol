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
 * @title NFT Collection contract version_4
 * @notice the contract is ERC721 enumerable.
 * @notice tokenIds are starting from 0 to (maxSupply - 1).
 * @notice tokenURIs can be all similar (baseURI); or all in the same format (baseURI/tokenId).
 * @notice baseURI can be set by the owner of the collection.
 * @notice totalSupply is limited and set once at initializing time.
 * @notice the owner can safeMint single or batch tokens to any address desired.
 * @notice also the owner can add one or more addresses to the white list so they can mint a token.
 * @notice the owner can enable or disable the white list as they want. if disable, every one can mint.
 * @notice there is a default royalty which can be set once at initializing time and 
 * also every token can have its particular royalty and does not use default royalty.
 * @notice owner of the contract can delete default royalty and token royalties and only 
 * set royalty for a specific token if they own it.
 */
contract Collection is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721BurnableUpgradeable, ERC721RoyaltyUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    CountersUpgradeable.Counter private _tokenIdCounter;
    mapping(address => bool) _whiteList;

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
     * @notice the base URI of the collection on IPFS or desired data base.
     */
    string public baseURI;
    bool public sameURI;

    event SetBaseURI(string baseURI_, bool sameForAllTokens);
    /**
     * @notice change the baseURI.
     * @param baseURI_ base URI of the tokens.
     * @notice only owner of the contract can call this function.
     */
    function setBaseURI(string memory baseURI_, bool sameForAllTokens) public onlyOwner {
        baseURI = baseURI_;
        sameURI = sameForAllTokens;
        emit SetBaseURI(baseURI_, sameForAllTokens);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return sameURI ? baseURI : string.concat(baseURI, tokenId.toString());
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
     * @param _baseURI the base uri of the collection on IPFS.
     * @param _sameURIForAllTokens true if all tokens use a same URI.
     * @param _maxSupply maximum number of tokens can be minted.
     * @param _owner address of the creator of the Collection.
     * @param _royaltyNumerator the numerator of default token royalties which denumerator is 10000.
     * @param _royaltyReciever the wallet address that receives the royalty.
     */
    function initialize(
        string memory _creator,
        string memory _name, 
        string memory _symbol,
        string memory _baseURI,
        bool _sameURIForAllTokens,
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
        baseURI = _baseURI;
        sameURI = _sameURIForAllTokens;
        maxSupply = _maxSupply;
        if (_royaltyNumerator > 0) {
            require(_royaltyReciever != address(0), "Collection: Invalid Royalty receiver");
            _setDefaultRoyalty(_royaltyReciever, _royaltyNumerator);
        }
    }

    bool whiteListIsEnabled;

    function enableWhiteList() public onlyOwner {
        whiteListIsEnabled = true;
    }

    function disableWhiteList() public onlyOwner {
        whiteListIsEnabled = false;
    }

    function addToWhiteList(address[] memory addrList) public onlyOwner {
        for(uint256 index; index < addrList.length; index++) {
            _whiteList[addrList[index]] = true;
        }
    }

    function removeFromWhiteList(address[] memory addrList) public onlyOwner {
        for(uint256 index; index < addrList.length; index++) {
            _whiteList[addrList[index]] = false;
        }
    }

    function safeMintBatch(address[] memory to) public onlyOwner {
        uint256 tokenId;
        for(uint256 index; index < to.length; index++) {
            tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to[index], tokenId);
        }
    }

    /**
     * @notice mint a new token.
     * @param to address that will own the token.
     * @dev the tokenId will be set automatically.
     * @notice only owner of the contract can call this function.
     */
    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    /**
     * @notice mint a new token.
     * @dev the tokenId will be set automatically.
     * @notice if white list is enabled, only whiteList can call this function.
     */
    function safeMint() public {
        address userAddr = msg.sender;
        if(whiteListIsEnabled) {
            require(_whiteList[userAddr], "Collection: address not registered in white list");
            _whiteList[userAddr] = false;
        }

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(userAddr, tokenId);

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