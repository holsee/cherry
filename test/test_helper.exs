# 40 async cases funnel every File.stat/wildcard through the BEAM's
# single file server; the heaviest golden-tree tests can queue past the
# default 60s under full-suite load without anything being wrong.
ExUnit.start(timeout: 120_000)
