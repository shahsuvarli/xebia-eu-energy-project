{% macro list_relations(schema) %}
  {# List relations (tables/views) in a given schema #}
  {% set sql %}
    select table_schema, table_name, table_type
    from information_schema.tables
    where table_schema = '{{ schema }}'
    order by table_name
  {% endset %}
  {% set results = run_query(sql) %}
  {% if execute %}
    {% for row in results.rows %}
      {{ log(row[0] ~ '.' ~ row[1] ~ ' (' ~ row[2] ~ ')', info=True) }}
    {% endfor %}
  {% endif %}
{% endmacro %}
