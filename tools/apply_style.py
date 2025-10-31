#!/usr/bin/env python3
"""
Script to insert a link to /css/site-style.css into all .htm/.html files under the workspace.
It will add the link before the closing </head> tag if the file doesn't already reference "site-style.css".
Backs up each file to filename.bak before modifying.
"""
import os
import io

root = r"c:\Users\RUSSO\Documents\website\TESTWEB"
link_tag = '<link rel="stylesheet" href="/css/site-style.css">'
count = 0
modified_files = []

for dirpath, dirnames, filenames in os.walk(root):
    for name in filenames:
        if name.lower().endswith(('.htm', '.html')):
            path = os.path.join(dirpath, name)
            try:
                with io.open(path, 'r', encoding='utf-8', errors='replace') as f:
                    text = f.read()
            except Exception as e:
                print(f"SKIP (read error): {path} -> {e}")
                continue
            if 'site-style.css' in text:
                # already references stylesheet
                continue
            # find closing </head>
            idx = text.lower().rfind('</head>')
            if idx == -1:
                # try to insert after <title> as fallback
                tidx = text.lower().find('</title>')
                if tidx != -1:
                    insert_at = tidx + len('</title>')
                    new_text = text[:insert_at] + '\n' + link_tag + '\n' + text[insert_at:]
                else:
                    print(f"SKIP (no </head> or </title>): {path}")
                    continue
            else:
                new_text = text[:idx] + link_tag + '\n' + text[idx:]
            # backup
            bak = path + '.bak'
            try:
                with io.open(bak, 'w', encoding='utf-8') as fb:
                    fb.write(text)
                with io.open(path, 'w', encoding='utf-8') as fw:
                    fw.write(new_text)
                count += 1
                modified_files.append(path)
            except Exception as e:
                print(f"FAIL writing {path}: {e}")

print(f"Done. Modified {count} files.")
if count:
    print("Modified files:")
    for p in modified_files[:200]:
        print(p)
