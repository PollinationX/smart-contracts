
# Hardhat For Dummies

Build SmartContract

```bash
npx hardhat clean
npx hardhat compile
```

Deploy SmartContract
```bash
npx hardhat run scripts/deploy.js --network networkName (mainnet, testnet, mumbai,..)
```
Verify SmartContract
```bash
npx hardhat verify CONTRACT_ADDRESS --network networkName
```

Verify SmartContract with parameters in constructor
```bash
npx hardhat verify CONTRACT_ADDRESS --network networkName “param1” “param2” “param3”
```

Run tests
```bash
npx hardhat test --network networkName
```

