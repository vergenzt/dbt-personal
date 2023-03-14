{%- macro jira_fields() %}
  {%- set field_info_yaml %}

  - { id: summary }
  - { id: description }
  - { id: updated, type: timestamp with time zone }
  - { id: created, type: timestamp with time zone }
  - { id: labels, type: 'text[]' }
  - { id: customfield_10063, alias: Email Message ID }
  - { id: customfield_10085, alias: Email Snippet }
  - { id: customfield_10086, alias: Email Link }
  - { id: customfield_10087, alias: Email Subject }
  - { id: issuetype, expr: "({}::json)->>'name'" }

  {%- endset %}
  {%- set field_info = [] %}
  {%- for entry in fromyaml(field_info_yaml) %}
    {%- do field_info.append({
      'id': entry.id,
      'alias': entry.alias or entry.id,
      'type': entry.type or 'text',
      'expr': entry.expr or '{}',
    }) %}
  {%- endfor %}
  {%- do return(field_info) %}
{%- endmacro %}
