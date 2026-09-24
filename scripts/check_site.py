"""Check a rendered course site without executing course experiments."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
import sys, json, re

class Page(HTMLParser):
    def __init__(self):
        super().__init__(); self.links=[]; self.ids=set()
    def handle_starttag(self, tag, attrs):
        a=dict(attrs)
        if 'id' in a:self.ids.add(a['id'])
        for key in ('href','src','poster','data-video','data-poster'):
            if key in a:self.links.append((tag,key,a[key]))

root=Path(sys.argv[1] if len(sys.argv)>1 else '课程网站/_site').resolve()
if not root.is_dir():raise SystemExit('Rendered site directory is missing')
pages={};errors=[]; count=0
for f in root.rglob('*.html'):
    if 'site_libs' in f.parts:continue
    p=Page();text=f.read_text('utf-8');p.feed(text);pages[f]=p
    if re.search(r'[Gg]:[/\\]2026-Agent',text):errors.append([str(f.relative_to(root)),'machine-specific path'])
for f,p in pages.items():
    for tag,key,url in p.links:
        if not url or url.startswith(('#','data:','mailto:','javascript:','tel:')):continue
        u=urlsplit(url)
        if u.scheme or u.netloc:continue
        part=unquote(u.path)
        if not part:continue
        if part.startswith('/Digital-Signal-Processing-Course/'):target=root/part.removeprefix('/Digital-Signal-Processing-Course/')
        elif part.startswith('/'):target=root/part.lstrip('/')
        else:target=f.parent/part
        target=target.resolve()
        if target.is_dir():target=target/'index.html'
        count+=1
        if not target.is_relative_to(root) or not target.exists():errors.append([str(f.relative_to(root)),url])
for f in root.rglob('*'):
    if f.is_file() and ('teacher' in f.parts or f.suffix in {'.mp4','.wav','.mp3'}):errors.append([str(f.relative_to(root)),'excluded private or media file'])
result={'html_pages':len(pages),'local_links':count,'errors':errors}
print(json.dumps(result,ensure_ascii=False,indent=2))
sys.exit(bool(errors))
