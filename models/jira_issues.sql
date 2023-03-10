{%- if execute %}
  {%- set pre_query -%}
    select ({{ jira('GET', '/search', json_expr({ 'fields': '', 'maxResults': 0 })) }}->>'total')::int as total
  {%- endset %}
  {%- set total = run_query(pre_query).rows[0].total %}
{%- else %}
  {%- set total = 0 %}
{%- endif %}

{%- set lit = dbt.string_literal %}
{%- set page_size = 50 %}

select
  issues_json.*
from
  generate_series(0, {{ total - 1 }}, {{ page_size }}) as start_at
  cross join
    json_to_recordset(
      {{
        jira('GET', '/search', json_expr({
          'fields': lit('*all'),
          'maxResults': page_size,
          'startAt': 'start_at'
        }))
      }}
      ->'issues'
    )
    as issues_json(
      id text,
      key text,
      fields json
    )

{%- set insert_fn_name = this.replace(identifier=this.identifier ~ "_insert") %}
{%- set insert_sql %}

  create or replace function {{ insert_fn_name }}
    returns trigger
    language plpgsql
    as $$
    begin

      {{
        jira('GET', '/search', json_expr({
          'fields': lit('*all'),
          'maxResults': page_size,
          'startAt': 'start_at'
        }))
      }}

    end;
    $$

  create or replace trigger 
    before insert on {{ this }}

{%- endset %}
