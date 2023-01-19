// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/26-DoubleEntryPoint/DoubleEntryPointFactory.sol";
import "../src/26-DoubleEntryPoint/DetectionBot.sol";
import "../src/Ethernaut.sol";

contract DoubleEntryPointTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testDoubleEntryPoint() public {
        // Level Setup
        DoubleEntryPointFactory doubleEntryPointFactory = new DoubleEntryPointFactory();
        ethernaut.registerLevel(doubleEntryPointFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(doubleEntryPointFactory);
        DoubleEntryPoint ethernautDoubleEntryPoint = DoubleEntryPoint(payable(levelAddress));
        address vault = ethernautDoubleEntryPoint.cryptoVault();

        // Level Attack
        DetectionBot bot = new DetectionBot(vault);
        Forta forta = ethernautDoubleEntryPoint.forta();
        forta.setDetectionBot(address(bot));
        
        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}