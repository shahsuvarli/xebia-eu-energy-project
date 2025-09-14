{{ config(materialized='table') }}

with src as (
  select distinct lower(country) as country
  from {{ ref('fct_energy_timeseries_long') }}
  where country is not null
)

select
  md5(country) as country_key,   -- surrogate key (text)
  country
from src
