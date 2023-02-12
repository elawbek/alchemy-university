// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Events {
    event Deployed(address indexed deployer);
    event Transfer(address indexed oldOwner, address indexed newOwner);
    event ForSale(uint256 price, uint256 timestamp);
    event Purchase(uint256 purchaseAmount, address indexed buyer);

    constructor() {
        assembly {
            sstore(0x00, caller())
            log2(
                0x00,
                0x00,
                0xf40fcec21964ffb566044d083b4073f29f7f7929110ea19e1b3ebe375d89055e, // keccak256("Deployed(address)")
                caller()
            )
        }
    }

    // 0x00 - owner slot
    function owner() external view returns (address result) {
        assembly {
            result := sload(0x00)
        }
    }

    // 0x01 - price slot
    function price() external view returns (uint256 result) {
        assembly {
            result := sload(0x01)
        }
    }

    // 0x02 - forSale slot
    function forSale() external view returns (bool result) {
        assembly {
            result := sload(0x02)
        }
    }

    function transfer(address) external {
        assembly {
            if iszero(eq(caller(), sload(0x00))) {
                revert(0x00, 0x00)
            }
            let newOwner := calldataload(0x04)
            sstore(0x00, newOwner)
            log3(
                0x00,
                0x00,
                0x4853ae1b4d437c4255ac16cd3ceda3465975023f27cb141584cd9d44440fed82, // keccak256("Transfer(address,address)")
                caller(),
                newOwner
            )
        }
    }

    function markPrice(uint256) external {
        assembly {
            if iszero(eq(caller(), sload(0x00))) {
                revert(0x00, 0x00)
            }
            let amount := calldataload(0x04)
            sstore(0x01, amount)
            sstore(0x02, 0x01)
            mstore(0x00, amount)
            mstore(0x20, timestamp())
            log1(
                0x00,
                0x40,
                0x454a59b1e51b1685e697faeca2a404382f4dcb9970aece78299147857e150393 // keccak256("ForSale(uint256,uint256)")
            )
        }
    }

    function purchase() external payable {
        assembly {
            if iszero(eq(callvalue(), sload(0x01))) {
                revert(0x00, 0x00)
            }
            if iszero(sload(0x02)) {
                revert(0x00, 0x00)
            }
            if iszero(
                call(gas(), sload(0x00), callvalue(), 0x00, 0x00, 0x00, 0x00)
            ) {
                revert(0x00, 0x00)
            }
            sstore(0x00, caller())
            sstore(0x02, 0x00)
            mstore(0x00, callvalue())
            log2(
                0x00,
                0x20,
                0x6b8e277b5ac199aea04139b79dce59b078ad22c9648f1bd3083495991809b770, // keccak256("Purchase(uint256,address)")
                caller()
            )
        }
    }
}
