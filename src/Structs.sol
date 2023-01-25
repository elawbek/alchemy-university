// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

enum Choices {
    Yes,
    No
}

struct Vote {
    Choices choice;
    address voter;
}

contract Structs {
    // single vote - 0x00 slot
    function vote() external view returns (Vote memory result) {
        assembly {
            let slot := sload(0x00)
            mstore(result, and(slot, 0xff))
            mstore(add(result, 0x20), shr(0x08, slot))
        }
    }

    function createVoteStorage(Choices choice) external {
        assembly {
            sstore(0x00, or(shl(0x08, caller()), choice))
        }
    }

    function createVoteMemory(Choices choice)
        external
        view
        returns (Vote memory result)
    {
        assembly {
            mstore(result, choice)
            mstore(add(result, 0x20), caller())
        }
    }

    // votes array - 0x01 slot
    function votes(uint256) external view returns (Vote memory result) {
        assembly {
            let index := calldataload(0x04)
            if iszero(lt(index, sload(0x01))) {
                // bytes4(keccak256("Panic(uint256)"))
                mstore(0x00, shl(0xe0, 0x4e487b71))
                mstore(0x04, 0x32)
                revert(0x00, 0x24)
            }

            mstore(0x00, 0x01)
            let slot := sload(add(keccak256(0x00, 0x20), index))
            mstore(result, and(slot, 0xff))
            mstore(add(result, 0x20), shr(0x08, slot))
        }
    }

    function createVote(Choices choice) external {
        if (hasVoted(msg.sender)) {
            assembly {
                revert(0x00, 0x00)
            }
        }
        assembly {
            let currentLength := sload(0x01)
            mstore(0x00, 0x01)
            let slot := add(keccak256(0x00, 0x20), currentLength)

            sstore(0x01, add(currentLength, 0x01))
            sstore(slot, or(shl(0x08, caller()), choice))
        }
    }

    function findChoice(address addr) external view returns (Choices result) {
        assembly {
            for {
                let length := sload(0x01)
                let i := 0x00
                mstore(0x00, 0x01)
                let slot := keccak256(0x00, 0x20)
                let value := 0x00
            } lt(i, length) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            } {
                value := sload(slot)
                if eq(addr, shr(0x08, value)) {
                    i := length
                    result := and(value, 0xff)
                }
            }
        }
    }

    function hasVoted(address addr) public view returns (bool result) {
        assembly {
            for {
                let length := sload(0x01)
                let i := 0x00
                mstore(0x00, 0x01)
                let slot := keccak256(0x00, 0x20)
                let value := 0x00
            } lt(i, length) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            } {
                if eq(addr, shr(0x08, sload(slot))) {
                    i := length
                    result := 0x01
                }
            }
        }
    }

    function changeVote(Choices choice) external {
        assembly {
            let success := 0x00
            for {
                let length := sload(0x01)
                let i := 0x00
                mstore(0x00, 0x01)
                let slot := keccak256(0x00, 0x20)
                let value := 0x00
            } lt(i, length) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            } {
                value := sload(slot)
                if eq(caller(), shr(0x08, value)) {
                    i := length
                    sstore(slot, or(and(value, not(0xff)), choice))
                    success := 0x01
                }
            }

            if iszero(success) {
                revert(0x00, 0x00)
            }
        }
    }
}
