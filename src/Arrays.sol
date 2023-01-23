// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Arrays {
    function sum(uint256[5] calldata) external pure returns (uint256 result) {
        assembly {
            for {
                let length := 0x05
                let i := 0x00
                let j := 0x04
            } lt(i, length) {
                i := add(i, 0x01)
                j := add(j, 0x20)
            } {
                result := add(result, calldataload(j))
            }
        }
    }

    function sum(uint256[] calldata) external pure returns (uint256 result) {
        assembly {
            for {
                let length := calldataload(0x24)
                let i := 0x00
                // let j := add(0x24, calldataload(0x04))
                let j := 0x44
            } lt(i, length) {
                i := add(i, 0x01)
                j := add(j, 0x20)
            } {
                result := add(result, calldataload(j))
            }
        }
    }

    // 0x00 - evenNumbers slot
    function evenNumbers(uint256) external view returns (uint256 result) {
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

    function filterEvenToStorage(uint256[] calldata) external {
        assembly {
            let currentLength := sload(0x00)
            let counter := 0x00

            for {
                // mstore(0x00, 0x00)
                let slot := add(keccak256(0x00, 0x20), currentLength)
                let length := calldataload(0x24)
                let value := 0x00
                let i := 0x00
                // let j := add(0x24, calldataload(0x04))
                let j := 0x44
            } lt(i, length) {
                i := add(i, 0x01)
                j := add(j, 0x20)
            } {
                value := calldataload(j)
                if iszero(and(value, 0x01)) {
                    sstore(add(slot, counter), value)
                    counter := add(counter, 0x01)
                }
            }

            sstore(0x00, add(counter, currentLength))
        }
    }

    function filterEvenToMemory(uint256[] calldata)
        external
        pure
        returns (uint256[] memory result)
    {
        assembly {
            let ptr := add(result, 0x20)
            let counter := 0x00
            for {
                let length := calldataload(0x24)
                let value := 0x00
                let i := 0x00
                // let j := add(0x24, calldataload(0x04))
                let j := 0x44
            } lt(i, length) {
                i := add(i, 0x01)
                j := add(j, 0x20)
            } {
                value := calldataload(j)
                if iszero(and(value, 0x01)) {
                    mstore(ptr, value)
                    counter := add(counter, 0x01)
                    ptr := add(ptr, 0x20)
                }
            }

            mstore(result, counter)
            mstore(0x40, ptr)
        }
    }
}
