<!-- ![](cover.png) -->

```solidity

______                        _   _       _                      _     _       ______    ______ _
|  _  \                      | | | |     | |                    | |   | |      |  _  \   |  ___(_)
| | | |__ _ _ __ ___  _ __   | | | |_   _| |_ __   ___ _ __ __ _| |__ | | ___  | | | |___| |_   _
| | | / _` | '_ ` _ \| '_ \  | | | | | | | | '_ \ / _ | '__/ _` | '_ \| |/ _ \ | | | / _ |  _| | |
| |/ | (_| | | | | | | | | | \ \_/ | |_| | | | | |  __| | | (_| | |_) | |  __/ | |/ |  __| |   | |
|___/ \__,_______| |_|_| |_|  \___/ \__,_|_|_| |_|\______  \__,_|_.___|_|\___| |___/ \___\_|   |_|
           |  ___|                  | |            |  ___|  | (_| | (_)
           | |_ ___  _   _ _ __   __| |_ __ _   _  | |__  __| |_| |_ _  ___  _ __
           |  _/ _ \| | | | '_ \ / _` | '__| | | | |  __|/ _` | | __| |/ _ \| '_ \
           | || (_) | |_| | | | | (_| | |  | |_| | | |__| (_| | | |_| | (_) | | | |
           \_| \___/ \__,_|_| |_|\__,_|_|   \__, | \____/\__,_|_|\__|_|\___/|_| |_|
                                             __/ |
                                            |___/

```

# Damn Vulnerable DeFi - Foundry Edition

**A set of challenges to learn offensive security of smart contracts in Ethereum.**

This repository is a Foundry-based implementation of the original
[Damn Vulnerable DeFi](https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0) project. The challenges feature
flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks, and more!

> This project is currently under development. Users should refer to the [TODO list](#todo-list) as any code not marked
> as complete has not been tested yet.

## Play

Visit [damnvulnerabledefi.xyz](https://damnvulnerabledefi.xyz) to access the challenges.

## How to Use

This repository uses Foundry for running tests and interacting with smart contracts. Follow the instructions below to
get started:

### Prerequisites

- Install [Foundry](https://getfoundry.sh/).
- Install [NodeJS](https://nodejs.org/en/download/package-manager).

### Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/EbiPenMan/foundry-damn-vulnerable-defi-v3
   cd foundry-damn-vulnerable-defi-v3
   ```

2. Install dependencies:
   ```sh
   bun install # install Solhint, Prettier, and other Node.js deps
   ```

### How to play

- Code your solution in the \*.t.sol file (inside each challenge's folder in the test folder)
- You only need to write your solution in the `_execution` method and run the test.
- Run the challenge with `forge test --match-test test{challenge-name}`. If the test is executed successfully, you've
  passed!

### Tips

- To code the solutions, you may need to read [Foundry](https://book.getfoundry.sh/getting-started/installation) docs.
- In all challenges you must use the account called player. In `forge`, that may translate to using:

```solidity
// Sets msg.sender to the `player` address for the next call.
vm.prank(player);
...
```

or

```solidity
// Sets msg.sender for all subsequent calls until stopPrank is called.
vm.startPrank(player);
...
vm.stopPrank();
```

- Some challenges require you to code and deploy custom smart contracts that you can use [this](src/player-contracts)
  folder.
- Go [here](https://github.com/tinchoabbate/damn-vulnerable-defi/discussions/categories/support-q-a-troubleshooting) for
  troubleshooting, support and Q&A.
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

### Todo List

- [x] 1: Unstoppable
- [x] 2: Naive receiver
- [x] 3: Truster
- [x] 4: Side Entrance
- [x] 5: The Rewarder
- [x] 6: Selfie
- [x] 7: Compromised
- [x] 8: Puppet V1
- [x] 9: Puppet V2
- [x] 10: Free Rider
- [ ] 11: Backdoor
- [ ] 12: Climber
- [ ] 13: Wallet Mining
- [ ] 14: Puppet V3
- [ ] 15: ABI Smuggling

## Disclaimer

All Solidity code, practices, and patterns in this repository are **DAMN VULNERABLE** and for educational purposes only.

Please note that the conversion of tests from Hardhat to Foundry and the update of dependencies may contain errors.
