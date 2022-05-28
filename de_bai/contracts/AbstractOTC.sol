
pragma solidity ^0.8.4;

/**
  Contract for transperant OTC deal
 */
abstract contract OTC {
  /**
    User must deposit `erc20Token` x `amount`
   */
  function push(address erc20Token, uint256 amount, 
    address erc20PaymentToken, uint256 minPaymentAmount,
    address[] memory whitelistedAdresses) virtual external returns (uint256 otcId);
  
  /**
    Buyer pay and burn the OTC afterward
   */
  function pull(uint256 otcId) virtual external;

  /**
    Owner OTC to get back the fund
   */
  function burn(uint256 tokenId) virtual external;
}