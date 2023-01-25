// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Structs, Choices, Vote} from "src/Structs.sol";

contract StructsTest is Test {
    Structs private structs;
    address private owner;
    address private tester1;

    function setUp() external {
        owner = makeAddr("owner");
        tester1 = makeAddr("tester1");

        vm.prank(owner, owner);
        structs = new Structs();
    }

    function testSingleVote() external {
        vm.prank(owner, owner);
        structs.createVoteStorage(Choices.No);

        Vote memory voteStorage = structs.vote();
        assertEq(voteStorage.voter, owner);
        assertEq(uint8(voteStorage.choice), uint8(Choices.No));

        vm.prank(owner, owner);
        Vote memory voteMemory = structs.createVoteMemory(Choices.Yes);
        assertEq(voteMemory.voter, owner);
        assertEq(uint8(voteMemory.choice), uint8(Choices.Yes));
    }

    function testVotesArray() external {
        vm.expectRevert();
        structs.votes(0);

        assertFalse(structs.hasVoted(owner));

        vm.startPrank(owner, owner);

        structs.createVote(Choices.Yes);
        assertTrue(structs.hasVoted(owner));

        vm.expectRevert();
        structs.createVote(Choices.Yes);

        Vote memory ownerVote = structs.votes(0);
        assertEq(ownerVote.voter, owner);
        assertEq(uint8(ownerVote.choice), uint8(Choices.Yes));

        structs.changeVote(Choices.No);
        ownerVote = structs.votes(0);
        assertEq(uint8(ownerVote.choice), uint8(Choices.No));

        vm.stopPrank();

        vm.prank(tester1, tester1);
        structs.createVote(Choices.No);
        Choices choice = structs.findChoice(tester1);
        assertEq(uint8(choice), uint8(Choices.No));
    }
}
