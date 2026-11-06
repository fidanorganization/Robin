// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title TestStable — USDC-style stablecoin TEST contract (Base Sepolia only)
/// @notice Models the issuer controls a fiat-backed stablecoin needs, for the
///         $JOHN test track: role-based minting, per-address freeze, pause,
///         holder burn, EIP-2612 permit. Worthless test token by design:
///         no sale, no backing claim, no peg promise.
contract TestStable is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant FREEZER_ROLE = keccak256("FREEZER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    mapping(address => bool) public frozen;

    event Frozen(address indexed account);
    event Unfrozen(address indexed account);

    error AccountFrozen(address account);

    /// @param admin Receives DEFAULT_ADMIN_ROLE plus MINTER/FREEZER/PAUSER at
    ///        deploy so a single test wallet can run the whole suite; roles
    ///        can be re-granted to separate accounts afterwards.
    constructor(address admin)
        ERC20("Test Stable", "TSTB")
        ERC20Permit("Test Stable")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(FREEZER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    /// @notice Issuer mint — MINTER_ROLE only. No supply exists until minted.
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice Freeze an address: it can no longer send or receive.
    function freeze(address account) external onlyRole(FREEZER_ROLE) {
        frozen[account] = true;
        emit Frozen(account);
    }

    function unfreeze(address account) external onlyRole(FREEZER_ROLE) {
        frozen[account] = false;
        emit Unfrozen(account);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        if (from != address(0) && frozen[from]) revert AccountFrozen(from);
        if (to != address(0) && frozen[to]) revert AccountFrozen(to);
        super._update(from, to, value);
    }
}
