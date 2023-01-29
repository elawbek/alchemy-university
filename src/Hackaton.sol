// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Hackathon {
    struct Project {
        string title;
        uint256[] ratings;
    }

    Project[] projects;

    function findWinner() external view returns (Project memory result) {
        uint256 winnerIndex;
        assembly {
            let projectsLength := sload(0x00)
            if iszero(projectsLength) {
                // bytes4(keccak256("Panic(uint256)"))
                mstore(0x00, shl(0xe0, 0x4e487b71))
                mstore(0x04, 0x32)
                revert(0x00, 0x24)
            }

            let max := 0x00

            for {
                let i := 0x00
                // mstore(0x00, 0x00) // array slot
                let slot := add(keccak256(0x00, 0x20), 0x01) // slot for first ratings
            } lt(i, projectsLength) {
                i := add(i, 0x01)
                slot := add(slot, 0x02)
            } {
                let avg := 0x0
                let length := sload(slot)
                if gt(length, 0x00) {
                    for {
                        mstore(0x00, slot)
                        let j := 0x00
                        let ratingsSlot := keccak256(0x00, 0x20)
                    } lt(j, length) {
                        j := add(j, 0x01)
                        ratingsSlot := add(ratingsSlot, 0x01)
                    } {
                        avg := add(avg, sload(ratingsSlot))
                    }
                    avg := div(avg, length)
                    if gt(avg, max) {
                        max := avg
                        winnerIndex := i
                    }
                }
            }
        }

        result = projects[winnerIndex];
    }

    function newProject(string calldata) external {
        assembly {
            let length := sload(0x00) // array len
            let name := calldataload(add(add(0x04, calldataload(0x04)), 0x20)) // str length le 31 bytes
            // mstore(0x00, 0x00) // array slot
            let slot := add(keccak256(0x00, 0x20), shl(0x01, length)) // slot for project name
            sstore(
                slot,
                or(name, shl(0x01, calldataload(add(0x04, calldataload(0x04)))))
            )
            sstore(0x00, add(length, 0x01))
        }
    }

    function rate(uint256, uint256) external {
        assembly {
            let index := calldataload(0x04)
            if iszero(lt(index, sload(0x00))) {
                // bytes4(keccak256("Panic(uint256)"))
                mstore(0x00, shl(0xe0, 0x4e487b71))
                mstore(0x04, 0x32)
                revert(0x00, 0x24)
            }

            // mstore(0x00, 0x00) // array slot
            let slot := add(add(keccak256(0x00, 0x20), shl(0x01, index)), 0x01) // slot for project ratings
            let length := sload(slot)
            sstore(slot, add(length, 0x01)) // update length for ratings
            mstore(0x00, slot)
            slot := add(keccak256(0x00, 0x20), length)
            sstore(slot, calldataload(0x24))
        }
    }
}
