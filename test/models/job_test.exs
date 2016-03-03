defmodule ImageExtractor.JobTest do
  use ImageExtractor.ModelCase

  alias ImageExtractor.Job

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Job.changeset(%Job{}, @valid_attrs)
    assert changeset.valid?
  end
end
