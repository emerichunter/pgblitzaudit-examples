# Demo fixture

`plant_issues.sql` is a demo fixture. It creates a table with dead tuples, two identical indexes, and a large table that gets sequential scans, purely so the sample reports have findings to show.

It also creates roles, a sequence near exhaustion, an inactive replication slot, and changes a couple of server settings. It is destructive-ish: run it only on a throwaway database, never on anything you care about. The sample bundle was collected from a disposable PostgreSQL 17 container.
