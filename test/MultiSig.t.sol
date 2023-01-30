// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {MultiSig} from "src/MultiSig.sol";

contract MultiSigTest is Test {
    uint256 helper;

    function test() external {
        address owner = makeAddr("owner");
        address owner1 = makeAddr("owner1");
        address owner2 = makeAddr("owner2");

        address[] memory owners = new address[](3);
        owners[0] = owner;
        owners[1] = owner1;
        owners[2] = owner2;

        vm.prank(owner, owner);
        MultiSig multiSig = new MultiSig(owners, 2);

        (bool success, ) = address(multiSig).call{value: 1 ether}("");
        require(success);

        vm.expectRevert();
        new MultiSig(new address[](0), 1);
        vm.expectRevert();
        new MultiSig(owners, 0);

        assertEq(multiSig.required(), 2);
        assertEq(multiSig.transactionCount(), 0);
        for (uint256 i; i < 3; ++i) {
            assertEq(multiSig.owners(i), owners[i]);
        }

        // ether transaction
        vm.expectRevert();
        multiSig.submitTransaction(address(this), 0.5 ether, "");

        vm.prank(owner, owner);
        multiSig.submitTransaction(address(this), 0.5 ether, "");

        assertEq(multiSig.transactionCount(), 1);
        (
            bool executed,
            address aim,
            uint256 value,
            bytes memory data
        ) = multiSig.transactions(0);
        assertFalse(executed);
        assertEq(aim, address(this));
        assertEq(value, 0.5 ether);
        assertEq(multiSig.getConfirmationsCount(0), 1);
        assertTrue(multiSig.confirmations(0, owner));

        vm.expectRevert();
        multiSig.confirmTransaction(0);

        uint256 balanceBefore = address(this).balance;
        vm.prank(owner1, owner1);
        multiSig.confirmTransaction(0);
        assertEq(address(this).balance - balanceBefore, 0.5 ether);
        (executed, aim, value, data) = multiSig.transactions(0);
        assertTrue(executed);

        vm.expectRevert();
        vm.prank(owner2, owner2);
        multiSig.confirmTransaction(0);

        // call transaction
        vm.prank(owner2, owner2);
        multiSig.submitTransaction(
            address(this),
            0,
            abi.encodeWithSignature("setHelper()")
        );
        (executed, aim, value, data) = multiSig.transactions(1);
        assertEq(data, abi.encodeWithSignature("setHelper()"));

        assertEq(helper, 0);
        vm.prank(owner1, owner1);
        multiSig.confirmTransaction(1);
        assertEq(helper, 42);
    }

    function setHelper() external {
        helper = 42;
    }

    receive() external payable {}
}
