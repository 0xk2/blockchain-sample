pragma solidity ^0.8.4;

abstract contract AbstractFakerSwap {
  /**
  Anyone can open a trading pair
   */
  function addPair(address erc20Token1, address erc20Token2, uint256 token1Amount, uint256 token2Amount) virtual external returns(uint256 pairId);

  /**
  Anyone can contribute liquidity to the trading pair
   */
  function addLiquidity(uint256 pairId, uint256 token1Amount, uint256 token2Amount) virtual external;

  function swap(uint256 token) virtual external;
}