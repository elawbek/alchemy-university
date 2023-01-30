// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    struct Transaction {
        bool executed;
        address aim;
        uint256 value;
        bytes data;
    }

    uint256 private _a;
    mapping(uint256 => Transaction) public transactions;

    constructor(address[] memory _owners, uint256 _required) {
        assembly {
            let length := mload(_owners) // gt 0 length is automatically checked
            if or(iszero(_required), gt(_required, length)) {
                revert(0x00, 0x00)
            }

            sstore(0x01, shl(0x80, _required))

            sstore(0x00, length)
            // mstore(0x00, 0x00)
            for {
                let i := 0x00
                let slot := keccak256(0x00, 0x20)
                _owners := add(_owners, 0x20)
            } lt(i, length) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
                _owners := add(_owners, 0x20)
            } {
                sstore(slot, mload(_owners))
            }
        }
    }

    receive() external payable {}

    // 0x00 - owners slot
    function owners(uint256) external view returns (address result) {
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

    // 0x01 - required slot
    function required() public view returns (uint256 result) {
        assembly {
            result := shr(0x80, sload(0x01))
        }
    }

    // 0x01 - transactionCount slot
    function transactionCount() public view returns (uint256 result) {
        assembly {
            result := and(sload(0x01), 0xffffffffffffffffffffffffffffffff)
        }
    }

    // 0x02 - confirmations mapping
    function confirmations(uint256, address)
        external
        view
        returns (bool result)
    {
        assembly {
            mstore(0x00, calldataload(0x04))
            mstore(0x20, 0x02) // slot
            mstore(0x20, keccak256(0x00, 0x40)) // first key slot
            mstore(0x00, calldataload(0x24))
            result := sload(keccak256(0x00, 0x20))
        }
    }

    function getConfirmationsCount(uint256 txId)
        public
        view
        returns (uint256 result)
    {
        assembly {
            if gt(
                add(txId, 0x01),
                and(sload(0x01), 0xffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }
            mstore(0x00, txId)
            mstore(0x20, 0x02) // slot
            result := sload(keccak256(0x00, 0x40))
        }
    }

    function submitTransaction(
        address _aim,
        uint256 _value,
        bytes calldata
    ) external {
        uint256 txId;
        assembly {
            let currentId := sload(0x01)
            sstore(0x01, add(currentId, 0x01))
            txId := and(currentId, 0xffffffffffffffffffffffffffffffff)
            mstore(0x00, txId)
            mstore(0x20, 0x01) // slot
            let slot := keccak256(0x00, 0x40) // key slot
            sstore(slot, shl(0x08, _aim))
            sstore(add(slot, 0x1), _value)

            let dataLen := calldataload(0x64)
            if gt(dataLen, 0x1f) {
                sstore(add(slot, 0x02), add(add(dataLen, dataLen), 0x01))

                for {
                    let length := add(div(dataLen, 0x20), 0x01)
                    let i := 0x00
                    mstore(0x00, add(slot, 0x02))
                    let dataSlot := keccak256(0x00, 0x20)
                    let offset := 0x84
                } lt(i, length) {
                    i := add(i, 0x01)
                    dataSlot := add(dataSlot, 0x01)
                    offset := add(offset, 0x20)
                } {
                    sstore(dataSlot, calldataload(offset))
                }
            }

            if lt(dataLen, 0x20) {
                sstore(
                    add(slot, 0x02),
                    or(calldataload(0x84), add(dataLen, dataLen))
                )
            }
        }
        confirmTransaction(txId);
    }

    function confirmTransaction(uint256 txId) public {
        assembly {
            if gt(
                add(txId, 0x01),
                and(sload(0x01), 0xffffffffffffffffffffffffffffffff)
            ) {
                revert(0x00, 0x00)
            }

            let success := 0x00
            for {
                let length := sload(0x00)
                let i := 0x00
                mstore(0x00, 0x00)
                let ownersSlot := keccak256(0x00, 0x20)
            } lt(i, length) {
                i := add(i, 0x01)
                ownersSlot := add(ownersSlot, 0x01)
            } {
                if eq(sload(ownersSlot), caller()) {
                    i := length
                    success := 0x01
                }
            }

            if iszero(success) {
                revert(0x00, 0x00)
            }

            mstore(0x00, txId)
            mstore(0x20, 0x02) // slot
            let slot := keccak256(0x00, 0x40) // first key slot
            sstore(slot, add(sload(slot), 0x01))
            mstore(0x20, slot)
            mstore(0x00, caller())
            sstore(keccak256(0x00, 0x20), 0x01)
        }

        if (isConfirmed(txId)) {
            executeTransaction(txId);
        }
    }

    function executeTransaction(uint256 txId) internal {
        assembly {
            mstore(0x00, txId)
            mstore(0x20, 0x01) // slot
            let slot := keccak256(0x00, 0x40) // key slot
            let firstEl := sload(slot)
            if and(firstEl, 0xff) {
                revert(0x00, 0x00) // already executed
            }
            sstore(slot, add(firstEl, 0x01))

            let dataLen := sload(add(slot, 0x02))
            mstore(0x00, shr(0x01, and(dataLen, 0x0f)))
            mstore(0x20, and(dataLen, not(0xff)))
            if and(dataLen, 0x01) {
                mstore(0x00, shr(0x01, dataLen))

                for {
                    let length := add(div(mload(0x00), 0x20), 0x01)
                    let i := 0x00
                    mstore(0x20, add(slot, 0x02))
                    let dataSlot := keccak256(0x20, 0x20)
                    let offset := 0x20
                } lt(i, length) {
                    i := add(i, 0x01)
                    dataSlot := add(dataSlot, 0x01)
                    offset := add(offset, 0x20)
                } {
                    mstore(offset, sload(dataSlot))
                }
            }

            if iszero(
                call(
                    gas(),
                    shr(0x08, firstEl),
                    sload(add(slot, 0x01)),
                    0x20,
                    mload(0x00),
                    0x00,
                    0x00
                )
            ) {
                revert(0x00, 0x00)
            }
        }
    }

    function isConfirmed(uint256 txId) internal view returns (bool result) {
        result = getConfirmationsCount(txId) >= required();
    }
}
