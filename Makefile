# Vélib' Rebalancing — reproducible commands.
# Uses uv (https://docs.astral.sh/uv/). See README "How to run".

.DEFAULT_GOAL := help
.PHONY: help setup collect snapshot build eda train dashboard test lint clean

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup:  ## Create venv and install deps (core + dev)
	uv venv
	uv pip install -e ".[dev]"

collect:  ## Run the GBFS collector once (one snapshot)  [Phase 2]
	uv run velib-collect --once

snapshot: collect  ## Alias for a single collection

build:  ## Build the modeling table from raw snapshots  [Phase 2]
	uv run velib-build

eda:  ## Launch JupyterLab for exploration  [Phase 3]
	uv run jupyter lab

train:  ## Train the baseline risk model  [Phase 3]
	uv run python -m velib_rebalancing.model

dashboard:  ## Launch the ops decision-support dashboard  [Phase 4]
	uv pip install -e ".[dashboard]"
	uv run streamlit run src/velib_rebalancing/dashboard.py

test:  ## Run the test suite
	uv run pytest

lint:  ## Lint with ruff
	uv run ruff check src tests

clean:  ## Remove caches and build artifacts (keeps collected data)
	rm -rf .pytest_cache .ruff_cache **/__pycache__ src/*.egg-info build dist
