# Data Source Notes

Findings from the Phase 1 data-availability check (2026-07-08). These justify the source
decision recorded in the [client brief](client_brief.md) §5.

## Sources evaluated

| Source | What it gives | History? | Verdict |
|---|---|---|---|
| **Vélib' Métropole GBFS** (`velib-metropole-opendata.smovengo.cloud`) | Live `station_status` + `station_information`, GBFS 1.0 | **No** — real-time snapshot only, `ttl` 3600s | **Primary source.** Authoritative, license-clean, 1,517 stations. |
| **opendata.paris.fr** `velib-disponibilite-en-temps-reel` | Same data, re-published, updated ~every minute | **No** — Paris explicitly provides no historical access | Redundant with GBFS. Not used. |
| **Community archives** (e.g. `lovasoa/historique-velib-opendata`) | Crowd-collected snapshots since Dec 2019 | Yes (third-party) | Optional backfill for demo depth; not a dependency. |

**Decision:** live source = **Vélib' Métropole GBFS**. Because no official history exists,
we **build our own** by snapshotting the feed on a schedule (Phase 2 collector).

## Verified feed structure (fetched 2026-07-08)

Discovery doc lists 4 feeds; we use two, joinable on `station_id` (and `stationCode`):

**`station_status.json`** — one object per station, 1,517 stations:
```json
{
  "station_id": 213688169,
  "num_bikes_available": 6,
  "num_bikes_available_types": [{"mechanical": 4}, {"ebike": 2}],
  "num_docks_available": 29,
  "is_installed": 1, "is_returning": 1, "is_renting": 1,
  "last_reported": 1783534203,
  "stationCode": "16107"
}
```
(`numBikesAvailable`/`numDocksAvailable` camelCase duplicates also present — ignore.)

**`station_information.json`** — static-ish metadata, 1,517 stations:
```json
{
  "station_id": 213688169, "stationCode": "16107",
  "name": "Benjamin Godard - Victor Hugo",
  "lat": 48.865983, "lon": 2.275725, "capacity": 35
}
```

## Practical notes for the collector

- **Access:** the endpoint 403s a bare/unknown user-agent (Cloudflare). Send a normal
  browser `User-Agent` header. Plain `curl`/`requests` with a UA works.
- **Feed timestamp:** top-level `lastUpdatedOther` (epoch seconds) + per-station
  `last_reported`. Snapshot cadence should record wall-clock capture time *and* keep the
  feed's own timestamps, so we can detect stale stations.
- **Failure labels** derive directly from status:
  - stockout ⇔ `num_bikes_available == 0` (and `is_renting == 1`, i.e. station is live)
  - dockout ⇔ `num_docks_available == 0` (and `is_returning == 1`)
- **Out-of-service stations** (`is_installed == 0`) must be excluded from failure metrics —
  a decommissioned station isn't a service failure.
- **Capacity sanity:** `num_bikes_available + num_docks_available` ≈ `capacity`, but not
  exactly (bikes in maintenance, broken docks). Don't assume equality.
