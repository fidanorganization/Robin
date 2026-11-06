// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {NebulaTestV1} from "./NebulaTestV1.sol";

/// @title NebulaTestV2 — upgrade target for the UUPS proxy test (TEST ONLY)
/// @notice Identical storage layout to V1 (no new state before this point);
///         appends one new state variable at the end, which is the only safe
///         way to extend storage in an upgrade. version() returns 2 and a new
///         owner-only marker setter proves new logic runs on old state.
contract NebulaTestV2 is NebulaTestV1 {
    uint256 public upgradeMarker;

    function version() public pure override returns (uint256) {
        return 2;
    }

    function setUpgradeMarker(uint256 value) external onlyOwner {
        upgradeMarker = value;
    }
}
