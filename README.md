# Bolt 12 Playground

This Bolt 12 Playground provides a docker stack that comprises of bitcoind, 2x lnd nodes and an lndk client. It connects everything together, initializes the wallets, and creates a channel between the two nodes.

You can use this to get familiar with [Bolt 12](https://bolt12.org/) and [LNDK](https://github.com/lndk-org/lndk).

## Usage

**Start nodes:**

```sh
docker compose up
```

**Initialise the nodes:**

```sh
./scripts/init.sh
```

**Generate a bolt 12 offer:**

```sh
./bin/clncli offer 10000 "test offer from cln"
```

**Decode a bolt 12 offer:**

```sh
./bin/lndk-cli lndk1 decode [BOLT12_OFFER]
```

**Pay to bolt 12 offer:**

```sh
./bin/lndk-cli lndk1 pay-offer [BOLT12_OFFER]
```

**Clean everything:**
```sh
./scripts/clean.sh
```