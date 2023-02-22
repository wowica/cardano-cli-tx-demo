#!/bin/bash

# Takes one argument and generates the following for
# use with Preprod Testnet (--testnet-magic 1)
#
# 1- Verification key
# 2- Signing key
# 3- Address (preprod testnet)

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
