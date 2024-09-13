#!/bin/bash

###########################################
### Sends ADA from multiple addresses,  ###
###           to multiple addresses.    ###
###########################################

# Enter the UTXOs which ADA + transaction fees 
# will be spent from
payorUTXO1=""
payorUTXO2=""

# Addresses for change
payorADDR1=$()
payorADDR2=$()

# Amount in ADA which the two
# destination addresses will receive
amountInADA1=10
amountInADA2=12

destinationADDR1=$()
destinationADDR2=$()

txSignatory1=""
txSignatory2=""

# First, run this script with fee value empty so that fee
# can be calculated and printed to the screen.
# Then, populate this variable with the amount displayed
# and run script again.
fee=""

############################################################################
## No need to modify code below when following directions from the README ##
############################################################################

# convert to Lovelaces
amountInLL1=$(( amountInADA1*1000000 ))
amountInLL2=$(( amountInADA2*1000000 ))

# Calculate fees
payorBALANCE1=$(cardano-cli query utxo --tx-in $payorUTXO1 --testnet-magic 1 | tail -n 1 | tr -s " " | cut -d " " -f 3)
payorBALANCE2=$(cardano-cli query utxo --tx-in $payorUTXO2 --testnet-magic 1 | tail -n 1 | tr -s " " | cut -d " " -f 3)

# Enter if block only when calculating fee
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

  dummyFeeInLL=10000

  cardano-cli conway transaction build-raw \
    --tx-in $payorUTXO1 \
    --tx-in $payorUTXO2 \
    --tx-out "$destinationADDR1 $((amountInLL1 - dummyFeeInLL)) lovelace" \
    --tx-out "$destinationADDR2 $((amountInLL2 - dummyFeeInLL)) lovelace" \
    --tx-out "$payorADDR1 $dummyFeeInLL lovelace" \
    --tx-out "$payorADDR2 $dummyFeeInLL lovelace" \
    --fee 0 \
    --out-file $tmpFile

  cardano-cli conway transaction calculate-min-fee \
      --testnet-magic 1 \
      --tx-body-file $tmpFile \
      --tx-in-count 2 \
      --tx-out-count 4 \
      --witness-count 2 \
      --protocol-params-file protocol.json

  exit 0
fi

changeADDR1=$(( ( payorBALANCE1 - amountInLL1 ) - (fee / 2) ))
changeADDR2=$(( ( payorBALANCE2 - amountInLL2 ) - (fee / 2) ))

modDiv=$(( fee % 2 ))
# If fee division is not even, then 
# second address pays +1 lovelace in fees
# so the math can be precise.
if [[ "$modDiv" -ne "0" ]]; then
  changeADDR2=$(( changeADDR2 - 1 ))
fi

tmpRaw=$(mktemp)

# For debugging purposes :)
# Uncoment lines below for debugging
# command="cardano-cli transaction build-raw \
#   --tx-in ${payorUTXO1} \
#   --tx-in ${payorUTXO2} \
#   --tx-out \"${destinationADDR1} ${amountInLL1} lovelace\" \
#   --tx-out \"${destinationADDR2} ${amountInLL2} lovelace\" \
#   --tx-out \"${payorADDR1} ${changeADDR1} lovelace\" \
#   --tx-out \"${payorADDR2} ${changeADDR2} lovelace\" \
#   --fee ${fee} \
#   --out-file ${tmpRaw}"
# echo $command
# exit 0

cardano-cli transaction build-raw \
  --tx-in $payorUTXO1 \
  --tx-in $payorUTXO2 \
  --tx-out "$destinationADDR1 $amountInLL1 lovelace" \
  --tx-out "$destinationADDR2 $amountInLL2 lovelace" \
  --tx-out "$payorADDR1 $changeADDR1 lovelace" \
  --tx-out "$payorADDR2 $changeADDR2 lovelace" \
  --fee $fee \
  --out-file $tmpRaw

[ $? -eq 0 ]  || { echo "Error building transaction"; exit 1; }

tmpSig=$(mktemp)

cardano-cli transaction sign \
  --testnet-magic 1 \
  --tx-body-file $tmpRaw \
  --signing-key-file $txSignatory1 \
  --signing-key-file $txSignatory2 \
  --out-file $tmpSig

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file $tmpSig

cardano-cli transaction txid --tx-file $tmpSig
