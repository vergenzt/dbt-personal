{%- macro with_prefix(prefix) %}
  {%- for line in caller().split('\n') %}
    {{ prefix ~ line }}
  {%- endfor %}
{%- endmacro %}
