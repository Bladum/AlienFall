# Analytics Pipeline Summary

## Five-Stage Flow

- Pipeline runs autonomous simulation, log capture, aggregation, metric calculation, and action planning as a continuous loop.
- Player-facing sessions share the same structured telemetry as AI simulations, tagged by source for unified queries.
- Output targets Parquet plus DuckDB indexes so analysts can query months of data in seconds.

## Simulation Coverage

- Geoscape, Basescape, Interception, Battlescape, and full-campaign sims execute on rotation; durations range from single encounters to multi-month campaigns.
- Dual-AI model separates Player AI (strategic planner with UI click emulation) and Faction AI (native opposition) to expose human-like decision mixes.
- Logging schema captures timestamp, actor, context, resource deltas, and cascading outcomes for every notable event.

## Data Processing Stack

- Stream parser validates schema, drops malformed rows, and writes hourly Parquet partitions before indexing with DuckDB.
- Core tables: game_events, research_projects, manufacturing_jobs, combat_encounters, unit_statistics, weapon_usage, mission_results, base_snapshots, player_actions, ui_interactions.
- Quality gates flag duplicates, impossible values, or time-order violations before data becomes queryable.

## Metrics & Dashboards

- Standard SQL templates evaluate combat balance (unit survival, weapon accuracy), economy pacing (research duration ratio, manufacturing profit), and strategic tension (mission success by tier, campaign escalation).
- Performance telemetry tracks pathfinding, combat resolution, and memory budgets with p95/p99 reporting.
- Metric config pairs each KPI with target ranges, acceptance thresholds, and priority tags (critical/high/medium/low).

## Action & Reporting

- Daily jobs regenerate dashboards and alert when KPIs breach thresholds (e.g., unit win rate outside 45-55%, FPS p95 <60).
- Insights drive automated balance proposals and feed designer review queues for manual follow-up.
- Regression checklist: validate schema ingest, ensure Parquet partitions build, confirm metric queries execute within budget, and verify alert thresholds fire under forced anomaly scenarios.
