select
  issue.id,
  issue.key,

  {%- for field in jira_fields() %}
  {{ field.expr.format('issue_fields.' ~ field.id) }} as "{{ field.alias.replace('"', '"'*2) }}"
  {{- ',' if not loop.last }}
  {%- endfor %}

  {{- ',' }}

  issue.fields as _all_fields

from

  {{ ref('jira_paginate_fn') }}(
    'GET', '/search', 'issues',
    json_build_object(
      'fields', '*all',
      'jql', 'statusCategory != Done'
    )
  ) as json_objs,

  json_to_record(json_objs) as issue(
    id text,
    key text,
    fields json
  ),

  json_to_record(issue.fields) as issue_fields(
    {%- for field in jira_fields() %}
    {{ field.id }} {{ field.type }}
    {{- ',' if not loop.last }}
    {%- endfor %}
  )

{%- set trg = 'jira_open_issues_trigger' %}
{{
  config(
    post_hook = ([
      'create or replace trigger "main"',
      'before update or insert or delete on {{ this }}',
      'for each row',
      'execute function {{ ref("jira_open_issues_trigger_fn") }}()',
    ] | join('\n'))
  )
}}
