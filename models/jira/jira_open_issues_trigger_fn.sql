{{ config(materialized='function') -}}

()
returns trigger
language plpgsql
as $$
declare
  response http_response;
begin

  if old.id  is distinct from new.id
  or old.key is distinct from new.key
  then
    raise '❌ Cannot change issue ID or key';
  end if;

  case
  when tg_op in ('INSERT', 'UPDATE') then
    assert (new.id is null) = (old.id is null)
       and (new.id is null) = (tg_op = 'INSERT');

    select
      issue.*
    from
      {{ ref('http') }}(
        'jira',
        case tg_op
          when 'INSERT' then 'POST'
          when 'UPDATE' then 'PUT'
        end,
        '/issue' || case tg_op
          when 'INSERT' then ''
          when 'UPDATE' then '/' || old.id
        end,
        json_build_object('fields', new.fields)
      ) as update_resp,

      json_to_record(update_resp.content::json) as issue_meta(id text, key text),

      {{ ref('http') }}('jira', 'GET', '/issue/' || case when tg_op = 'INSERT' then issue_meta.id else old.id end, json_build_object('fields', '*all')) as get_resp,

      json_to_record(get_resp.content::json) as issue(id text, key text, fields json)

    into new;

    return new;
{# 
  when 'DELETE' then

    select
      issue.*
    from
      {{ ref('http') }}(
        'jira', 'PUT', '/issue/' || old.id,
        json_build_object('fields', json_build_object('status', json_build_object
          'id': 
        ))
      ) as put_resp,
      json_to_record(put_resp.content::json) as issue_meta(id text, key text),
      {{ ref('http') }}('jira', 'GET', '/issue/' || issue_meta.id, json_build_object('fields', '*all')) as get_resp,
      json_to_record(get_resp.content::json) as issue(id text, key text, fields json)

    into new;
    return new;
 #}

  else
    raise 'Not implemented yet';

  end case;

end
$$
