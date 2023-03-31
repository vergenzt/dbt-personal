with
  emails as (
    {{ ref('http') }}('gmail', 'GET', '/messages', json_build_object('labelIds', 'STARRED'))
  ),
  emails_meta(id text, "threadId" text) as (
    sl

  )
select
  thread.id as thread_id,
  thread."historyId" as thread_history_id,
  thread_message.id as message_id,
  thread_message."labelIds" as message_labels,
  thread_message.snippet as message_snippet,
  thread_message."historyId" as message_history_id,
  thread_message.payload.

  
from

   as emails_meta_resp,
  json_to_recordset(emails_meta_resp.content::json->'messages') as emails_meta(
    id text,
    "threadId" text
  ),

  {{ ref('http') }}('gmail', 'GET', '/threads/' || emails_meta."threadId", json_build_object('format', 'metadata')) as thread_resp,
  json_to_record(thread_resp.content::json) as thread(
    id text,
    "historyId" text,
    messages json
  ),

  json_to_recordset(thread.messages) as thread_message(
    id text,
    "labelIds" text[],
    snippet text,
    payload json,
    "sizeEstimate" integer,
    "historyId" text,
  ),

  json_to_record(thread_message.payload) as message_payload(
    "partId" text,
    "mimeType" text,
    "filename" text,
    "headers" 
  )



