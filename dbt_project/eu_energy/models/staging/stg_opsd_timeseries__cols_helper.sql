{{ config(materialized='ephemeral') }}

{# Build a comma-separated list of NL_/DE_ columns dynamically #}
{% set cols = adapter.get_columns_in_relation(source('raw','opsd_timeseries_raw')) %}
{% set keep = [] %}
{% for c in cols %}
  {% if c.name.startswith('NL_') or c.name.startswith('DE_') or c.name == 'utc_timestamp' %}
    {% do keep.append(c.name) %}
  {% endif %}
{% endfor %}
select {{ keep | join(', ') }}
