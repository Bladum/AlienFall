# Lore System Summary

## Purpose & Scope

- Centralizes narrative scaffolding for dynamic enemy factions, ensuring campaign pacing mirrors the layered conspiracy → invasion → time-loop arc.
- Keeps mechanical systems aligned with story beats: factions escalate, missions intensify, and calendar cadence applies pressure without overwriting player agency.
- Supplies designers with knobs (faction counts, campaign tiers, quest/event frequency) to tune narrative density across difficulties.

## Faction & Campaign Framework

- Each faction runs autonomous economies, tech trees, and mission scripts; defeating one leaves others untouched, preserving long-term threat variety.
- Campaigns span 6-10 weeks with ~5 missions released on fixed intervals; quarterly escalation adds +1 simultaneous campaign (cap 10/month).
- Regional preferences bias mission spawn (e.g., Asian factions ~80% Asia); player intel builds around predictable yet compounding schedules.
- Technology tiers and unit unlocks advance as campaigns survive, making base strikes and early interceptions the most efficient suppression tools.

## Mission, Quest & Event Flow

- Mission taxonomy: **Sites** (static, 3-14 day timers, 50-500 score swing), **UFO scripts** (multistep operations accruing points until intercepted), and **Bases** (4 growth levels, 1-5 missions/week plus base assaults).
- Optional quest track keeps 3-5 concurrent objectives (military, economic, diplomatic, organizational, research, heroic, regional, survival) rewarding power points, fame, or credits without fail penalties.
- Random events hit 2-5×/month, weighted across economic (30%), personnel (25%), research (15%), diplomatic (15%), operational (15%) categories with branching choices and cascading follow-ups.

## Timekeeping & Enemy Scoring

- Calendar runs 28-day months, 6-day weeks: monthly campaign refresh and funding, weekly mission generation/base scripts, daily UFO steps, radar scans, passive XP, supply ticks.
- Enemy scoring mirrors player points: campaigns (+20 launch, +30-50 completion), missions (+50-200 success, −50 to −100 if foiled), bases (+10/week, +50 per level, +200 for base assaults).
- Threat level = monthly enemy score / 100 (capped 10), driving campaign count, reinforcement quality, and escalation pacing; leaving factions unchecked accelerates scoring by +50%.

## Cross-System Integration

- Feeds AI behavior (faction motives, race rosters), Geoscape mission generation, Battlescape encounter composition, and diplomacy/funding levers.
- Calendar hooks trigger analytics, finance payouts, and supply line scripts so narrative beats and economy stay synchronized.

## QA Targets

- Validate campaign scheduler (monthly/weekly triggers), quest completion logic, and event probability modifiers (fame/karma multipliers).
- Simulate scoring to verify threat tiers, base progression timers (30-45 days per level), and mission expiry payouts across difficulties.
- Ensure calendar automation delivers missions, funding, and events without player interaction and that storyline milestones unlock correct missions.
