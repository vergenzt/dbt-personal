{%- macro jira(method, path, args='null', options={}) -%}
  (
    select
      content::json
    from
      http((
        '{{ method }}',
        (
          {{ jira_config('rest_api_url') }} || {{ path if options.quote_path is false else dbt.string_literal(path)  }}
          {%- if method.lower() == 'get' %}
            || coalesce('?' || urlencode(({{ args or 'null' }})::jsonb), '')
          {%- endif -%}
        ),
        ARRAY[
          http_header('Authorization', {{ jira_config('authorization') }})
        ],

      {%- if method.lower() == 'get' %}
        NULL,
        NULL
      {%- else %}
        'application/json',
        ({{ args or 'null' }}):json
      {%- endif %}

      )::http_request)
  )
{%- endmacro %}
