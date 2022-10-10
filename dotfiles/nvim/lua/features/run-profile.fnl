(local {: run-profile-config} (require :profiles))

(fn setup []
  (run-profile-config :startup))

{: setup}
