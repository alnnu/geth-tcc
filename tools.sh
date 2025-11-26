#!/usr/bin/env bash

set -o allexport
source .env
set +o allexport

echo "Criando uma carteira"
echo "Criando arquivo secreto..."

openssl rand -hex 32 >"secret.txt"

OUTPUT=$(script -qec "printf \"$PASSWORD\n$PASSWORD\n\" | ./scripts/geth --datadir=gethdata account import secret.txt" /dev/null)

ADDRESS=$(echo "$OUTPUT" | grep -o "{.*}" | tr -d "{}")

cp "$GENESIS_EXEMPLE_FILE" "$GENESIS_FILE"

sed -i "s|<<account>>|$ADDRESS|g" "$GENESIS_FILE"

echo "Carteira criada com o endereço: $ADDRESS"

echo "Criando o arquivo de gênesis..."

script -qec "./scripts/prysmctl testnet generate-genesis --fork capella --num-validators 64 --genesis-time-delay 600 --chain-config-file $CONFIG_FILE --geth-genesis-json-in $GENESIS_FILE  --geth-genesis-json-out $GENESIS_FILE --output-ssz $GENESIS_SSZ_FILE"
script -qec "./scripts/geth --datadir=gethdata init $GENESIS_FILE" /dev/null

echo "Arquivo de gênesis criado com sucesso!"

echo "Criando jwt para autenticação... "
openssl rand -hex 32 >"jwt.hex"

echo "JWT criado com sucesso!"
echo "Todas as ferramentas foram criadas com sucesso!"
