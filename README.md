# Bolt 12 Playground

This Bolt 12 Playground provides a docker stack that comprises of bitcoind, [LND](https://github.com/lightningnetwork/lnd), [CLN](https://github.com/ElementsProject/lightning), [Eclair](https://github.com/ACINQ/eclair) and [LNDK](https://github.com/lndk-org/lndk). It connects everything together, initializes wallets, and creates channels between the nodes.

You can use this to get familiar with [Bolt 12](https://bolt12.org/).

## Setup

**Start nodes:**

```sh
docker compose up
```

**Initialise the nodes:**

```sh
./scripts/init.sh
```


## Paying to an Eclair node

This is the only working scenario at the moment.

**Generate a bolt 12 offer:**

```sh
./bin/eclair-cli tipjarshowoffer
```

**Decode a bolt 12 offer:**

```sh
./bin/lndk-cli decode [BOLT12_OFFER]
```

**Pay to bolt 12 offer:**

```sh
./bin/lndk-cli pay-offer [BOLT12_OFFER] 10000
```


## Paying to a CLN node

This is not working at the moment.

**Generate a bolt 12 offer:**

```sh
./bin/clncli offer 10000 "test offer from cln"
```

**Decode a bolt 12 offer:**

```sh
./bin/lndk-cli decode [BOLT12_OFFER]
```

**Pay to bolt 12 offer:**

```sh
./bin/lndk-cli pay-offer [BOLT12_OFFER]
```


## Clean up

**Clean everything:**
```sh
./scripts/clean.sh
```
