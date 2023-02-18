# Ethernaut Challenges automated in Foundry

## What is Ethernaut by [OpenZeppelin](https://www.openzeppelin.com/)

[Ethernaut](https://github.com/OpenZeppelin/ethernaut) is a Web3/Solidity based war game inspired in [overthewire.org](https://overthewire.org/), to be played in the Ethereum Virtual Machine. Each level is a smart contract that needs to be 'hacked'.

The game acts both as a tool for those interested in learning Ethereum, and as a way to catalog historical hacks in levels. Levels can be infinite, and the game does not require to be played in any particular order.

Visit [https://ethernaut.openzeppelin.com/](https://ethernaut.openzeppelin.com/) for the challenges' website.

## IMPORTANT DISCLAIMER
All Solidity code in this repository is VULNERABLE and for educational purposes only.

I **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

**DO NOT USE IN PRODUCTION**.

## How to install and run this repository

### 1. Install [Foundry](https://github.com/gakonst/foundry)

```bash
curl -L https://foundry.paradigm.xyz | bash
```
Check the [Foundry Book](https://book.getfoundry.sh/) to learn more about Foundry.

### 2. Update Foundry

```bash
foundryup
```

### 3. Clone the repository and install dependencies

```bash
git clone git@github.com:rookmate/ethernaut_foundry.git
cd ethernaut_foundry
git submodule update --init --recursive
```

### 4. Run a solution

```bash
forge test --match-contract <NAME_OF_THE_TEST_CONTRACT>
# example:
#		forge test --match-contract VaultTest
```
## Notes on Alien Codex challenge
1.  Compile the AlienCodex challenge
```bash
FOUNDRY_PROFILE=0_5_x forge build --extra-output-files evm.bytecode
forge test --match-contract AlienCodexTest
```
2. Inspect the bytecode
```bash
FOUNDRY_PROFILE=0_5_x forge inspect AlienCodex bytecode
```
3. Run the test
```bash
forge test --match-contract AlienCodexTest
```
