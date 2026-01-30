#!/usr/bin/env bash

set -o allexport
source .env
set +o allexport

echo "Ciando as pastas necessárias..."

mkdir ./geth
mkdir ./geth/config/
mkdir ./prysm
mkdir ./prysm/validator
mkdir ./prysm/validator/wallet

echo "Criando uma carteira"
echo "Criando arquivo secreto..."

openssl rand -hex 32 >"secret.txt"

OUTPUT=$(printf "$PASSWORD\n$PASSWORD\n" | docker run --rm -i -v $(pwd):/app -w /app ethereum/client-go:stable --datadir geth account import secret.txt 2>&1)

ADDRESS=$(echo "$OUTPUT" | grep -o "{.*}" | tr -d "{}")

DATE=$(date +%s)

cp "$GENESIS_EXEMPLE_FILE" "geth/$GENESIS_FILE"

sed -i "s|<<account>>|$ADDRESS|g" "geth/$GENESIS_FILE"
sed -i "s|<<date>>|$DATE|g" "geth/$GENESIS_FILE"
sed -i "s|<<account>>|$ADDRESS|g" "$DOCKER_COMPOSE_FILE"

echo "Carteira criada com o endereço: $ADDRESS"

echo "Criando o arquivo de gênesis..."

echo "criando configuração do prysm..."

openssl rand -hex 32 >"prysm/validator/password.txt"

cp ./config/config.yml ./prysm/config.yml

docker run --rm \
  -v $(pwd)/prysm:/data \
  -v $(pwd)/geth:/geth \
  gcr.io/offchainlabs/prysm/cmd/prysmctl:latest \
  testnet generate-genesis \
  --fork=capella \
  --chain-config-file=/data/config.yml \
  --num-validators 64 \
  --genesis-time-delay 30 \
  --genesis-time $(date +%s) \
  --geth-genesis-json-in=/geth/$GENESIS_FILE \
  --geth-genesis-json-out=/geth/$GENESIS_FILE \
  --output-ssz=/data/genesis.ssz

docker run --rm -v $(pwd)/geth:/data \
  ethereum/client-go:stable \
  --datadir=data init /data/$GENESIS_FILE

echo "Criando jwt para autenticação... "
openssl rand -hex 32 >"jwt.hex"

echo "JWT criado com sucesso!"
echo "Todas as ferramentas foram criadas com sucesso!"
