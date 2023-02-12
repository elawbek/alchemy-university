// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract LearningRevert {
    constructor() payable {
        assembly {
            if lt(callvalue(), 1000000000000000000) {
                revert(0x00, 0x00)
            }

            sstore(0x00, caller())
        }
    }

    // 0x00 - owner slot
    function owner() external view returns (address result) {
        assembly {
            result := sload(0x00)
        }
    }

    function withdraw() external {
        assembly {
            let owner := sload(0x00)
            if iszero(eq(owner, caller())) {
                revert(0x00, 0x00)
            }

            if iszero(
                call(gas(), owner, selfbalance(), 0x00, 0x00, 0x00, 0x00)
            ) {
                revert(0x00, 0x00)
            }
        }
    }
}
