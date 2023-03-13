(service text, method http_method, path text, args json = null)
returns http_response
language plpgsql
as $$
  declare
    settings json := current_setting('{{ project_name }}.' || service || '_config');

    fullpath text := concat(
      settings->>'base_url',
      path,
      case lower(method)
        when 'get' then coalesce('?' || urlencode(args::jsonb), '')
        else ''
      end
    );

    headers http_header[] := ARRAY[
      http_header('Authorization', settings->>'authorization')
    ];

    content_type text := (
      case lower(method)
        when 'get' then null
        else 'application/json'
      end
    );
    content text := (
      case lower(method)
        when 'get' then null
        else args
      end
    );

    request http_request := (method, fullpath, headers, content_type, content);
    response http_response;

  begin
    select * from http(request) into response;

    if response.status >= 400 then
      raise 'Request returned status code %', response.status;
    end if;

    return response;
  end;
$$
