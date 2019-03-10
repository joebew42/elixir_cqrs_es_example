ExUnit.start(trace: true, exclude: [:ignore, :acceptance])

:ok = Application.start(:mox)
