defmodule SiresTaskApi.Notifier.Media do
  @callback notify(subscriber :: SiresTaskApi.User.t(), operation :: String.t(), txn :: map()) ::
              no_return()
end
