{%- macro jira_config(key) -%}
  ((current_setting('dbt_personal.jira_config')::json)->>'{{ key }}')
{%- endmacro -%}
