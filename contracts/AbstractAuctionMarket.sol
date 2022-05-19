pragma solidity ^0.8.4;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

/**
  Standalone AuctionMarket contract
 */
abstract contract AbstractAuctionMarket{
  /**
    Token owner will push `erc20Token` x `minPaymentAmount` to the Market
    - The `bid` will valid from startBlk to endBlk
    - If the `bid` is success, the owner would have to pay `fee` to the Protocol
  */
  function push(address erc20Token, uint256 amount, 
    address erc20PaymentToken, uint256 minPaymentAmount, 
    uint256 startBlk, uint256 endBlk) virtual external returns(uint256 auctionId);

  /**
    A valid `bid` must has the `amount` >= `minPaymentAmount`
   */
  function bid(uint256 amount, uint256 auctionId) virtual external;

  /**
    AuctionId can only be pulled if it is already ended
    `Pull` will transfer the fund to according parties
    Whoever `pull` will receive some `fee`
   */
  function pull(uint256 auctionId) virtual external;

  /**
    Owner can `pop` the bid to get the fund back if the bid is not yet started
    If the bid is success then `pop` will `pull` instead
   */
  function pop(uint256 auctionId) virtual external;
}