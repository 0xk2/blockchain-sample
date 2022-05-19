// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract AUSDT is IERC20 {
  uint basicPointsRate;
  uint maximumFee;
  bool deprecated;
  address upgradedAddress;

  // Called when new token are issued
  event Issue(uint amount);

  // Called when tokens are redeemed
  event Redeem(uint amount);

  // Called when contract is deprecated
  event Deprecate(address newAddress);

  // Called if contract ever adds fees
  event Params(uint feeBasisPoints, uint maxFee);

  function setParams(uint newBasisPoints, uint newMaxFee) external virtual;

  // Called to mark this contract is deprecated and set `upgradedAddress`
  function deprecate(address _upgradedAddress) external virtual;
}