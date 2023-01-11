#!/bin/bash

#########################################
### Sends ADA from 01.addr to 02.addr ###
#########################################

# Enter the UTXO under 01.addr which ADA will be spent from
payorUTXO=""

############################################################################
## No need to modify code below when following directions from the README ##
############################################################################

# Amount in ADA which will be converted to lovelace
amountInADA=5
# Address for change
payorADDR=$(cat wallets/01.addr)
destinationADDR="$(cat wallets/02.addr)"

tmpBuild=$(mktemp)

cardano-cli transaction build \
  --testnet-magic 1 \
  --change-address $payorADDR \
  --tx-in $payorUTXO \
  --tx-out "$destinationADDR $(($amountInADA*1000000)) lovelace" \
  --out-file $tmpBuild

[ $? -eq 0 ]  || { echo "Error building transaction"; exit 1; }

echo "banana"

tmpSig=$(mktemp)

cardano-cli transaction sign \
  --tx-body-file $tmpBuild \
  --signing-key-file wallets/01.skey \
  --testnet-magic 1 \
  --out-file $tmpSig

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file $tmpSig

cardano-cli transaction txid --tx-file $tmpSig
