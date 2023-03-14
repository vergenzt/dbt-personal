select
  *
from

  {{ ref('http_fn') }}('gmail', 'GET', '/messages', json_build_object('labelIds', 'STARRED')) as emails_meta_resp,
  json_to_recordset(emails_meta) as emails_meta(
    id text,
    threadId text,
  ),

  {{ ref('http_fn') }}('gmail', 'GET', '/threads/' || emails_meta.threadId, json_build_object('format', 'metadata')) as email_thread_resp,
  json_to_record(email_thread_resp) as email_thread(
    id text,
    historyId text,
    messages text[],
  )

