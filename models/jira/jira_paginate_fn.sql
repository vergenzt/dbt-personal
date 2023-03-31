{{ config(materialized='function') -}}

(method http_method, path text, response_key text, args json)
returns setof json
language plpgsql
as $$
  declare
    start_at int;
    page_size int;

    response http_response;
    resp json;

  begin
    loop

      select * from {{ ref('http') }}('jira', method, path, args) into response;
      resp := response.content;
      start_at := coalesce((args->>'startAt')::int, 0);
      page_size := json_array_length(resp->response_key);

      raise notice '{{ this.identifier }}: fetched % of % %', start_at + page_size, (resp->>'total'), response_key;

      return query
        select *
        from json_array_elements(resp->response_key);

      if start_at + page_size < (resp->>'total')::int then
        args := jsonb_set(args::jsonb, '{startAt}', to_jsonb(start_at + page_size))::json;
        continue;
      else
        return;
      end if;

    end loop;
  end
$$
