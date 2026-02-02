from dags.definitions import (
    defs,
    evaluation_report,
    prepared_data,
    raw_data,
    trained_model,
    training_job,
)


def test_dagster_definitions_exist() -> None:
    assert defs is not None
    assert raw_data is not None
    assert prepared_data is not None
    assert trained_model is not None
    assert evaluation_report is not None
    assert training_job is not None
