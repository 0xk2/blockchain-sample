// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Auction.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract AAuctionManager {
    uint _auctionIdCounter; // auction Id counter
    mapping(uint => Auction) public auctions; // auctions
    
    // create an auction
    function createAuction(uint _endTime, uint _minIncrement, uint _directBuyPrice,uint _startPrice,address _nftAddress,uint _tokenId) external returns (bool) {}

    // Return a list of all auctions
    function getAuctions() external view returns(address[] memory _auctions) {}

    // Return the information of each auction address
    function getAuctionInfo(address[] calldata _auctionsList) external view {}
}