#!/bin/bash

########################################################
### Sends ADA from one address to multiple addresses ###
########################################################

# Enter the UTXO which ADA + transaction fees
# will be spent from
payorUTXO=""

# Amount in ADA which will be converted to lovelace
amountInADA1=20
amountInADA2=22
# Addresses ADA will be sent to
destinationADDR1="$()"
destinationADDR2="$()"
# Address for change
payorADDR=$()
# Signature file of sender
txSignatory=""

####################################
### No need to change code below ###
####################################

tmpBuild=$(mktemp)

cardano-cli conway transaction build \
  --testnet-magic 1 \
  --tx-in $payorUTXO \
  --tx-out "$destinationADDR1 $(($amountInADA1*1000000)) lovelace" \
  --tx-out "$destinationADDR2 $(($amountInADA2*1000000)) lovelace" \
  --change-address $payorADDR \
  --out-file $tmpBuild

[ $? -eq 0 ]  || { echo "Error building transaction"; exit 1; }

tmpSig=$(mktemp)

cardano-cli transaction sign \
  --testnet-magic 1 \
  --tx-body-file $tmpBuild \
  --signing-key-file $txSignatory \
  --out-file $tmpSig

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file $tmpSig

cardano-cli transaction txid --tx-file $tmpSig
