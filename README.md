# pgBlitzAudit — sample output

These are real reports generated from a throwaway PostgreSQL 17 database (a small shop schema: customers, orders, order items, invoices, payments), collected with the public collector and replayed offline. Nothing here comes from a client system.

## What you are looking at

### Reports

Both HTML reports cover the `shopdb` database.

- `reports/ultimate_report_shopdb.html` — **health and structure report**. Answers: what is the overall state of this database, and what should be fixed first? Covers bloat, index health, storage, maintenance, replication, settings, security, and objects.
- `reports/perf_report_shopdb.html` — **query-level performance report**. Answers: which queries cost the most, and why? Ranks statements by CPU, disk I/O, planning time, WAL, frequency, total time, variance, temporary files, cache misses, and JIT overhead.

### Bundle

The bundle is the raw material the reports are built from.

- `bundle/manifest.json` — run inventory: tool version, collection time, PostgreSQL version, databases covered, and the size of every file below.
- `bundle/catalog_db_postgres.json` — structure of the `postgres` maintenance database: schemas, tables, columns, indexes, and planner statistics.
- `bundle/catalog_db_shopdb.json` — structure of `shopdb`: schemas, tables, columns, indexes, constraints, and planner statistics.
- `bundle/stat_db_postgres.json` — runtime statistics for `postgres`: activity, settings, table and index usage, and related counters.
- `bundle/stat_db_shopdb.json` — runtime statistics for `shopdb`: statement statistics, table and index usage, settings, and counters.
- `bundle/schema_dump_postgres.sql` — readable DDL for the `postgres` database.
- `bundle/schema_dump_shopdb.sql` — readable DDL for `shopdb`, including the duplicate index planted for the demo.
- `bundle/statistics_dump_postgres.sql` — short note explaining that statistics-only dumps require PostgreSQL 18+; planner statistics for this run are in the matching catalog JSON file.
- `bundle/statistics_dump_shopdb.sql` — the same note for `shopdb`.

## How to open

Clone the repository and open either HTML file in a browser:

```bash
git clone https://github.com/emerichunter/pgblitzaudit-examples.git
cd pgblitzaudit-examples
xdg-open reports/ultimate_report_shopdb.html   # or just double-click it
```

The reports are single files: no server, no build step, and no account. Each report loads web fonts from Google Fonts; without a connection it still renders fine with system fonts.

## What the bundle is

The bundle is the JSON the client sends back: 260 KB for this two-database cluster. It contains catalog metadata and statistics only — no row data, no query literals, no hashes. It is safe to review before sending.

## Reproduce it

The demo database is disposable and the result is deterministic enough for a sample. The collector is public; the report engine is not.

```bash
# 1. Start a throwaway PostgreSQL 17
docker run --name pba-demo -e POSTGRES_PASSWORD=demo -p 5432:5432 -d postgres:17

# 2. Plant the demo issues, then run a little load
psql postgresql://postgres:demo@localhost:5432/postgres -f demo/plant_issues.sql

# 3. Run the collector from the public collect repository, then replay the bundle with the engine
#    (the engine is not public; see the collect repository's README for its invocation)
```

The reports in this repository were generated with this flow against PostgreSQL 17.11.

## What the report does not do

- It is not a compliance certification.
- It is not a penetration test.
- It is not data profiling: it does not read or judge the content of your rows.

## License

MIT — see [LICENSE](LICENSE).
