{{ config(materialized='function') -}}

(variadic text[])
returns text
language plpython3u
as $$
  import subprocess
  import os
  return os.environ
$$
