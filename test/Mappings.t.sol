// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Mappings} from "src/Mappings.sol";

contract MappingsTest is Test {
    Mappings private mappings;
    address private owner;
    address private tester1;
    address private tester2;

    function setUp() external {
        owner = vm.addr(1);
        tester1 = vm.addr(2);
        tester2 = vm.addr(3);
        vm.label(owner, "owner");
        vm.label(tester1, "tester1");
        vm.label(tester2, "tester2");

        vm.prank(owner, owner);
        mappings = new Mappings();
    }

    function testMembersMapping() external {
        assertFalse(mappings.isMember(tester1));
        assertFalse(mappings.isMember(tester2));

        mappings.addMember(tester1);
        assertTrue(mappings.isMember(tester1));
        mappings.addMember(tester2);
        assertTrue(mappings.isMember(tester2));

        mappings.removeMember(tester2);
        assertFalse(mappings.isMember(tester2));
    }

    function testUsersMapping() external {
        Mappings.User memory one = mappings.users(tester1);
        Mappings.User memory two = mappings.users(tester2);
        assertFalse(one.isActive);
        assertFalse(two.isActive);
        assertEq(one.balance, 0);
        assertEq(two.balance, 0);

        vm.startPrank(tester1, tester1);

        mappings.createUser();
        one = mappings.users(tester1);
        assertTrue(one.isActive);
        assertEq(one.balance, 100);

        vm.expectRevert();
        mappings.createUser();

        vm.expectRevert();
        mappings.transfer(tester2, 50);

        vm.stopPrank();

        vm.prank(tester2, tester2);
        mappings.createUser();

        vm.startPrank(tester1, tester1);

        vm.expectRevert();
        mappings.transfer(tester2, 101);
        mappings.transfer(tester2, 75);

        vm.stopPrank();

        one = mappings.users(tester1);
        two = mappings.users(tester2);
        assertTrue(one.isActive);
        assertTrue(two.isActive);
        assertEq(one.balance, 25);
        assertEq(two.balance, 175);
    }

    function testConnectionsMapping() external {
        Mappings.ConnectionTypes connectionType = mappings.connections(
            tester1,
            tester2
        );
        assertEq(uint8(connectionType), 0);

        vm.prank(tester1, tester1);
        mappings.connectWith(tester2, Mappings.ConnectionTypes.Friend);

        connectionType = mappings.connections(tester1, tester2);
        assertEq(uint8(connectionType), 1);
    }
}
