
![](cover.png)

# Damn Vulnerable DeFi - Foundry Edition

**A set of challenges to learn offensive security of smart contracts in Ethereum.**

This repository is a Foundry-based implementation of the original [Damn Vulnerable DeFi](https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0) project. The challenges feature flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks, and more!

## Play

Visit [damnvulnerabledefi.xyz](https://damnvulnerabledefi.xyz) to access the challenges.


## How to Use

This repository uses Foundry for running tests and interacting with smart contracts. Follow the instructions below to get started:

### Prerequisites

- Install [Foundry](https://getfoundry.sh/).

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/EbiPenMan/damn-vulnerable-defi-foundry
   cd damn-vulnerable-defi-foundry
   ```

2. Install dependencies:
   ```sh
   forge install
   ```

### How to play

- Code your solution in the *.t.sol file (inside each challenge's folder in the test folder)
- You only need to write your solution in the `_execution` method and run the test.
- Run the challenge with `forge test --match-test test{challenge-name}`. If the test is executed successfully, you've passed!


### Tips
- To code the solutions, you may need to read [Foundry](https://book.getfoundry.sh/getting-started/installation) docs.
- In all challenges you must use the account called player. In `forge`, that may translate to using:
```sh
# Sets msg.sender to the `player` address for the next call.
vm.prank(player);
```
or
```sh
# Sets msg.sender for all subsequent calls until stopPrank is called.
vm.startPrank(player);
...
vm.stopPrank();
```
- Some challenges require you to code and deploy custom smart contracts that you can use [this](src/player-contracts) folder.
- Go [here](https://github.com/tinchoabbate/damn-vulnerable-defi/discussions/categories/support-q-a-troubleshooting) for troubleshooting, support and Q&A.
- If you have any problem with `converted Foundry` scripts, You can create issue in this repo.


### Running Tests

To run the specefic tests, use the following command:
```sh
forge test --match-test testUnstoppable
```

To run the all tests, use the following command:
```sh
forge test
```

## Disclaimer

All Solidity code, practices, and patterns in this repository are **DAMN VULNERABLE** and for educational purposes only.

Please note that the conversion of tests from Hardhat to Foundry and the update of dependencies may contain errors.

