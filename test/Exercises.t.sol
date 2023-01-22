// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Exercises} from "src/Exercises.sol";

contract ExercisesTest is Test {
    Exercises private exercises;

    function setUp() external {
        exercises = new Exercises();
    }

    function testSumAndAverage() external {
        (uint256 sum, uint256 avg) = exercises.sumAndAverage(1, 2, 3, 4);
        assertEq(sum, 10);
        assertEq(avg, 2);
    }
}
