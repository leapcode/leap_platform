@title = "Miscellaneous"
@summary = "Miscellaneous commands you may need to know."

Facts
==============================

There are a few cases when we must gather internal data from a node before we can successfully deploy to other nodes. This is what `facts.json` is for. It stores a snapshot of certain facts about each node, as needed. Entries in `facts.json` are updated automatically when you initialize, rename, or remove a node. To manually force a full update of `facts.json`, run:

    leap facts update FILTER

Run `leap help facts update` for more information.

The file `facts.json` should be committed to source control. You might not have a `facts.json` if one is not required for your provider.

