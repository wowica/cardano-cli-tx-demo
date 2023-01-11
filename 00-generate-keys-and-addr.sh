#!/bin/bash

# Takes one argument and generates verification key, 
# signing key and preprod testnet address.

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

cardano-cli address key-hash \
  --payment-verification-key-file wallets/$keyName.vkey \
  --out-file wallets/$keyName.pkh

echo "Generated files in wallets folder:"
ls -l wallets | grep -i $keyName
