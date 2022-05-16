pragma solidity ^0.8.4;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

abstract contract FakerDAI is Ownable, ERC20 {
  
  /**
   Owner can enable or disable a certain kind of token can be used for lending
   */
  function _toggleTreasuryToken(address erc20TokenAddress, bool enable) virtual internal;
  function enableTreasuryToken(address erc20TokenAddress) external onlyOwner{
    _toggleTreasuryToken(erc20TokenAddress, true);
  }
  function disableTreasuryToken(address erc20TokenAddress) external onlyOwner {
    _toggleTreasuryToken(erc20TokenAddress, false);
  }

  /**
    If user depost X amount of a token then
    - The deposited asset will be collateraled and the protocol will mint x% of the market price and send to the user.
    e.g: if collateralPercentage=150% then the minting amount will be: market price/1.5. This is also the liquidated price.
    - They have to pay depositFee (%) of the minted amount, this is the protocol revenue 
    which will be used to pay for liquidationPenalty in a liquidation event
   */
  function deposit(address erc20TokenAddress, uint256 amount, uint256 collateralPercentage) virtual external returns (uint256 depositId);

  /**
    If user decide to burn their previous deposit then
    - They have to pay stablizeFee (%), this is the protocol revenue
    - They have to send the borrowed amount to the protocol and these tokens will be burnt
  */
  function burn(uint256 depositId) virtual external;

  /**
    Whenever the marketPrice drop below liquidated price then 
    whoever find out and execute the liquidate function will receive a liquidationPenalty
   */
  function liquidate(uint256 depositId) virtual external;

}