// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Escrow} from "src/Escrow.sol";

contract EscrowTest is Test {
    event Approved(uint256 balance);

    function testApprove() external {
        address depositor = makeAddr("depositor");
        address beneficiary = makeAddr("beneficiary");
        address arbiter = makeAddr("arbiter");

        vm.deal(depositor, 2 ether);
        vm.prank(depositor, depositor);
        Escrow escrow = new Escrow{value: 1 ether}(beneficiary, arbiter);

        assertEq(escrow.depositor(), depositor);
        assertEq(escrow.beneficiary(), beneficiary);
        assertEq(escrow.arbiter(), arbiter);
        assertFalse(escrow.isApproved());

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
