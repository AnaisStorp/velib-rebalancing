"""Vélib' Rebalancing — forward-deployed case study.

Predict and prioritize near-term station stockouts (no bikes) and dockouts
(no free docks) for the Vélib' Métropole operations team.

Package layout (built out across phases):
    collect.py    GBFS snapshot collector            [Phase 2]
    pipeline.py   raw snapshots -> modeling table     [Phase 2]
    features.py   feature engineering                 [Phase 3]
    model.py      baseline risk model + validation    [Phase 3]
    dashboard.py  Streamlit ops decision-support app  [Phase 4]
"""

__version__ = "0.1.0"

# Single source of truth for reproducibility.
RANDOM_SEED = 42
