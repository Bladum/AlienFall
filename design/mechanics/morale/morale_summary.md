# Morale, Bravery, and Sanity Summary

## Psychological Model Overview

- Three-layer model: bravery sets morale ceiling, morale governs in-mission resilience, sanity controls long-term deployability.
- Bravery spans 6-12 with traits, equipment, and rank bumps; morale starts at bravery but never exceeds it; sanity tracks trauma between sorties.
- Robotics ignore morale/sanity entirely, providing panic-proof options for critical objectives.

## Morale (Tactical Layer)

- Stress events chip morale: nearby ally deaths, personal damage, flanking, night missions, commander loss, first-contact horror.
- Threshold ladder: 4 = nervous (−5% accuracy), 3 = stressed (−10%), 2 = shaken (−1 AP, −15%), 1 = panicking (−2 AP, −25%), 0 = panic lock (no actions, 10% flee, 5% drop weapon).
- Recovery tools: Rest action (+1 morale, 2 AP), leader rally (+2, 4 AP, 5-hex range), leader aura (+1 per turn within 8 hexes), kill streak momentum (+1 per kill).
- Morale fully resets to bravery at mission end; no passive in-battle regen, enforcing AP tradeoffs.

## Sanity (Strategic Layer)

- Persisting stat (0-12) reduced post-mission by difficulty, night ops, witnessed deaths, horrors, failures, base assaults, civilian losses.
- No combat penalties until 0; sanity only gates deployment (0 = Broken, unusable until treated).
- Recovery cadence: +1/week idle, +1/week via Temple, +3 via hospital therapy (10K cost), +5 via two-week leave (5K), +2 on promotion, +1-2 on flawless victories.
- Encourages roster rotation and facility investment; temple + medical bay considered critical mid-game infrastructure.

## Bravery Progression & Modifiers

- Base values by archetype (conscripts 6, soldiers 8, veterans 10, elites 11, heroes 12) with traits like Brave (+2) or Coward (−3), gear like officer badges (+1).
- Experience grants +1 bravery per 3 ranks (cap +4), while situational modifiers apply per mission (leader proximity, night penalties, being outnumbered).
- Bravery > morale synergy: high-bravery leaders project morale buffs, also bolster psionic defense (+1 per 2 bravery).

## Strategic & Balance Implications

- Recommended roster = 2-3× squad size to allow sanity cooldowns; horror missions require fresh high-sanity units.
- Attrition spiral risk: consecutive high-trauma missions shrink roster, forcing low-sanity deployments and increasing casualty rates.
- Difficulty scaling adjusts bravery baselines, morale thresholds, sanity degradation, and recovery speeds (Easy forgiving, Impossible brutal).
- Traits, facilities, and mission choice create meaningful strategic decisions balancing immediate combat power vs long-term mental health.

## QA & Testing Focus

- Verify morale loss tables fire once per event and combine correctly with AP/accuracy penalties.
- Ensure panic state behavior (flee/drop/surrender chances) triggers only at morale 0 and clears after recovery.
- Regression tests for sanity deduction stacking (mission type + casualties + horror) and recovery sources respecting caps.
- Scenario tests covering rotation logic (units locked at sanity 0), facility bonuses, leader rally stacking, and robotics immunity edge cases.
- Difficulty scaling validation: confirm easy/hard modifiers shift bravery ranges, morale thresholds, and recovery rates per spec.
