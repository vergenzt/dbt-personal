select
  jira_issues.*
from
  {{ ref('jira_paginate') }}('GET', '/search', 'issues', json_build_object('fields', '*all')) as json_objs,
  json_to_record(json_objs) as jira_issues(
    id text,
    key text,
    fields json
  )

{# 
{%- set create_trigger_fn %}
  create or replace function {{ trigger_fn_name() }}()
    returns trigger
    volatile
    as $$
      declare response http_response;
      begin
        raise notice 'Test message';

        select {{
          jira('POST', '/issue', json_expr({
            'fields': 'new.fields',
            'fieldsByKeys': lit('true'),
          }))
        }}
        into response;

        select * from json_to_record(post_result)
        as issues_json(id text, key text, fields json)
        into strict new;

        return new;
      end;
    $$
    language plpgsql
{%- endset %}

{%- set create_trigger %}
  create or replace trigger {{ trigger_name() }}
    before insert on {{ this }}
    for each row execute function {{ trigger_fn_name() }}()
{%- endset %}

{%- do config(post_hook = [create_trigger_fn, create_trigger]) %} #}
