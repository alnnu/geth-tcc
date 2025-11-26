rm -r gethdata/geth
./geth --datadir=gethdata init genesis.json
./geth --datadir gethdata --networkid 141319 --http --http.addr "0.0.0.0" --http.port 8545 --http.api "eth,net,web3,engine" --ws --ws.addr "0.0.0.0" --ws.port 8546 --ws.api "eth,net,web3,engine" --authrpc.jwtsecret jwt.hex --authrpc.addr "0.0.0.0" --authrpc.port 8551 --authrpc.vhosts "*" --nodiscover --allow-insecure-unlock --unlock 0xbc5fd374b5d781e8018d8c7313b7fff6d214fb37
