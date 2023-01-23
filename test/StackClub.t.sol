// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {StackClub} from "src/StackClub.sol";

contract SendingEtherTest is Test {
    StackClub private stackClub;
    address private owner;
    address private tester1;

    function setUp() external {
        owner = vm.addr(1);
        tester1 = vm.addr(2);
        vm.label(owner, "owner");
        vm.label(tester1, "tester1");

        vm.prank(owner, owner);
        stackClub = new StackClub();
    }

    function testState() external {
        vm.expectRevert(stdError.indexOOBError);
        stackClub.members(1);

        assertEq(stackClub.members(0), owner);
        assertTrue(stackClub.isMember(owner));
    }

    function testAddAndRemove() external {
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
