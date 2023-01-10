#!/bin/bash

############################################
### Sends ADA from 01.addr and 02.addr,  ###
###           to 03.addr and 04.addr     ###
############################################

# Enter the UTXOs under 01.addr and 02.addr 
# which ADA + transaction fees will be spent from
payorUTXO1=""
payorUTXO2=""

# First, run this script this value empty so that fee
# can be calculated and printed to the screen.
# Then, populate this variable with the amount displayed
# and run script again.
fee=""

############################################################################
## No need to modify code below when following directions from the README ##
############################################################################

# Amount in ADA which the two
# destination addresses will receive
amountInADA=2
# convert to Lovelaces
amountInLL=$(( amountInADA*1000000 ))

# Address for change
payorADDR1=$(cat wallets/01.addr)
payorADDR2=$(cat wallets/02.addr)
# Calculate fees
payorBALANCE1=$(cardano-cli query utxo --tx-in $payorUTXO1 --testnet-magic 1 | tail -n 1 | tr -s " " | cut -d " " -f 3)
payorBALANCE2=$(cardano-cli query utxo --tx-in $payorUTXO2 --testnet-magic 1 | tail -n 1 | tr -s " " | cut -d " " -f 3)

destinationADDR1="$(cat wallets/03.addr)"
destinationADDR2="$(cat wallets/04.addr)"

tmpFile=$(mktemp)

# Enter if block only when calculating fee
if [[ "$fee" -le 0 ]]; then
  echo "Tx Fee: "

  cardano-cli transaction build-raw \
    --tx-in $payorUTXO1 \
    --tx-in $payorUTXO2 \
    --tx-out "$destinationADDR1 0 lovelace" \
    --tx-out "$destinationADDR2 0 lovelace" \
    --tx-out "$payorADDR1 0 lovelace" \
    --tx-out "$payorADDR2 0 lovelace" \
    --fee 0 \
    --out-file $tmpFile

  cardano-cli transaction calculate-min-fee \
      --testnet-magic 1 \
      --tx-body-file $tmpFile \
      --tx-in-count 2 \
      --tx-out-count 4 \
      --witness-count 2 \
      --protocol-params-file protocol.json

  exit 0
fi

changeADDR1=$(( ( payorBALANCE1 - amountInLL ) - (fee / 2) ))
changeADDR2=$(( ( payorBALANCE2 - amountInLL ) - (fee / 2) ))

modDiv=$(( fee % 2 ))
# If fee division is not even, then 
# second address pays +1 lovelace so
# the math can be precise.
if [[ "$modDiv" -ne "0" ]]; then
  changeADDR2=$(( changeADDR2 - 1 ))
fi

tmpRaw=$(mktemp)

# For debugging purposes :)
command="cardano-cli transaction build-raw \
  --tx-in ${payorUTXO1} \
  --tx-in ${payorUTXO2} \
  --tx-out \"${destinationADDR1} ${amountInLL} lovelace\" \
  --tx-out \"${destinationADDR2} ${amountInLL} lovelace\" \
  --tx-out \"${payorADDR1} ${changeADDR1} lovelace\" \
  --tx-out \"${payorADDR2} ${changeADDR2} lovelace\" \
  --fee ${fee} \
  --out-file ${tmpRaw}"

# Uncoment lines below for debugging
# echo $command
# exit 0

cardano-cli transaction build-raw \
  --tx-in $payorUTXO1 \
  --tx-in $payorUTXO2 \
  --tx-out "$destinationADDR1 $amountInLL lovelace" \
  --tx-out "$destinationADDR2 $amountInLL lovelace" \
  --tx-out "$payorADDR1 $changeADDR1 lovelace" \
  --tx-out "$payorADDR2 $changeADDR2 lovelace" \
  --fee $fee \
  --out-file $tmpRaw

[ $? -eq 0 ]  || (echo "Error building transaction" && exit 1)

tmpSg=$(mktemp)

cardano-cli transaction sign \
  --tx-body-file $tmpRaw \
  --signing-key-file wallets/01.skey \
  --signing-key-file wallets/02.skey \
  --testnet-magic 1 \
  --out-file $tmpSg

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file $tmpSg

cardano-cli transaction txid --tx-file $tmpSg

