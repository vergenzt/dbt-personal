{# with recursive
  responses as ( #}
    {%- set page_size = 50 %}
    {%- set total_to_fetch = 1000 %}
    {%- set lit = dbt.string_literal %}

    {{ config(pre_hook = "select http_set_curlopt('CURLOPT_TIMEOUT_MS', '20000')") }}

    select
      {{
        jira('GET', '/search', json_expr({
          'fields': lit('summary'),
          'maxResults': page_size,
          'startAt': 'start_at'
        }))
      }}
    from
      generate_series(0, {{ total_to_fetch }}, {{ page_size }}) as start_at
{# 
    union all

    select
      {{ jira('GET', '/search', json_expr({ 'startAt': jira_page_total('content') })) }}
    from
      responses
    where
      {{ jira_page_total('content') }} < {{ jira_total('content') }}
  )

select
  *
from
  responses #}
