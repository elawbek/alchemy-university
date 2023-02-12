// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Party {
    constructor(uint256) {
        assembly {
            sstore(0x01, mload(0x80))
        }
    }

    // 0x00 - party slot
    function party(uint256) external view returns (address result) {
        assembly {
            let index := calldataload(0x04)
            if iszero(lt(index, sload(0x00))) {
                // bytes4(keccak256("Panic(uint256)"))
                mstore(0x00, shl(0xe0, 0x4e487b71))
                mstore(0x04, 0x32)
                revert(0x00, 0x24)
            }

            // mstore(0x00, 0x00)
            result := sload(add(keccak256(0x00, 0x20), index))
        }
    }

    // 0x01 - depositAmount slot
    function depositAmount() external view returns (uint256 result) {
        assembly {
            result := sload(0x01)
        }
    }

    function rsvp() external payable {
        assembly {
            if iszero(eq(callvalue(), sload(0x01))) {
                revert(0x00, 0x00)
            }

            let slot := keccak256(0x00, 0x20)
            let length := sload(0x00)

            for {
                let i
            } lt(i, length) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            } {
                if eq(caller(), sload(slot)) {
                    revert(0x00, 0x00)
                }
            }

            sstore(slot, caller())
            sstore(0x00, add(length, 0x01))
        }
    }

    function payBill(address, uint256) external {
        assembly {
            let amount := calldataload(0x24)
            if lt(selfbalance(), amount) {
                revert(0x00, 0x00)
            }

            let remain := sub(selfbalance(), amount)
            if iszero(
                call(gas(), calldataload(0x04), amount, 0x00, 0x00, 0x00, 0x00)
            ) {
                revert(0x00, 0x00)
            }

            if gt(remain, 0x00) {
                for {
                    let length := sload(0x00)
                    let amountPerFriend := div(remain, length)
                    let i
                    let slot := keccak256(0x00, 0x20)
                } lt(i, length) {
                    i := add(i, 0x01)
                    slot := add(slot, 0x01)
                } {
                    if iszero(
                        call(
                            gas(),
                            sload(slot),
                            amountPerFriend,
                            0x00,
                            0x00,
                            0x00,
                            0x00
                        )
                    ) {
                        revert(0x00, 0x00)
                    }
                }
            }
            sstore(0x00, 0x00)
        }
    }
}
