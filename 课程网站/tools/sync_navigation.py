"""Bake the Quarto navbar configuration into standalone teaching HTML.

Invoked by Quarto pre-render; supports local file URLs and a GitHub Pages subpath.
Only updates navigation assets/markup; preserves lesson and media content.
"""
from pathlib import Path
from html import escape
import os
import yaml
from bs4 import BeautifulSoup

ROOT=Path(__file__).resolve().parents[1]

def integrate_courseware(soup,path):
    """Apply integration rules to the site copy, not the independent originals."""
    if 'courseware' not in path.relative_to(ROOT).parts:return
    for node in soup.select('.masthead .mworks, .branded-top .tongyuan-logo'):node.decompose()
    for link in soup.select('.masthead nav a'):
        if link.get('href') not in ('#chapters','#guide'):link.decompose()
        elif link.get('href')=='#chapters':link.string='课件目录'
    for nav in soup.select('.masthead nav'):nav['aria-label']='课件目录与使用说明'
    for link in soup.select('.school'):link['aria-label']='数字信号处理课件目录'
    for link in soup.select('.header-actions .home-link'):
        link.clear();link.append('← 课件目录')
        link['href']=os.path.relpath(ROOT/'courseware/index.html',path.parent).replace(chr(92),'/')
        link['aria-label']='返回在线课件目录'
    for nav in soup.select('.header-actions'):nav['aria-label']='本讲教学控制'


def apply(path,config):
    soup=BeautifulSoup(path.read_text(encoding='utf-8'),'html.parser')
    if not soup.body or not soup.head:return
    integrate_courseware(soup,path)
    for node in soup.select('.site-header,link[data-site-navigation],script[data-site-navigation]'):node.decompose()
    prefix=os.path.relpath(ROOT,path.parent).replace('\\','/')+'/'
    if prefix=='./':prefix=''
    links=[]
    category='microlectures/index.html' if 'microlectures' in path.relative_to(ROOT).parts else 'courseware/index.html'
    for item in config['navbar']['left']:
        href=item['href'].replace('.qmd','.html');external=href.startswith('https://')
        url=href if external else prefix+href
        attrs=' target="_blank" rel="noopener noreferrer"' if external else ''
        if href==category:attrs+=' aria-current="page"'
        links.append(f'<a href="{escape(url)}"{attrs}>{escape(item["text"])}</a>')
    markup=f'''<div class="site-header" role="banner" data-open="false"><div class="site-header-inner"><a class="site-brand" href="{prefix}index.html">{escape(config['title'])}</a><button class="site-menu-toggle" type="button" aria-label="展开网站导航" aria-controls="site-links" aria-expanded="false">菜单</button><nav class="site-links" id="site-links" aria-label="网站主导航">{''.join(links)}</nav></div></div>'''
    soup.body.insert(0,BeautifulSoup(markup,'html.parser'))
    soup.head.append(soup.new_tag('link',rel='stylesheet',href=prefix+'site-header.css',attrs={'data-site-navigation':'true'}))
    script=soup.new_tag('script',src=prefix+'site-header.js',attrs={'data-site-navigation':'true'});soup.body.append(script)
    path.write_text(str(soup),encoding='utf-8')

def main():
    config=yaml.safe_load((ROOT/'_quarto.yml').read_text(encoding='utf-8'))['website']
    pages=list((ROOT/'microlectures').glob('*/index.html'))+list((ROOT/'microlectures').glob('*/teacher.html'))
    pages+=[ROOT/'microlectures/index.html']
    pages+=list((ROOT/'courseware').rglob('index.html'))
    for path in pages:
        if path.exists():apply(path,config)
    print(f'Unified navigation: {len(pages)} HTML pages')

if __name__=='__main__':main()
