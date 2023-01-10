#!/bin/bash

#####################################################
### Sends ADA from 01.addr to 02.addr and 03.addr ###
#####################################################

# Enter the UTXO under 01.addr which ADA will be spent from
payorUTXO1=""
payorUTXO2=""


############################################################################
## No need to modify code below when following directions from the README ##
############################################################################

# Amount in ADA which will be converted to lovelace
amountInADA=2
# Address for change
payorADDR=$(cat wallets/01.addr)
destinationADDR1="$(cat wallets/02.addr)"
destinationADDR2="$(cat wallets/03.addr)"

cardano-cli transaction build \
  --testnet-magic 1 \
  --change-address $payorADDR \
  --tx-in $payorUTXO1 \
  --tx-in $payorUTXO2 \
  --tx-out "$destinationADDR1 $(($amountInADA*1000000)) lovelace" \
  --tx-out "$destinationADDR2 $(($amountInADA*1000000)) lovelace" \
  --out-file tx02.body

[ $? -eq 0 ]  || (echo "Error building transaction" && exit 1)

cardano-cli transaction sign \
  --tx-body-file tx02.body \
  --signing-key-file wallets/01.skey \
  --testnet-magic 1 \
  --out-file tx02.signed

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file tx02.signed

cardano-cli transaction txid --tx-file tx02.signed

