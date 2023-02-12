// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Events} from "src/Events.sol";

contract EventsTest is Test {
    event Deployed(address indexed deployer);
    event Transfer(address indexed oldOwner, address indexed newOwner);
    event ForSale(uint256 price, uint256 timestamp);
    event Purchase(uint256 purchaseAmount, address indexed buyer);

    Events private events;
    address private owner;
    address private tester1;

    function setUp() external {
        owner = makeAddr("owner");
        tester1 = makeAddr("tester1");

        vm.prank(owner, owner);
        events = new Events();
    }

    function testState() external {
        assertEq(events.owner(), owner);

        vm.expectEmit(true, true, true, true);
        emit Deployed(owner);
        vm.prank(owner, owner);
        new Events();
    }

    function testTransfer() external {
        vm.expectRevert();
        events.transfer(tester1);

        vm.expectEmit(true, true, true, true);
        emit Transfer(owner, tester1);
        vm.prank(owner, owner);
        events.transfer(tester1);
    }

    function testSale() external {
        assertFalse(events.forSale());
        assertEq(events.price(), 0);

        vm.prank(tester1, tester1);
        vm.expectRevert();
        events.purchase();

        vm.expectRevert();
        events.markPrice(42);

        vm.expectEmit(true, true, true, true);
        emit ForSale(42, block.timestamp);
        vm.prank(owner, owner);
        events.markPrice(42);

        vm.expectRevert();
        events.purchase();

        uint256 balanceBefore = owner.balance;

        vm.deal(tester1, 100);
        vm.expectEmit(true, true, true, true);
        emit Purchase(42, tester1);
        vm.prank(tester1, tester1);
        events.purchase{value: 42}();

        assertEq(owner.balance - balanceBefore, 42);
    }
}
