// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Exercises {
    function sumAndAverage(
        uint256,
        uint256,
        uint256,
        uint256
    ) external pure returns (uint256 sum, uint256 average) {
        assembly {
            sum := add(
                add(
                    add(calldataload(0x04), calldataload(0x24)),
                    calldataload(0x44)
                ),
                calldataload(0x64)
            )
            average := shr(0x02, sum)
        }
    }
}
