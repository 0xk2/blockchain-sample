   
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RedeemableNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    /* ======== EVENTS ======== */
    event SafeMint(address indexed to, string uri, string indexed backedTokenSymbol, uint256 amount);

    event Redeem(uint256 indexed tokenId, address indexed to);

    event Withdraw(address indexed backedTokenAddr, uint256 amount);

    /* ======== STATE VARIABLES ======== */
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public baseURI;

    string[] public symbols;
    struct BackedToken {
        address addr;
        uint256 decimal;
        uint256 redeemableAt;
        uint256 mintedAmount;
        uint256 redeemedAmount;
    }
    mapping(string => BackedToken) public backedTokens;

    struct Attribute {
        string symbol;
        uint256 amount;
    }
    mapping(uint256 => Attribute) public attributes;

    constructor(string memory _baseUri) ERC721("RedeemableNFT", "RNFT") {
        baseURI = _baseUri;
        _tokenIdCounter.increment();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        baseURI = _uri;
    }

    function getCurrentCounter() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function withdraw(address _backedTokenAddr, uint256 _amount) public onlyOwner {
        IERC20(_backedTokenAddr).transfer(msg.sender, _amount);
        emit Withdraw(_backedTokenAddr, _amount);
    }

    function getBackedToken(string memory _symbol) public view returns (BackedToken memory) {
        return backedTokens[_symbol];
    }

    function hasBackedToken(string memory _symbol) public view returns (bool) {
        return backedTokens[_symbol].redeemableAt != 0;
    }

    function setBackedToken(
        string memory _symbol,
        address _addr,
        uint256 _redeemableAt
    ) public onlyOwner {
        require(_redeemableAt > 0, "_redeemableAt should be greater than zero");
        BackedToken memory backedToken = backedTokens[_symbol];

        uint256 backedTokenDecimal = decimals();

        if (backedToken.redeemableAt == 0) {
            symbols.push(_symbol);
        }

        if (_addr != address(0)) {
            backedTokenDecimal = IERC20Metadata(_addr).decimals();
        }

        backedTokens[_symbol] = BackedToken({
            addr: _addr,
            decimal: backedTokenDecimal,
            redeemableAt: _redeemableAt,
            mintedAmount: backedToken.mintedAmount,
            redeemedAmount: backedToken.redeemedAmount
        });
    }

    function getBackedTokenSymbols() public view returns (string[] memory) {
        return symbols;
    }

    function getBackedTokenBalance(string calldata _symbol) public view returns (uint256) {
        BackedToken memory backedToken = backedTokens[_symbol];
        return ((backedToken.mintedAmount - backedToken.redeemedAmount) * (10**backedToken.decimal)) / (10**decimals());
    }

    function getTokenIdsPage(
        address _owner,
        uint256 _offset,
        uint256 _limit
    ) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(_owner);

        uint256[] memory ids = new uint256[](_limit);

        uint256 counter = 0;

        for (uint256 i = _offset; i < _offset + _limit; i++) {
            if (i >= balance) return ids;
            uint256 id = tokenOfOwnerByIndex(_owner, i);
            ids[counter++] = id;
        }

        return ids;
    }

    function safeMint(
        address _to,
        string memory _uri,
        string memory _symbol,
        uint256 _amount,
        uint256 _id
    ) public onlyOwner {
        BackedToken storage backedToken = backedTokens[_symbol];
        require(backedToken.redeemableAt != 0, "Backed Token Is Not Supported!");

        require(_to != address(0), "Mint to zero address!");

        uint256 tokenId = _tokenIdCounter.current();
        require(_id == tokenId, "TokenId conflict");

        _tokenIdCounter.increment();

        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _uri);

        attributes[tokenId] = Attribute({symbol: _symbol, amount: _amount});
        backedToken.mintedAmount += _amount;

        emit SafeMint(_to, _uri, _symbol, _amount);
    }

    function safeMintTokens(
        address _to,
        string[] memory _tokensURI,
        string[] memory _tokensSymbol,
        uint256[] memory _backedTokensAmount,
        uint256 fromId
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        require(fromId == tokenId, "TokenId conflict");

        require(_tokensURI.length > 0, "Tokens URI arrays not empty");
        require(
            _tokensURI.length == _tokensSymbol.length,
            "Length of tokens URI and tokens ymbol arrays is not equal!"
        );
        require(
            _tokensURI.length == _backedTokensAmount.length,
            "Length of tokensURI and tokensAmount arrays is not equal!"
        );

        for (uint256 i = 0; i < _tokensURI.length; i++) {
            safeMint(_to, _tokensURI[i], _tokensSymbol[i], _backedTokensAmount[i], fromId + i);
        }
    }

    function setTokensUri(uint256[] memory _ids, string[] memory _tokensURI) public onlyOwner {
        require(_ids.length > 0, "ID arrays not empty");
        require(_ids.length == _tokensURI.length, "Length of ID and Data arrays is not equal!");

        for (uint256 i = 0; i < _ids.length; i++) {
            _setTokenURI(_ids[i], _tokensURI[i]);
        }
    }

    function redeem(uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "Sender not owner!");

        Attribute memory attribute = attributes[_tokenId];
        BackedToken storage backedToken = backedTokens[attribute.symbol];
        require(backedToken.addr != address(0), "backedToken is not set");

        uint48 currentTime = uint48(block.timestamp);
        require(currentTime > backedToken.redeemableAt, "Not redeemable!");

        uint256 backedTokenAmount = (attribute.amount * (10**backedToken.decimal)) / (10**decimals());

        uint256 maxRedeem = IERC20(backedToken.addr).balanceOf(address(this));

        require(backedTokenAmount <= maxRedeem, "Not enough token to redeem!");

        _burn(_tokenId);

        backedToken.redeemedAmount += attribute.amount;

        delete attributes[_tokenId];

        IERC20(backedToken.addr).transfer(msg.sender, backedTokenAmount);

        emit Redeem(_tokenId, msg.sender);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
}