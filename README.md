# EU Energy Analytics

Goal: Build an end-to-end analytics pipeline that ingests open EU electricity data, models it with dbt, orchestrates with Airflow, and visualizes with Power BI.

Initial scope:

- Country: Netherlands (NL) + easy extension to DE.
- Data: Hourly/day energy generation, load, and CO₂ intensity (from OPSD/Eurostat).
- Questions:
  1. How does the energy mix evolve over time?
  2. When/where do consumption peaks occur?
  3. How does CO₂ intensity correlate with the mix?

Stack:

- Ingestion: Python (requests/pandas), Docker
- Storage/DB (dev): Postgres (local) → later Azure Synapse/SQL
- Transform: dbt
- Orchestration: Airflow (Docker)
- Viz: Power BI
- CI/CD: GitHub Actions
# xebia-eu-energy-project
# xebia-eu-energy-project
# xebia-eu-energy-project
