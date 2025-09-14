{{ config(materialized='table') }}

with src as (
  select
    f.utc_timestamp,
    f.metric,
    f.value,
    d_c.country_key,
    d_m.metric_key
  from {{ ref('fct_energy_timeseries_long') }} f
  left join {{ ref('dim_country') }} d_c
    on lower(f.country) = d_c.country
  left join {{ ref('dim_metric') }} d_m
    on f.metric = d_m.metric
)

select * from src
