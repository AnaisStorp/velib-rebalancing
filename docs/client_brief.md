# Client Brief — Vélib' Métropole Station Rebalancing

> **Engagement type:** Forward-deployed data science, decision-support tooling
> **Prepared for:** Vélib' Métropole — Operations & Field Logistics
> **Status:** Discovery → scoping (Phase 1)
> **Author:** Anaïs Storp
> **Date:** 2026-07-08

---

## 1. Context

Vélib' Métropole operates the largest station-based bike-share network in the world:
**~1,517 stations** across 55 municipalities in Greater Paris, mixing mechanical and
electric bikes. Demand is highly asymmetric in space and time — commuters flow *into*
business districts each morning and *out* each evening, gravity drains hilltop stations,
and events create local spikes.

The result is **imbalance**: some stations empty out (no bikes to rent), others fill up
(no docks to return to). The field team runs a fleet of trucks and on-foot "rebalancers"
who move bikes between stations, but today they decide *where to go next* mostly from
experience and live dashboards — reacting after a station has already failed, not before.

## 2. The pain point

Two failure modes, each a lost trip and a frustrated rider:

- **Stockout** — a station has **0 bikes available**. A rider who walks up cannot rent.
- **Dockout** — a station has **0 free docks**. A rider arriving cannot return their bike
  and must hunt for another station, extending their trip and their bill.

Both are **service failures the operator can see coming** but currently does not act on
systematically. Every stockout-minute is suppressed demand; every dockout-minute pushes a
paying customer toward a competitor (Lime, Dott) or the metro.

## 3. Stakeholders

| Stakeholder | Role in this engagement | What they care about |
|---|---|---|
| **Operations Manager** | Primary user of the tool | "Where do I send trucks in the next 1–3 hours?" A short, trustworthy, ranked list. |
| **Field rebalancing crews** | Downstream of the tool | Actionable, geographically sensible routes; not being sent on pointless trips. |
| **Head of Operations** | Sponsor / budget holder | Fewer service failures per euro of rebalancing effort; a metric they can report up. |
| **Riders** | End beneficiaries | A bike when they want one, a dock when they arrive. |
| **Data / IT** | Provides feeds, hosts tooling | Something maintainable that runs on the public GBFS feed, no new data contracts. |

## 4. Success metrics

We frame success in the operator's language, not the modeler's. Primary business metric:

- **Stockout-minutes per station per day** — total minutes a station sits at 0 bikes.
- **Dockout-minutes per station per day** — total minutes a station sits at 0 free docks.
  Together these are our **"failure-minutes"** north star. Rebalancing that works drives
  them down at high-traffic stations without ballooning truck mileage.

Supporting / model-facing metrics (means to the end, reported honestly):

- **Lead-time value** — can we flag an at-risk station **30–60 min before** it fails, with
  enough precision that crews trust the alert? Measured as precision/recall (and PR-AUC)
  of the near-term risk model at a fixed operating point.
- **Ranking quality** — of the top-N stations the tool tells the operator to rebalance,
  what fraction actually failed soon after? (Precision@N — this is what the manager
  experiences.)

Explicitly **not** a success metric: raw model accuracy. Stockouts are rare per-station
per-interval, so a model can be 97% "accurate" by predicting "fine" forever and be useless.
We hold ourselves to precision/recall on the rare event and to Precision@N on the list the
operator actually acts on.

## 5. Constraints & assumptions

- **Data.** The only reliable, license-clean source is the **public Vélib' GBFS feed**
  (`station_status` + `station_information`). It is a **real-time snapshot** with no
  official history (see [`data_source_notes.md`](data_source_notes.md)). We therefore build
  our own history by snapshotting the feed on a schedule. Early phases run on a modest,
  self-collected window; findings are stated relative to that window, not overclaimed.
- **Signal, not control.** We predict and prioritize; we do **not** dispatch trucks or
  optimize routes. The human operator stays in the loop and makes the call.
- **Interpretability over cleverness.** The operator must understand *why* a station is
  flagged ("empties every weekday ~8am, currently draining fast"). A simple, explainable
  model that the field trusts beats a black box they ignore.
- **Reproducibility.** Fixed seeds, pinned deps, one-command runs. Strict time-series
  validation — no training on the future to predict the past.
- **Runs on a laptop.** No cluster, no paid infra. Public feed → local pipeline → local
  dashboard.

## 6. Scope

**In scope (this engagement):**
1. A collector that accumulates GBFS snapshots into a local history.
2. A cleaning/feature pipeline turning raw snapshots into a modeling table.
3. EDA of *when* and *where* failures happen (hour, weekday, station cluster).
4. An interpretable baseline model for **near-term stockout/dockout risk per station**.
5. A **decision-support dashboard** for an ops manager: at-risk map, ranked "rebalance
   next" list, plain-language reasons.
6. A one-page executive summary with findings, recommendation, and honest limitations.

**Out of scope (flagged for a possible follow-on):**
- Vehicle routing / truck dispatch optimization (which truck, what order, how many bikes).
- Real-time streaming / production SLAs, alerting, on-call.
- Demand forecasting for network planning or new-station siting.
- Pricing, incentives, or user-facing "bonus" rebalancing.
- Weather, events, and strike data as features (candidate enrichment, not baseline).

## 7. How we'll know it worked

At the end of the engagement the Operations Manager can open one screen, see the stations
most likely to fail in the next hour, understand *why* in plain French/English, and send a
crew **before** the rider walks up to an empty rack — and we can show, on held-out history,
that the ranked list would have caught real failures ahead of time.
