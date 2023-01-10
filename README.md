# Cardano CLI TX Demo

This is a simple demo showing different ways to use the `cardano-cli` to transfer ADA.

## Generating Addresses

The following list of commands will generate the necessary keys and addresses which will be used to run the demo.

```bash
$ cd wallets
$ ./00-generate-keys-and-addr.sh 01
$ ./00-generate-keys-and-addr.sh 02
$ ./00-generate-keys-and-addr.sh 03
$ ./00-generate-keys-and-addr.sh 04
```


## Protocol Params

```bash
$ cardano-cli query protocol-parameters --out-file protocol.json --testnet-magic 1
```
