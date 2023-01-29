// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {StackClub} from "src/StackClub.sol";

contract SendingEtherTest is Test {
    function testAddAndRemove() external {
        address owner = makeAddr("owner");
        address tester1 = makeAddr("tester1");

        vm.prank(owner, owner);
        StackClub stackClub = new StackClub();

        vm.expectRevert(stdError.indexOOBError);
        stackClub.members(1);

        assertEq(stackClub.members(0), owner);
        assertTrue(stackClub.isMember(owner));

        vm.expectRevert();
        stackClub.addMember(tester1);

        vm.expectRevert();
        stackClub.removeLastMember();

        vm.prank(owner, owner);
        stackClub.addMember(tester1);

        assertEq(stackClub.members(1), tester1);
        assertTrue(stackClub.isMember(tester1));

        vm.prank(owner, owner);
        vm.expectRevert();
        stackClub.addMember(tester1);

        vm.prank(owner, owner);
        stackClub.removeLastMember();

        assertFalse(stackClub.isMember(tester1));
    }
}
