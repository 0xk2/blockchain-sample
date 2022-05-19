// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

abstract contract AStablecoin is IERC20, AccessControlEnumerable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    function pause() public virtual;

    function unpause() public virtual;

    function burn(uint256 amount) public virtual;

    function burnFrom(address account, uint256 amount) public virtual;

    function mint(address to, uint amount) public virtual;
}