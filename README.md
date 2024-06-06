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

This script sets up a network of nodes and channels for the Lightning Network. The nodes are instances of different Lightning Network implementations, including LND, c-lightning (CLN), and Eclair.

### Nodes

The script sets up six nodes:

- `lnd1` and `lnd2`: These are instances of the LND implementation.
- `cln1` and `cln2`: These are instances of the c-lightning implementation.
- `eclair1` and `eclair2`: These are instances of the Eclair implementation.

Each node is funded with Bitcoin through a series of transactions.

### Channels

The script sets up the following channels, which allows for testing of Bolt 12 interoperability between different Lightning Network node implementations and various channel configurations:

```mermaid
graph LR
    lnd1 --10M (5M/5M)--> cln1
    lnd1 --10M (5M/5M)--> eclair1
    lnd1 --10M (5M/5M)--> lnd2
    lnd2 --10M (5M/5M)--> cln2
    lnd2 --10M (5M/5M)--> eclair2
    cln2 --10M (5M/5M)--> cln3
    eclair2 --10M (5M/5M)--> eclair3
```

- A channel between `lnd1` and `cln1` with a local capacity of 10,000,000 satoshis and a remote capacity of 5,000,000 satoshis.
- A channel between `lnd1` and `eclair1` with a local capacity of 10,000,000 satoshis and a remote capacity of 5,000,000 satoshis.
- A channel between `lnd1` and `lnd2` with a local capacity of 10,000,000 satoshis and a remote capacity of 5,000,000 satoshis.
- A channel between `lnd2` and `cln2` with a local capacity of 10,000,000 satoshis and a remote capacity of 5,000,000 satoshis.
- A channel between `lnd2` and `eclair2` with a local capacity of 10,000,000 satoshis and a remote capacity of 5,000,000 satoshis.

## Visualizing the Network with LN-Visualizer

LN-Visualizer is a tool that allows you to visualize the Lightning Network nodes and channels. It can be accessed at [http://localhost:5646/](http://localhost:5646/).

## Using CLI Commands

You can interact with any of the nodes using CLI commands. The bin scripts provided in the repository allow you to issue commands against any of the nodes. 

To use the CLI commands, you need to pass the node name as the first argument to the relevant bin script. The node names are `lnd1`, `lnd2`, `cln1`, `cln2`, `eclair1`, and `eclair2`.

Here's an example of how to use the CLI commands:

```sh
./bin/lnd.sh lnd1 getinfo
```

In this example, `./bin/lncli` is the bin script for the LND nodes, `lnd1` is the name of the node you're issuing the command against, and `getinfo` is the command you're issuing. This command retrieves information about the `lnd1` node.

You can replace `getinfo` with any other command supported by the node. For a list of available commands, you can use the `help` command. For example:

```sh
./bin/eclair-cli eclair2 help
```

This command displays a list of all commands that you can issue against the `eclair2` node.

## Examples


### Paying to an Eclair node that is one hop away

**Generate a bolt 12 offer on eclair1:**

```sh
./bin/eclair-cli eclair1 tipjarshowoffer
```

**Pay to bolt 12 offer from lndk1:**

```sh
./bin/lndk-cli lndk1 pay-offer [BOLT12_OFFER] 10000
```


### Paying to an Eclair node that is two hops away

**Generate a bolt 12 offer on eclair2:**

```sh
./bin/eclair-cli eclair2 tipjarshowoffer
```

**Pay to bolt 12 offer:**

```sh
./bin/lndk-cli lndk1 pay-offer [BOLT12_OFFER] 10000
```


### Paying to a CLN node

*NOTE: This is not working at the moment.*

**Generate a bolt 12 offer:**

```sh
./bin/lightning-cli cln1 offer 1000 "test offer from cln"
```

**Pay to bolt 12 offer:**

```sh
./bin/lndk-cli lndk1 pay-offer [BOLT12_OFFER]
```


## Clean up

This will remove all docker container, images, and volumes created by this project.

**Clean everything:**
```sh
./scripts/clean.sh
```
