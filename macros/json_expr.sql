{%- macro json_expr(obj) %}

{%- if obj is mapping -%}
  json_build_object(
    {%- for key, val in obj.items() %}
      {{- dbt.string_literal(key) }},
      {{- json_expr(val) or 'null' }}
      {{- ',' if not loop.last }}
    {%- endfor -%}
  )
{%- elif obj is sequence and obj is not string -%}
  json_build_array(
    {%- for val in obj %}
      {{- json_expr(val) or 'null' }}
      {{- ',' if not loop.last }}
    {%- endfor -%}
  )
{%- else -%}
  {{- obj }}
{%- endif %}

{%- endmacro %}
