import pytest


@pytest.fixture(scope="module")
def dagster_deps():
    pytest.require_optional("dagster")
    from dagster import materialize_to_memory

    from dags.definitions import (
        defs,
        evaluation_report,
        prepared_data,
        raw_data,
        trained_model,
        training_job,
    )

    return (
        materialize_to_memory,
        defs,
        evaluation_report,
        prepared_data,
        raw_data,
        trained_model,
        training_job,
    )


def test_dagster_definitions_exist(dagster_deps) -> None:
    _, defs, evaluation_report, prepared_data, raw_data, trained_model, training_job = dagster_deps
    assert defs is not None
    assert raw_data is not None
    assert prepared_data is not None
    assert trained_model is not None
    assert evaluation_report is not None
    assert training_job is not None


@pytest.mark.integration
def test_dagster_assets_materialize_in_memory(dagster_deps) -> None:
    (
        materialize_to_memory,
        _,
        evaluation_report,
        prepared_data,
        raw_data,
        trained_model,
        _,
    ) = dagster_deps
    result = materialize_to_memory([raw_data, prepared_data, trained_model, evaluation_report])
    assert result.success
