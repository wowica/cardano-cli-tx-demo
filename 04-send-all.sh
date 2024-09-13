#!/bin/bash

# The goal of this script is to send all ADA from
# one address to another

destADDR=""
payorUTXO=""
totalAmountInUTXO=""
txSignatory=""

# First, run this script with fee value empty so that fee
# can be calculated and printed to the screen.
# Then, populate this variable with the amount displayed
# and run script again.
fee=""

############################################################################
## No need to modify code below when following directions from the README ##
############################################################################

amountInLL=$((totalAmountInUTXO-fee))

if [[ "$fee" -le 0 ]]; then
  tmpFile=$(mktemp)

  # Check for the presence of protocol.json.
  # This file is needed in order to calculate the fee for the transaction.
  # In case it's not present, then download it.
  if [ ! -f protocol.json ]; then
    cardano-cli query protocol-parameters --out-file protocol.json --testnet-magic 1
  fi

  echo "Tx Fee: "

  # For the sake of simplicity, this script does not accurately calculate tx fee.
  # See comment below for proper way to caculate fee.
  # https://github.com/IntersectMBO/cardano-cli/issues/827#issuecomment-2214328286

  cardano-cli transaction build-raw \
    --tx-in $payorUTXO \
    --tx-out "$destADDR $totalAmountInUTXO lovelace" \
    --fee 0 \
    --out-file $tmpFile

  cardano-cli transaction calculate-min-fee \
      --testnet-magic 1 \
      --tx-body-file $tmpFile \
      --tx-in-count 1 \
      --tx-out-count 1 \
      --witness-count 1 \
      --protocol-params-file protocol.json

  exit 0
fi

tmpRaw=$(mktemp)

cardano-cli transaction build-raw \
  --tx-in $payorUTXO \
  --tx-out "$destADDR $amountInLL lovelace" \
  --fee $fee \
  --out-file $tmpRaw

[ $? -eq 0 ]  || { echo "Error building transaction"; exit 1; }

tmpSig=$(mktemp)

cardano-cli transaction sign \
  --tx-body-file $tmpRaw \
  --signing-key-file $txSignatory \
  --testnet-magic 1 \
  --out-file $tmpSig

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file $tmpSig

cardano-cli transaction txid --tx-file $tmpSig
