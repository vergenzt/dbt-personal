{%- macro jira_page_total(result_col, item_key) -%}
  (({{ result_col }}->>'startAt')::int + json_array_length({{ result_col }}->'{{ item_key }}'))
{%- endmacro %}

{%- macro jira_total(result_col) -%}
  ({{ result_col }}->>'total')::int
{%- endmacro %}
