{% materialization function, adapter='postgres' %}
  {%- call statement('main') -%}

    drop function if exists {{ this }} cascade;

    create function {{ this }} {{- sql }}

  {%- endcall %}
  {%- do adapter.commit() %}
  {%- do return({ 'relations': [this] }) %}
{% endmaterialization %}
