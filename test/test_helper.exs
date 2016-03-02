ExUnit.start

Mix.Task.run "ecto.create", ~w(-r ImageExtractor.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r ImageExtractor.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(ImageExtractor.Repo)

