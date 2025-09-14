{{ config(materialized='table') }}

with src as (
  select distinct
    metric,
    split_part(metric, '_', 1)  as country,
    split_part(metric, '_', 2)  as topic,     -- e.g., load, generation, price
    split_part(metric, '_', 3)  as qualifier, -- e.g., actual, forecast
    array_to_string(            -- everything after the 3rd part (provider/source)
      array[
        split_part(metric, '_', 4),
        split_part(metric, '_', 5),
        split_part(metric, '_', 6),
        split_part(metric, '_', 7)
      ],
      '_'
    ) as tail
  from {{ ref('fct_energy_timeseries_long') }}
  where metric is not null
)

select
  md5(metric) as metric_key,  -- surrogate key
  metric,
  lower(country)  as country,
  lower(topic)    as topic,
  lower(qualifier) as qualifier,
  nullif(lower(tail), '') as tail
from src
