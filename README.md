# Vélib' Rebalancing — A Forward-Deployed Case Study

**Predicting and prioritizing station stockouts and dockouts for the Vélib' Métropole operations team.**

This repository is structured as a client engagement, not a notebook dump: a problem framed
for a real operator, a reproducible pipeline, an interpretable model held to an honest bar,
and a decision-support tool the operations manager could actually use tomorrow morning.

> Fictional client, real data. The Vélib' Métropole operations team is a stand-in; the
> [GBFS feed](docs/data_source_notes.md) is the genuine public Paris bike-share feed.

---

## Engagement

Vélib' runs ~1,517 bike-share stations across Greater Paris. Demand is asymmetric, so
stations **stock out** (0 bikes to rent) and **dock out** (0 free docks to return to)
throughout the day. Field crews rebalance bikes between stations, but decide *where to go
next* reactively — after a station has already failed.

**The ask:** help the operations manager see failures **coming** and prioritize where to
send crews first, in the operator's own language, with reasons they can trust.

Full framing — stakeholders, success metrics, constraints, scope — in
**[`docs/client_brief.md`](docs/client_brief.md)**.

## Approach

| Phase | Deliverable | Status |
|---|---|---|
| **1. Client brief + scaffold** | Problem framing, repo, reproducible tooling | Done |
| **2. Data pipeline** | GBFS collector + cleaning module + CLI + tests | Next |
| **3. Analysis & forecasting** | EDA of failure patterns; interpretable near-term risk model with leakage-free time-series validation | |
| **4. Decision-support dashboard** | Streamlit app: at-risk map, ranked "rebalance next" list, plain-language reasons |  |
| **5. Executive write-up** | One-page client summary: findings, recommendation, impact, limitations |  |

**Success is measured in the operator's terms** — *failure-minutes* (stockout- and
dockout-minutes per station per day) and *Precision@N* on the ranked list the manager acts
on — not raw model accuracy. Stockouts are rare per interval, so "accuracy" is a trap; see
the brief §4.

**Data.** The public Vélib' GBFS feed is a real-time snapshot with **no official history**,
so Phase 2 builds a collector that accumulates our own. Source evaluation and verified feed
schema: [`docs/data_source_notes.md`](docs/data_source_notes.md).

## Findings

_To be populated from Phase 3 onward. The one-page client-facing version will live in
`docs/executive_summary.md` (Phase 5)._

## How to run

Requires [`uv`](https://docs.astral.sh/uv/) (dependency + venv manager) and `make`.

```bash
# One-time: create the venv and install core + dev dependencies
make setup

# Verify the scaffold
make test        # run the test suite
make lint        # ruff

# Phase 2+ (as phases land):
make collect     # take one GBFS snapshot into data/raw/
make build       # build the modeling table in data/processed/
make train       # train the baseline risk model
make dashboard   # launch the ops Streamlit app
```

Run `make help` to list all commands. Everything is seeded (`velib_rebalancing.RANDOM_SEED`)
and dependency-pinned for reproducibility.

### Project layout

```
velib-rebalancing/
├── docs/                     # client_brief.md, data_source_notes.md, executive_summary.md
├── src/velib_rebalancing/    # the package (collector, pipeline, model, dashboard)
├── notebooks/                # exploration only — not part of the pipeline
├── tests/                    # pytest transform tests
├── data/                     # gitignored — collected snapshots + derived tables
├── pyproject.toml            # deps (core / dashboard / dev), CLI entry points
└── Makefile                  # reproducible commands
```

## Author

Anaïs Storp — MSc Data Science for Business (X-HEC). Built as a portfolio piece for
Forward-Deployed Engineer roles: taking a vague operational pain point to a usable,
honest, decision-support deliverable.
