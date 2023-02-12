// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {SendingEther} from "src/SendingEther.sol";

contract SendingEtherTest is Test {
    SendingEther private sendingEther;
    address private owner;
    address private charity;
    address private tipper;

    function setUp() external {
        owner = makeAddr("owner");
        charity = makeAddr("charity");
        tipper = makeAddr("tipper");

        vm.prank(owner, owner);
        sendingEther = new SendingEther(charity);
    }

    function testState() external {
        assertEq(sendingEther.owner(), owner);
        assertEq(sendingEther.charity(), charity);
    }

    function testReceive() external {
        (bool success, ) = address(sendingEther).call{value: 1 ether}("");
        require(success);
        assertEq(address(sendingEther).balance, 1 ether);
    }

    function testTip() external {
        uint256 balanceBefore = owner.balance;

        vm.deal(tipper, 1 ether);
        vm.prank(tipper, tipper);
        sendingEther.tip{value: 0.5 ether}();

        assertEq(owner.balance - balanceBefore, 0.5 ether);
    }

    function testDonate() external {
        uint256 balanceBefore = charity.balance;

        vm.deal(owner, 1 ether);
        vm.prank(owner, owner);
        (bool success, ) = address(sendingEther).call{value: 1 ether}("");
        require(success);

        sendingEther.donate();

        assertEq(charity.balance - balanceBefore, 1 ether);
    }
}
