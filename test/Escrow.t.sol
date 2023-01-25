// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Escrow} from "src/Escrow.sol";

contract EscrowTest is Test {
    event Approved(uint256 balance);

    Escrow private escrow;
    address private depositor;
    address private beneficiary;
    address private arbiter;

    function setUp() external {
        depositor = makeAddr("depositor");
        beneficiary = makeAddr("beneficiary");
        arbiter = makeAddr("arbiter");

        vm.deal(depositor, 2 ether);
        vm.prank(depositor, depositor);
        escrow = new Escrow{value: 1 ether}(beneficiary, arbiter);
    }

    function testState() external {
        assertEq(escrow.depositor(), depositor);
        assertEq(escrow.beneficiary(), beneficiary);
        assertEq(escrow.arbiter(), arbiter);
        assertFalse(escrow.isApproved());
    }

    function testApprove() external {
        vm.expectRevert();
        escrow.approve();

        uint256 balanceBefore = beneficiary.balance;

        vm.expectEmit(true, true, true, true);
        emit Approved(1 ether);
        vm.prank(arbiter, arbiter);
        escrow.approve();

        assertTrue(escrow.isApproved());
        assertEq(beneficiary.balance - balanceBefore, 1 ether);
    }
}
