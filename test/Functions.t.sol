// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Functions} from "src/Functions.sol";

contract FunctionsTest is Test {
    Functions private functions;

    function setUp() external {
        functions = new Functions(42);
    }

    function testIncrement() external {
        functions.increment();
        assertEq(functions.value(), 43);
    }

    function testAdd() external {
        assertEq(functions.add(24), 66);
    }

    function testDouble() external {
        assertEq(functions.double(42), 84);

        (uint256 res1, uint256 res2) = functions.double(42, 24);
        assertEq(res1, 84);
        assertEq(res2, 48);
    }
}
