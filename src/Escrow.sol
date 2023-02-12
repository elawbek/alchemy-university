// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Escrow {
    event Approved(uint256 balance);

    constructor(address, address) payable {
        assembly {
            sstore(0x00, caller())
            sstore(0x01, mload(0x80)) // beneficiary
            sstore(0x02, mload(0xa0)) // arbiter
        }
    }

    // 0x00 - depositor slot
    function depositor() external view returns (address result) {
        assembly {
            result := sload(0x00)
        }
    }

    // 0x01 - beneficiary slot
    function beneficiary() external view returns (address result) {
        assembly {
            result := sload(0x01)
        }
    }

    // 0x02 - arbiter slot
    function arbiter() external view returns (address result) {
        assembly {
            result := shr(0x60, shl(0x60, sload(0x02)))
        }
    }

    // 0x02 - isApproved slot
    function isApproved() external view returns (bool result) {
        assembly {
            result := shr(0xa0, sload(0x02))
        }
    }

    function approve() external {
        assembly {
            let arbiterAddress := sload(0x02)
            if iszero(eq(caller(), shr(0x60, shl(0x60, arbiterAddress)))) {
                revert(0x00, 0x00)
            }
            mstore(0x00, selfbalance())
            if iszero(
                call(gas(), sload(0x01), selfbalance(), 0x00, 0x00, 0x00, 0x00)
            ) {
                revert(0x00, 0x00)
            }
            sstore(0x02, or(shl(0xa0, 0x01), arbiterAddress))
            log1(
                0x00,
                0x20,
                0x3ad93af63cb7967b23e4fb500b7d7d28b07516325dcf341f88bebf959d82c1cb // keccak256("Approved(uint256)")
            )
        }
    }
}
