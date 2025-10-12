# Manufacturing

This document explains the production systems for items and equipment in AlienFall. It covers manufacturing projects, entries, dependencies, capacity, and labor costs.

## Table of Contents

- [Manufacturing System](#manufacturing-system)
- [Manufacturing Project](#manufacturing-project)
- [Manufacturing Entry](#manufacturing-entry)
- [Dependencies](#dependencies)
- [Manufacturing Capacity](#manufacturing-capacity)
- [Labor Cost per Consumption](#labor-cost-per-consumption)
- [Local vs Global Manufacturing](#local-vs-global-manufacturing)

## Manufacturing System
In-game management interface for production operations across all bases.
It handle all mfg projects, their progress, their inputs, requirements, outputs and costs. 

## Manufacturing Project
Single entry tracking progress, required item, resources, and completion status.
Once started inside base it will consume items and produce other items.

## Manufacturing Entry
Individual blueprint defining what can be built and production requirements.
This is definition what can be build, many prerequisites can be used here. 

## Dependencies
Prerequisite technologies, materials, and facility requirements for manufacturing.
Services also, organization level too. 

## Manufacturing Capacity
Total production slots available across all bases and facilities.
This comes from building more facility that provide mfg capacity. 

## Labor Cost per Consumption
Personnel time and salary expenses for manufacturing operations.
There are no engineers to be paid, there is just max capacity and payment is per labor done. 

## Local vs Global Manufacturing
Production is local per base but receives serial production bonuses for efficiency.

## Automatic sell price
Game should allow to based on resources used, labor needed to do done etc and this is used to calculate total cost

## Labor cost
Each facility provide a manufacturing capacity e.g. 5 will also provide its price per man day
which means end game facilities will provide much cheaper workspace via robots / automation