// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Party} from "src/Party.sol";

contract PartyTest is Test {
    function testParty() external {
        address deployer = makeAddr("deployer");
        address tester1 = makeAddr("tester1");
        address tester2 = makeAddr("tester2");

        vm.deal(deployer, 1 ether);
        vm.deal(tester1, 1 ether);
        vm.deal(tester2, 1 ether);

        vm.prank(deployer, deployer);
        Party party = new Party(0.2 ether);

        assertEq(party.depositAmount(), 0.2 ether);
        vm.expectRevert(stdError.indexOOBError);
        party.party(0);

        vm.startPrank(deployer, deployer);

        party.rsvp{value: 0.2 ether}();

        vm.expectRevert();
        party.rsvp{value: 0.3 ether}();

        vm.expectRevert();
        party.rsvp{value: 0.2 ether}();

        vm.stopPrank();

        assertEq(party.party(0), deployer);

        vm.prank(tester1, tester1);
        party.rsvp{value: 0.2 ether}();

        vm.prank(tester2, tester2);
        party.rsvp{value: 0.2 ether}();

        uint256[4] memory balancesBefore;
        balancesBefore[0] = address(this).balance;
        balancesBefore[1] = deployer.balance;
        balancesBefore[2] = tester1.balance;
        balancesBefore[3] = tester2.balance;

        party.payBill(address(this), 0.3 ether);

        assertEq(address(this).balance - balancesBefore[0], 0.3 ether);
        assertEq(deployer.balance - balancesBefore[1], 0.1 ether);
        assertEq(tester1.balance - balancesBefore[2], 0.1 ether);
        assertEq(tester2.balance - balancesBefore[3], 0.1 ether);
    }

    receive() external payable {}
}
