// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Mappings {
    // mapping(address => bool) public members; 0x00 slot
    function addMember(address) external {
        assembly {
            mstore(0x00, calldataload(0x04))
            // mstore(0x20, 0x00)
            sstore(keccak256(0x00, 0x40), 0x01)
        }
    }

    function isMember(address) external view returns (bool result) {
        assembly {
            mstore(0x00, calldataload(0x04))
            // mstore(0x20, 0x00)
            result := sload(keccak256(0x00, 0x40))
        }
    }

    function removeMember(address) external {
        assembly {
            mstore(0x00, calldataload(0x04))
            // mstore(0x20, 0x00)
            sstore(keccak256(0x00, 0x40), 0x00)
        }
    }

    struct User {
        uint256 balance;
        bool isActive;
    }

    // mapping(address => User) public users; 0x01 slot
    function users(address) external view returns (User memory result) {
        assembly {
            mstore(0x00, calldataload(0x04))
            mstore(0x20, 0x01)
            let slot := keccak256(0x00, 0x40)
            mstore(result, sload(slot))
            mstore(add(result, 0x20), sload(add(slot, 0x01)))
        }
    }

    function createUser() external {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, 0x01)
            let balanceSlot := keccak256(0x00, 0x40)
            let isActiveSlot := add(balanceSlot, 0x01)
            if sload(isActiveSlot) {
                revert(0x00, 0x00)
            }
            sstore(balanceSlot, 100)
            sstore(isActiveSlot, 1)
        }
    }

    function transfer(address, uint256) external {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, 0x01)
            let slotOwner := keccak256(0x00, 0x40)
            mstore(0x00, calldataload(0x04))
            let slotRecipient := keccak256(0x00, 0x40)
            if or(
                iszero(sload(add(slotOwner, 0x01))),
                iszero(sload(add(slotRecipient, 0x01)))
            ) {
                revert(0x00, 0x00)
            }
            let amount := calldataload(0x24)
            if lt(sload(slotOwner), amount) {
                revert(0x00, 0x00)
            }
            sstore(slotOwner, sub(sload(slotOwner), amount))
            sstore(slotRecipient, add(sload(slotRecipient), amount))
        }
    }

    enum ConnectionTypes {
        Unacquainted,
        Friend,
        Family
    }

    // mapping(address => mapping(address => ConnectionTypes)) public connections; 0x02 slot
    function connections(address, address)
        external
        view
        returns (ConnectionTypes result)
    {
        assembly {
            mstore(0x00, calldataload(0x04))
            mstore(0x20, 0x02)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, calldataload(0x24))
            result := sload(keccak256(0x00, 0x40))
        }
    }

    function connectWith(address, ConnectionTypes) external {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, 0x02)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, calldataload(0x04))
            sstore(keccak256(0x00, 0x40), calldataload(0x24))
        }
    }
}
