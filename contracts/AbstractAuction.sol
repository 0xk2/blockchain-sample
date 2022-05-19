pragma solidity ^0.8.4;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

/**
  Auction contract, ready to be listed on market such as OpenSea
 */
abstract contract AbstractAuction is ERC721 {
  /**
    User must deposit `erc20Token` x `amount`
   */
  function mint(address erc20Token, uint256 amount, string memory _baseURI) 
    virtual external returns (uint256 tokenId);

   /**
    Owner can burn NFT to get the fund deposited in it
    */
  function burn(uint256 tokenId) virtual external;

 }