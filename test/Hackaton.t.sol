// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Hackathon} from "src/Hackaton.sol";

contract HackathonTest is Test {
    function test() external {
        Hackathon hack = new Hackathon();

        hack.newProject("Winner");

        hack.rate(0, 1);
        hack.rate(0, 2);
        hack.rate(0, 3);

        hack.newProject("Loser");
        hack.rate(1, 1);
        hack.rate(1, 2);

        Hackathon.Project memory winner = hack.findWinner();

        console2.logString(winner.title);
        assertEq(winner.title, "Winner");
    }
}
