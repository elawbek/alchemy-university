// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract SendingEther {
    constructor(address) {
        assembly {
            sstore(0x00, caller())
            sstore(0x01, mload(0x80))
        }
    }

    // 0x00 - owner slot
    function owner() external view returns (address result) {
        assembly {
            result := sload(0x00)
        }
    }

    // 0x01 - charity slot
    function charity() external view returns (address result) {
        assembly {
            result := sload(0x01)
        }
    }

    function tip() external payable {
        assembly {
            if iszero(
                call(gas(), sload(0x00), callvalue(), 0x00, 0x00, 0x00, 0x00)
            ) {
                revert(0x00, 0x00)
            }
        }
    }

    function donate() external {
        assembly {
            if iszero(
                call(gas(), sload(0x01), selfbalance(), 0x00, 0x00, 0x00, 0x00)
            ) {
                revert(0x00, 0x00)
            }
        }
    }

    receive() external payable {}
}
