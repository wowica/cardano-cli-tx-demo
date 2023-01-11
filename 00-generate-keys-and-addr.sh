#!/bin/bash

# Takes one argument and generates verification key, 
# signing key and testnet address for preprod (--testnet-magic 1)

if [[ ! $# -gt 0 ]]; then
  echo "Missing wallet name as argument" && exit 1
fi

keyName=$1

cardano-cli address key-gen \
  --verification-key-file wallets/$keyName.vkey \
  --signing-key-file wallets/$keyName.skey

cardano-cli address build \
  --payment-verification-key-file wallets/$keyName.vkey \
  --out-file wallets/$keyName.addr --testnet-magic 1

echo "Generated files in wallets folder:"
ls -l wallets | grep -i $keyName
