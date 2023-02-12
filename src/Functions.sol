// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract Functions {
    constructor(uint256) {
        assembly {
            sstore(0x00, mload(0x80))
        }
    }

    // 0x00 - value slot
    function value() external view returns (uint256 result) {
        assembly {
            result := sload(0x00)
        }
    }

    function increment() external {
        assembly {
            sstore(0x00, add(sload(0x00), 0x01))
        }
    }

    function add(uint256) external view returns (uint256 result) {
        assembly {
            result := add(sload(0x00), calldataload(0x04))
        }
    }

    function double(uint256) external pure returns (uint256 result) {
        assembly {
            let x := calldataload(0x04)
            result := add(x, x)
        }
    }

    function double(uint256, uint256)
        external
        pure
        returns (uint256 result1, uint256 result2)
    {
        assembly {
            let x := calldataload(0x04)
            result1 := add(x, x)

            x := calldataload(0x24)
            result2 := add(x, x)
        }
    }
}
