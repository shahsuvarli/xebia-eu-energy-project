{{ config(materialized='view') }}

{% set cols = select_country_cols('raw', 'opsd_timeseries_raw', ['NL','DE'], time_col='utc_timestamp') %}

with src as (
  select
    {# quote each physical column, then alias to lowercase #}
    {% for c in cols -%}
      {{ adapter.quote(c) }} as {{ c | lower }}{% if not loop.last %},{% endif %}
    {% endfor %}
  from {{ source('raw', 'opsd_timeseries_raw') }}
)

select * from src
