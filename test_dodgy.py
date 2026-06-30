from dodgy import read_queue, write_queue, process_item, run_pipeline


def test_read_queue_defaults():
    result = read_queue("TESTQ")
    assert result["queue"] == "TESTQ"
    assert result["item"] == 1
    assert result["data"] == "SAMPLE DATA"
    assert result["status"] == 0
    assert "timestamp" in result


def test_read_queue_custom_item():
    result = read_queue("TESTQ", item_num=3)
    assert result["item"] == 3


def test_write_queue_short_data():
    result = write_queue("TESTQ", "SHORT")
    assert result["queue"] == "TESTQ"
    assert result["length"] == 5
    assert result["status"] == 0


def test_write_queue_long_data():
    long_data = "A" * 21
    result = write_queue("TESTQ", long_data)
    assert result["length"] == 21
    assert result["status"] == 8


def test_process_item():
    item = {"data": "SAMPLE DATA"}
    output = process_item(item)
    assert "FINAL PROCESSING" in output
    assert "SAMPLE DATA" in output


def test_run_pipeline_smoke(capsys):
    run_pipeline()
    captured = capsys.readouterr()
    assert "FINAL PROCESSING complete." in captured.out
