// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {LearningRevert} from "src/LearningRevert.sol";

contract LearningRevertTest is Test {
    LearningRevert private learningRevert;
    address private owner;

    function setUp() external {
        owner = vm.addr(1);
        vm.label(owner, "owner");

        vm.deal(owner, 3 ether);
        vm.prank(owner, owner);
        learningRevert = new LearningRevert{value: 1 ether}();
    }

    function testConstructorRevert() external {
        vm.expectRevert();
        vm.prank(owner, owner);
        new LearningRevert{value: 0.9 ether}();
    }

    function testState() external {
        assertEq(learningRevert.owner(), owner);
    }

    function testWithdraw() external {
        vm.expectRevert();
        vm.prank(vm.addr(2), vm.addr(2));
        learningRevert.withdraw();

        vm.prank(owner, owner);
        learningRevert.withdraw();

        assertEq(address(learningRevert).balance, 0);
    }
}
