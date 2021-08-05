# hackweek

## Developer Setup

To deploy the contract, run the following:

```bash
npx truffle deploy
```

Next, use `./build/contracts/GatchaRoller.json` in your drizzle contracts.

## Invoking smart contracts

Smart contracts can be invoked using `npx truffle console`.

This will give 420 roll tokens to the 2nd account in the accounts array.

```
let instance = await GatchaRoller.deployed()
instance.vendRollToken(accounts[1], 420)
```
