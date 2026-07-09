#Smoke test — confirms the package imports and the scaffold is wired up.
import velib_rebalancing

def test_package_imports():
    assert velib_rebalancing.__version__ == "0.1.0"

def test_seed_is_fixed():
    # Reproducibility contract: one seed, used everywhere.
    assert velib_rebalancing.RANDOM_SEED == 17
