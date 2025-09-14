{{ config(materialized='table') }}

{% set relation = ref('stg_opsd_timeseries') %}
{% set cols = adapter.get_columns_in_relation(relation) %}

{% set time_col = 'utc_timestamp' %}
{% set value_cols = [] %}
{% for c in cols %}
  {% if c.name != time_col %}
    {% do value_cols.append(c.name) %}
  {% endif %}
{% endfor %}

with base as (

  {% for col in value_cols %}
  select
    {{ time_col }}::timestamptz as utc_timestamp,
    '{{ col }}'::text            as metric,
    /* SAFE numeric cast:
       - Handle NULLs and blanks
       - Accept only numeric patterns (e.g., 123, -1.23)
       - Otherwise return NULL
    */
    case
      when {{ col }} is null then null
      when trim({{ col }}::text) = '' then null
      when trim({{ col }}::text) ~ '^-?[0-9]+(\.[0-9]+)?$' then ({{ col }}::double precision)
      else null
    end as value
  from {{ relation }}
  {% if not loop.last %}union all{% endif %}
  {% endfor %}

),

enriched as (
  select
    utc_timestamp,
    metric,
    value,
    split_part(metric, '_', 1) as country
  from base
)

select * from enriched
