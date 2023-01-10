#!/bin/bash

# Takes one argument and generates verification key, 
# signing key and preprod testnet address.

if [[ ! $# -gt 0 ]]; then
  echo "Missing wallet name as argument" && exit 1
fi

keyName=$1

cardano-cli address key-gen \
  --verification-key-file $keyName.vkey \
  --signing-key-file $keyName.skey

cardano-cli address build \
  --payment-verification-key-file $keyName.vkey \
  --out-file $keyName.addr --testnet-magic 1

cardano-cli address key-hash \
  --payment-verification-key-file $keyName.vkey \
  --out-file $keyName.pkh

echo "Generated files:"
ls -l wallets | grep -i $keyName

