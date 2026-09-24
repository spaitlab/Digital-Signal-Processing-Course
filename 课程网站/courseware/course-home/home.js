(() => {
 'use strict';
 const chapters=window.COURSE_CHAPTERS;
 const list=document.querySelector('#chapter-list');
 let filter='all';
 const make=(tag,cls,text)=>{const el=document.createElement(tag);if(cls)el.className=cls;if(text!==undefined)el.textContent=text;return el;};
 const ready=chapters.filter(c=>c.lessons.length).length;
 const count=chapters.reduce((total,c)=>total+c.lessons.length,0);
 document.querySelector('#availability').textContent=`已接入 ${count} 讲 · 覆盖 ${ready} 章`;
 document.querySelector('#ready-count').textContent=ready;
 document.querySelector('[data-filter="all"] span').textContent=chapters.length;
 function render(){
  const query=document.querySelector('#search').value.trim().toLowerCase();
  const visible=chapters.filter(c=>(filter==='all'||c.lessons.length)&&`${c.number} ${c.title} ${c.summary} ${c.topics.join(' ')} ${c.lessons.map(l=>l.title+' '+l.description).join(' ')}`.toLowerCase().includes(query));
  list.replaceChildren();
  for(const chapter of visible){
   const available=chapter.lessons.length>0;
   const row=make('article',`chapter${available?' available':''}`);
   row.append(make('div','chapter-number',String(chapter.number).padStart(2,'0')));
   const content=make('div','chapter-content');
   const heading=make('div','chapter-heading');
   heading.append(make('h3','',chapter.title),make('span',`badge${available?' ready':''}`,available?`${chapter.lessons.length} 讲已接入`:'待接入'));
   content.append(heading,make('p','summary',chapter.summary));
   const tags=make('div','topics');chapter.topics.forEach(topic=>tags.append(make('span','',topic)));content.append(tags);
   for(const lesson of chapter.lessons){
    const item=make('div','lesson');
    const details=make('div','lesson-details');
    details.append(make('span','lesson-code',`第${chapter.number}章 ${lesson.code}`),make('h4','',lesson.title),make('p','',lesson.description));
    const entry=make('div','lesson-entry');
    if(lesson.screens)entry.append(make('span','screen-count',`${lesson.screens} 屏 · 动静课件`));
    const link=make('a','lesson-link','进入课件 ↗');link.href=lesson.href;link.target='_blank';link.rel='noopener';link.setAttribute('aria-label',`打开第${chapter.number}章${lesson.code} ${lesson.title}（新标签页）`);entry.append(link);
    item.append(details,entry);content.append(item);
   }
   row.append(content);list.append(row);
  }
  document.querySelector('#no-results').hidden=visible.length>0;
  document.querySelector('#result-status').textContent=`显示 ${visible.length} 个章节`;
 }
 document.querySelector('#search').addEventListener('input',render);
 document.querySelectorAll('[data-filter]').forEach(button=>button.addEventListener('click',()=>{filter=button.dataset.filter;document.querySelectorAll('[data-filter]').forEach(b=>b.setAttribute('aria-pressed',String(b===button)));render();}));
 render();
 // The illustration is a sine wave with uniformly spaced samples.
 const ns='http://www.w3.org/2000/svg';
 const layer=document.querySelector('#signal-trace');
 const y=x=>105-62*Math.sin((x-25)/450*Math.PI*3.4);
 const path=document.createElementNS(ns,'path');
 path.setAttribute('d',Array.from({length:451},(_,i)=>`${i?'L':'M'}${i+25} ${y(i+25).toFixed(2)}`).join(' '));
 path.setAttribute('fill','none');path.setAttribute('stroke','#087e85');path.setAttribute('stroke-width','2.4');layer.append(path);
 for(let i=0;i<20;i++){
  const x=25+i*450/19;
  const line=document.createElementNS(ns,'line');Object.entries({x1:x,x2:x,y1:105,y2:y(x),stroke:'#bd6a2a','stroke-width':1.4,opacity:.55}).forEach(([k,v])=>line.setAttribute(k,v));
  const circle=document.createElementNS(ns,'circle');Object.entries({cx:x,cy:y(x),r:3.3,fill:'#bd6a2a'}).forEach(([k,v])=>circle.setAttribute(k,v));layer.append(line,circle);
 }
})();
