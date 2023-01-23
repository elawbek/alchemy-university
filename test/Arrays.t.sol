// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Arrays} from "src/Arrays.sol";

contract ArraysTest is Test {
    Arrays private arrays;

    function setUp() external {
        arrays = new Arrays();
    }

    function testSums() external {
        uint256[5] memory a;
        a[0] = 1;
        a[1] = 2;
        a[2] = 3;
        a[3] = 4;
        a[4] = 5;
        assertEq(arrays.sum(a), 15);

        uint256[] memory b = new uint256[](5);
        b[0] = 2;
        b[1] = 3;
        b[2] = 4;
        b[3] = 5;
        b[4] = 6;
        assertEq(arrays.sum(b), 20);
    }

    function testFilterEven() external {
        uint256[] memory b = new uint256[](5);
        b[0] = 2;
        b[1] = 3;
        b[2] = 4;
        b[3] = 5;
        b[4] = 6;

        uint256[] memory result = new uint256[](3);
        result[0] = 2;
        result[1] = 4;
        result[2] = 6;

        vm.expectRevert(stdError.indexOOBError);
        arrays.evenNumbers(0);

        arrays.filterEvenToStorage(b);

        uint256[] memory resultToMemory = arrays.filterEvenToMemory(b);

        for (uint256 i; i < 3; ++i) {
            assertEq(arrays.evenNumbers(i), result[i]);
            assertEq(resultToMemory[i], result[i]);
        }
    }
}
