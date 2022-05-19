// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract AAuction {
    uint public tokenId; // The id of the token
    address public creator; // The address of the auction creator
    uint256 public startTime; // The block timestamp which marks the start of the auction
    uint256 public endTime; // Timestamp of the end of the auction (in seconds)
    address public nftAddress;  // The address of the NFT contract
    IERC721 _nft; // The NFT token
    
    uint public maxBid; // The maximum bid
    Bid[] public bids; // The bids made by the bidders
    address public maxBidder; // The address of the maximum bidder
    
    uint public startPrice; // The starting price for the auction
    uint public minIncrement; // The minimum increment for the bid
    uint public directBuyPrice; // The price for a direct buy
    bool public isDirectBuy; // True if the auction ended due to direct buy
    bool public isCancelled; // If the the auction is cancelled
    
    enum AuctionState { OPEN, CANCELLED, ENDED, DIRECT_BUY }

    struct Bid { // A bid on an auction
        address sender;
        uint256 bid;
    }

    event NewBid(address bidder, uint bid); // A new bid was placed
    event WithdrawToken(address withdrawer); // The auction winner withdrawed the token
    event WithdrawFunds(address withdrawer, uint256 amount); // The auction owner withdrawed the funds
    event AuctionCanceled(); // The auction was cancelled

    constructor(address _creator, uint _endTime, uint _minIncrement, uint _directBuyPrice, uint _startPrice, address _nftAddress, uint _tokenId) {}

    // Returns a list of all bids and addresses
    function allBids() external view returns (address[] memory, uint256[] memory) {}

    // Place a bid on the auction
    function placeBid() payable external returns(bool) {}

    // Withdraw the token after the auction is over
    function withdrawToken() external returns(bool) {}

    // Withdraw the funds after the auction is over
    function withdrawFunds() external returns(bool) {}

    function cancelAuction() external returns(bool) {}

    // Get the auction state
    function getAuctionState() external view returns(AuctionState) {}
}