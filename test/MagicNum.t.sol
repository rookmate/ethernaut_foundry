// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/18-MagicNumber/MagicNumFactory.sol";
import "../src/Ethernaut.sol";

contract MagicNumTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testMagicNum() public {
        // Level Setup
        MagicNumFactory magicNumFactory = new MagicNumFactory();
        ethernaut.registerLevel(magicNumFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(magicNumFactory);
        MagicNum ethernautMagicNum = MagicNum(payable(levelAddress));

        // Level Attack
        /* To solve this challenge we need to deploy a smart contract that
        1) Answer 0x2a (42 in decimal) when `whatIsTheMeaningOfLife()` is called
        2) Its code must be less or equal than 10 bytes (so less than 10 instructions)

        All the EVM Opcodes info and a Playground to test your EVM bytecode: https://www.evm.codes/

        1) Create a minimal smart contract that only return 0x2a based on the link above
        EVM to make the contract return 0x2a
        1) PUSH1 0x2a
        2) PUSH1 00
        3) MSTORE
        4) PUSH1 0x20
        5) PUSH1 00
        6) RETURN
        bytecode -> 0x602A60005260206000F3

        2) Create the bytecode that will deploy the bytecode of the smart contract
        The EVM will execute the constructor code once when a smart contract is created
        In this case we are just pushing the smart contract bytecode into memory and returning it

        EVM to create a contract with the above code
        7) PUSH10 602A60005260206000F3 (runtime code)
        8) PUSH1 0
        9) MSTORE
        10) PUSH1 0A
        11) PUSH1 0x16
        12) RETURN
        bytecode -> 0x69602A60005260206000F3600052600A6016F3

        3) Deploy: https://eips.ethereum.org/EIPS/eip-1167
        Additional info: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/Clones.sol
        */
        address solver;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0x68, 0x69602A60005260206000F3600052600A6016F3))
            solver := create(0, ptr, 0x13)
        }

        emit log_named_address("Solver", solver);
        ethernautMagicNum.setSolver(solver);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}