// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract StackClub {
    constructor() {
        assembly {
            // mstore(0x00, 0x00)
            sstore(keccak256(0x00, 0x20), caller())
            sstore(0x00, 0x01)
        }
    }

    // 0x00 - members slot
    function members(uint256) external view returns (address result) {
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

    function addMember(address addr) external {
        if (!isMember(msg.sender)) {
            assembly {
                revert(0x00, 0x00)
            }
        }

        if (isMember(addr)) {
            assembly {
                revert(0x00, 0x00)
            }
        }

        assembly {
            let length := sload(0x00)
            // mstore(0x00, 0x00)
            sstore(add(keccak256(0x00, 0x20), length), addr)
            sstore(0x00, add(length, 0x01))
        }
    }

    function removeLastMember() external {
        if (!isMember(msg.sender)) {
            assembly {
                revert(0x00, 0x00)
            }
        }

        assembly {
            sstore(0x00, sub(sload(0x00), 0x01))
        }
    }

    function isMember(address addr) public view returns (bool result) {
        assembly {
            for {
                // mstore(0x00, 0x00)
                let slot := keccak256(0x00, 0x20)
                let length := sload(0x00)
                let i := 0x00
                let value := 0x00
            } lt(i, length) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            } {
                if eq(addr, sload(slot)) {
                    result := 0x01
                    i := length
                }
            }
        }
    }
}
