{% macro select_country_cols(source_name, table_name, prefixes, time_col='utc_timestamp') -%}
  {# Get real columns from the physical source relation #}
  {% set relation = source(source_name, table_name) %}
  {% set cols = adapter.get_columns_in_relation(relation) %}

  {% set pfx = prefixes if prefixes is sequence else [prefixes] %}
  {% set selected = [] %}

  {# ensure time column first if present #}
  {% for c in cols %}
    {% if c.name == time_col %}
      {% do selected.append(c.name) %}
    {% endif %}
  {% endfor %}

  {# add all columns that start with the prefixes #}
  {% for c in cols %}
    {% for pr in pfx %}
      {% if c.name.startswith(pr ~ '_') %}
        {% do selected.append(c.name) %}
      {% endif %}
    {% endfor %}
  {% endfor %}

  {# de-duplicate while preserving order #}
  {% set uniq = [] %}
  {% for s in selected %}
    {% if s not in uniq %}
      {% do uniq.append(s) %}
    {% endif %}
  {% endfor %}

  {{ return(uniq) }}
{%- endmacro %}
