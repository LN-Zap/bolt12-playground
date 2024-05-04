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

**Decode a bolt 12 offer:**

```sh
./bin/lndk-cli lndk1 decode lno1pqqnyzsmx5cx6umpwssx6atvw35j6ut4v9h8g6t50ysx7enxv4epyrmjw4ehgcm0wfczucm0d5hxzag5qqtzzq3lxgva5qlw9xsjmeqs0ek9cdj0vpec9ur972l7mywa66u3q7dlhs
```

**Clean everything:**
```sh
./scripts/clean.sh
```