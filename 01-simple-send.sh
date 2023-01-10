#!/bin/bash

#########################################
### Sends ADA from 01.addr to 02.addr ###
#########################################

payorUTXO=""

# Address for change
payorADDR=$(cat wallets/01.addr)
# UTXO which ADA will be spent from
destinationADDR="$(cat wallets/02.addr)"
# Amount in ADA which will be converted to lovelace
amountInADA=5

cardano-cli transaction build \
  --testnet-magic 1 \
  --change-address $payorADDR \
  # UTXO where amount + fees will be deducted from
  --tx-in $payorUTXO \
  --tx-out "$(destinationADDR) $(amountInADA*1000000) lovelace" \
  --out-file tx01.body

[ $? -eq 0 ]  || (echo "Error building transaction" && exit 1)

cardano-cli transaction sign \
  --tx-body-file tx01.body \
  --signing-key-file wallets/01.skey \
  --testnet-magic 1 \
  --out-file tx01.signed

cardano-cli transaction submit \
  --testnet-magic 1 \
  --tx-file tx01.signed

cardano-cli transaction txid --tx-file tx01.signed
