#!/usr/bin/python3
"""Wrap cmark-gfm output in an HTML page using the shared workspace styles."""
import subprocess
import sys

rendered = subprocess.run(
  [
    "/usr/bin/cmark-gfm", "--validate-utf8", "--smart",
    "-e", "table", "-e", "strikethrough", "-e", "autolink", "-e", "tasklist",
  ],
  input=sys.stdin.buffer.read(),
  stdout=subprocess.PIPE,
  check=True,
).stdout

header = b'''<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Markdown | Workspace</title>
    <link rel="stylesheet" href="/_workspace.css">
  </head>
  <body class="markdown">
    <main>
      <article>
'''
footer = b'''
      </article>
    </main>
    <script>
      const heading = document.querySelector('article h1');
      if (heading) document.title = heading.textContent + ' | Workspace';
    </script>
  </body>
</html>
'''
sys.stdout.buffer.write(header + rendered + footer)
