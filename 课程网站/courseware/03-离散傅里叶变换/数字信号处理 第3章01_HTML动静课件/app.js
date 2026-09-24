(()=>{'use strict';
const $=s=>document.querySelector(s),a=$('#voice'),cv=$('#plot'),ctx=cv.getContext('2d'),F=window.Fourier,slides=window.SLIDES;
const C={ink:'#1c303c',muted:'#71858e',grid:'#e6eded',gray:'#b9c4c6',teal:'#087e85',orange:'#be641a',blue:'#6483ad'};
let page=0,raf=0,lastCue=-1,manual=false,token=0,observed={},quizIndex=0,quizSelection=null;
const clamp=(v,l=0,h=1)=>Math.max(l,Math.min(h,v)),s=()=>slides[page],time=()=>a.getAttribute('src')?a.currentTime:0;
const cue=()=>{let i=s().units.findIndex(u=>time()<u.end);return i<0?s().units.length-1:i;};
const fraction=()=>{const u=s().units[cue()];return clamp((time()-u.start)/(u.end-u.start||1));};
const progress=()=>clamp(time()/(s().duration||1));
function text(x,y,t,size=19,color=C.muted,align='left'){ctx.fillStyle=color;ctx.font=`${size}px "Microsoft YaHei",sans-serif`;ctx.textAlign=align;ctx.fillText(t,x,y);}
function line(x1,y1,x2,y2,color=C.grid,width=1){ctx.beginPath();ctx.moveTo(x1,y1);ctx.lineTo(x2,y2);ctx.strokeStyle=color;ctx.lineWidth=width;ctx.stroke();}
function dot(x,y,color=C.teal,r=4){ctx.beginPath();ctx.arc(x,y,r,0,2*Math.PI);ctx.fillStyle='#fff';ctx.fill();ctx.strokeStyle=color;ctx.lineWidth=2;ctx.stroke();}
function graph({x=68,y=40,w=802,h=94,xmin=-12,xmax=12,ymin=-.15,ymax=1.3,ticks=[-8,0,8],labels=null,title='',unit=''}={}){
 const g={x,y,w,h,xmin,xmax,ymin,ymax,px:v=>x+(v-xmin)/(xmax-xmin)*w,py:v=>y+(ymax-v)/(ymax-ymin)*h};
 text(x,y-13,title,21,C.ink);line(x,g.py(0),x+w,g.py(0),'#bbc9cc');
 for(let i=0;i<ticks.length;i++){const px=g.px(ticks[i]);line(px,y,px,y+h);text(px,y+h+22,labels?labels[i]:String(ticks[i]),17,C.muted,'center');}
 for(const v of [ymin<-.2?-1:0,1,...(ymax>3?[3]:[])])if(v>=ymin&&v<=ymax){line(x,g.py(v),x+w,g.py(v));text(x-12,g.py(v)+5,String(v),16,C.muted,'right');}
 text(x+w,y+h+44,unit,17,C.muted,'right');return g;
}
function curve(g,fn,color=C.teal,width=2.5,dash=[]){ctx.save();ctx.beginPath();ctx.rect(g.x,g.y,g.w,g.h);ctx.clip();ctx.setLineDash(dash);ctx.beginPath();for(let i=0;i<=900;i++){const x=g.xmin+(g.xmax-g.xmin)*i/900;const y=fn(x);if(i)ctx.lineTo(g.px(x),g.py(y));else ctx.moveTo(g.px(x),g.py(y));}ctx.strokeStyle=color;ctx.lineWidth=width;ctx.stroke();ctx.restore();}
function stems(g,values,color=C.orange){ctx.save();ctx.beginPath();ctx.rect(g.x-5,g.y-5,g.w+10,g.h+10);ctx.clip();for(const [x,y] of values){if(x<g.xmin||x>g.xmax)continue;line(g.px(x),g.py(0),g.px(x),g.py(y),color,1.7);dot(g.px(x),g.py(y),color,3.5);}ctx.restore();}
function legends(items){$('#legend').replaceChildren(...items.map(([t,c])=>{const e=document.createElement('span'),i=document.createElement('i');i.style.setProperty('--c',c);e.append(i,t);return e;}));}
function note(meta,caption,items){$('#scene-meta').textContent=meta;$('#visual-caption').textContent=caption;legends(items);}
function controls(ids){$('#controls').hidden=!ids.length;document.querySelectorAll('[data-control]').forEach(e=>e.hidden=!ids.includes(e.dataset.control));}
const names={ctft:'CTFT',fs:'FS',dtft:'DTFT',dfs:'DFS'};
const forms=['ctft','fs','dtft','dfs'];
function overview(){
 let active=manual?forms.indexOf($('#form').value):(s().kind==='matrix'?(cue()===0?(fraction()<.5?0:1):cue()===1?(fraction()<.5?2:3):Math.min(3,Math.floor(fraction()*4))):Math.min(3,Math.floor(progress()*4)));
 if(!manual)$('#form').value=forms[active];controls(['form']);
 text(270,23,'时域',21,C.ink,'center');text(663,23,'频域',21,C.ink,'center');
 forms.forEach((form,i)=>{
  const y=35+i*79;ctx.fillStyle=i===active?'#edf6f4':'#fafbf9';ctx.fillRect(5,y,889,74);
  text(19,y+27,names[form],23,i===active?C.teal:C.ink);text(19,y+52,['连续 / 非周期','连续 / 周期','离散 / 非周期','离散 / 周期'][i],16);
  const top={x:178,y:y+8,w:253,h:47,xmin:-12,xmax:12,ymin:-.2,ymax:1.3};top.px=v=>top.x+(v+12)/24*top.w;top.py=v=>top.y+(1.3-v)/1.5*top.h;
  line(top.x,top.py(0),top.x+top.w,top.py(0));
  if(i<2)curve(top,t=>i===0?F.pulse(t):F.periodicPulse(t,8));else stems(top,Array.from({length:25},(_,j)=>[j-12,F.sequence(j-12,i===3?8:0)]),C.teal);
  const bot={x:496,y:y+8,w:355,h:47,xmin:-2*Math.PI,xmax:2*Math.PI,ymin:-.2,ymax:i===1?.43:3.3};bot.px=v=>bot.x+(v-bot.xmin)/(bot.xmax-bot.xmin)*bot.w;bot.py=v=>bot.y+(bot.ymax-v)/(bot.ymax-bot.ymin)*bot.h;
  line(bot.x,bot.py(0),bot.x+bot.w,bot.py(0));
  if(i===0)curve(bot,w=>Math.abs(F.P(w)),C.orange);if(i===1)stems(bot,Array.from({length:17},(_,j)=>{let m=j-8;return[m*Math.PI/4,Math.abs(F.coefficient(m,8))];}));
  if(i===2)curve(bot,w=>Math.abs(F.X(w)),C.orange);if(i===3)stems(bot,Array.from({length:17},(_,j)=>{let k=j-8;return[k*Math.PI/4,Math.abs(F.dfs(k,8))];}));
  text(430,y+68,i<2?'t / s':'n',14,C.muted,'right');text(853,y+68,i<2?'Ω / rad·s⁻¹':'ω / rad·sample⁻¹',14,C.muted,'right');
 });
 note('四种表示 · 幅度谱对照','连续脉冲宽 3 s；离散序列有三个非零样本。周期示例 T = 8 s、N = 8；各行纵轴分别缩放。',[['时间信号',C.teal],['频域幅度 / 系数幅度',C.orange]]);observed={kind:s().kind,form:forms[active]};
}
function continuous(form,T=8){
 const isPeriodic=form==='fs'||form==='spacing';
 const xmax=isPeriodic?Math.max(12,T*1.25):6;
 const g=graph({xmin:-xmax,xmax,ticks:isPeriodic?[-T,0,T]:[-3,0,3],title:isPeriodic?`周期脉冲 pT(t) · T = ${T} s`:'孤立脉冲 p(t) · 宽 3 s',unit:'时间 t / s'});
 curve(g,t=>isPeriodic?F.periodicPulse(t,T):F.pulse(t));
 const scaled=form==='spacing';const ymax=form==='fs'?3/T*1.15:3.3;
 const h=graph({y:222,h:89,xmin:-2*Math.PI,xmax:2*Math.PI,ymin:-.05,ymax,ticks:[-2*Math.PI,-Math.PI,0,Math.PI,2*Math.PI],labels:['−2π','−π','0','π','2π'],title:form==='ctft'?'幅度 |P(jΩ)|':scaled?'缩放系数 T|cm| 与 |P(jΩ)|':'FS 系数幅度 |cm|',unit:'连续角频率 Ω / rad·s⁻¹'});
 if(form==='ctft'){
  curve(h,w=>Math.abs(F.P(w)),C.orange);const w=-5.5+11*progress();dot(h.px(w),h.py(Math.abs(F.P(w))),C.teal,5);
  note('CTFT · 连续频率','Ω = 0 处 P(0) = 3。曲线是解析式的绘图，Ω 的定义域不是离散网格。',[['时间信号',C.teal],['|P(jΩ)|',C.orange]]);
 }else{
  if(scaled)curve(h,w=>Math.abs(F.P(w)),C.gray,2,[5,4]);
  const max=Math.floor(T);stems(h,Array.from({length:2*max+1},(_,j)=>{const m=j-max;return[2*Math.PI*m/T,Math.abs(F.coefficient(m,T))*(scaled?T:1)];}));
  if(form==='fs'&&s().kind!=='lab'){const m=Math.min(4,Math.floor(progress()*5));dot(h.px(2*Math.PI*m/T),h.py(Math.abs(F.coefficient(m,T))),C.teal,5);}
  text(842,248,`直流${scaled?'（缩放前）':''} c₀ = ${(3/T).toFixed(4)}`,18,C.ink,'right');
  note(`T = ${T} s · ΔΩ = ${(2*Math.PI/T).toFixed(3)} rad/s`,scaled?'脉冲宽度不变；T 增大使谱线更密、原始 c₀ 更小。图中谱线已乘 T，以便比较包络。':'谱线位置 Ω = m·2π/T，m 为整数；纵轴是系数幅度，不是冲激权重。',[['时间信号',C.teal],[scaled?'T|cm|':'|cm|',C.orange],...(scaled?[['|P| 包络',C.gray]]:[])]);
 }
 observed={kind:form,T,spacing:2*Math.PI/T,dc:3/T,scaled};
}
function discrete(form,N=8){
 const periodic=form==='dfs';const xmax=periodic?Math.max(10,N+2):6;
 const g=graph({xmin:-xmax,xmax,ticks:periodic?[-N,0,N]:[-4,0,4],title:periodic?`周期序列 x̃[n] · N = ${N}`:'三点序列 x[n] · n = −1, 0, 1',unit:'时间索引 n'});
 stems(g,Array.from({length:xmax*2+1},(_,j)=>[j-xmax,F.sequence(j-xmax,periodic?N:0)]),C.teal);
 const h=graph({y:222,h:89,xmin:-2*Math.PI,xmax:4*Math.PI,ymin:-1.3,ymax:3.3,ticks:[-2*Math.PI,0,2*Math.PI,4*Math.PI],labels:['−2π','0','2π','4π'],title:periodic?'DFS 系数 X̃[k] · 带符号实值':'DTFT：X(eʲω) = 1 + 2 cos ω · 带符号实值',unit:'数字角频率 ω / rad·sample⁻¹'});
 curve(h,F.X,periodic?C.gray:C.orange,2.5,periodic?[6,4]:[]);
 if(periodic){
  stems(h,Array.from({length:3*N+1},(_,j)=>{const k=j-N;return[2*Math.PI*k/N,F.dfs(k,N)];}));
  const k=Math.min(N-1,Math.floor(progress()*N));dot(h.px(2*Math.PI*k/N),h.py(F.dfs(k,N)),C.teal,5);
  note(`N = ${N} · Δω = 2π/${N}`,`一个周期内非零位置为 0、1、${N-1}；橙点是 DFS 系数，灰线仅作 DTFT 对照。正变换不除以 N。`,[['离散样本',C.teal],['DFS 系数',C.orange],['DTFT 参照',C.gray]]);
  observed={kind:'dfs',N,spacing:2*Math.PI/N,dc:F.dfs(0,N),values:Array.from({length:N},(_,k)=>F.dfs(k,N))};
 }else{
  const w=manual||s().kind==='lab'?Number($('#omega').value)*Math.PI:(cue()<2?Math.PI*fraction():cue()===2?Math.PI*(.2+1.2*fraction()):Math.PI);
  if(!manual&&s().kind!=='lab')$('#omega').value=w/Math.PI;$('#omega-value').textContent=(w/Math.PI).toFixed(2);
  for(const [freq,col] of [[w,C.teal],[w+2*Math.PI,C.blue]]){line(h.px(freq),h.y,h.px(freq),h.y+h.h,col,1.3);dot(h.px(freq),h.py(F.X(freq)),col,5);}
  note('连续 ω · 频域周期 2π',`ω = ${(w/Math.PI).toFixed(2)}π：X = ${F.X(w).toFixed(3)}，|X| = ${Math.abs(F.X(w)).toFixed(3)}；ω + 2π 处的函数值相同。`,[['样本 / 当前 ω',C.teal],['X(eʲω) 实值',C.orange],['ω + 2π',C.blue]]);
  observed={kind:'dtft',omega:w,value:F.X(w),shifted:F.X(w+2*Math.PI)};
 }
}
function projection(){
 const m=manual?Number($('#m').value):2,r=manual?Number($('#r').value):(cue()<4?2:1),q=m-r;
 const u=manual?Number($('#cycle').value):([3,4].includes(cue())?fraction():1);
 if(!manual){$('#m').value=m;$('#r').value=r;$('#cycle').value=u;}$('#cycle-value').textContent=u.toFixed(2);
 text(35,27,'乘积相量 eʲ⁽ᵐ⁻ʳ⁾Ω₀t',22,C.ink);
 // Keep the complex unit circle circular even in the compact projector layout.
 const cx=170,cy=145,R=70,Ry=R*(cv.clientWidth/900)/(cv.clientHeight/360);ctx.beginPath();ctx.ellipse(cx,cy,R,Ry,0,0,2*Math.PI);ctx.strokeStyle=C.grid;ctx.lineWidth=2;ctx.stroke();line(cx-100,cy,cx+100,cy);line(cx,cy-Ry-10,cx,cy+Ry+10);text(cx+104,cy+7,'Re',18);text(cx+5,cy-Ry-16,'Im',18);
 const angle=2*Math.PI*q*u;line(cx,cy,cx+R*Math.cos(angle),cy-Ry*Math.sin(angle),C.teal,3);dot(cx+R*Math.cos(angle),cy-Ry*Math.sin(angle),C.teal,6);
 const g=graph({x:365,y:55,w:485,h:158,xmin:0,xmax:1,ymin:-1.2,ymax:1.2,ticks:[0,.5,1],title:'归一化积分：实部与虚部的贡献',unit:'归一化时间 t/T'});
 curve(g,x=>Math.cos(2*Math.PI*q*x),C.teal);curve(g,x=>Math.sin(2*Math.PI*q*x),C.blue,2,[6,4]);line(g.px(u),g.y,g.px(u),g.y+g.h,C.orange,2);
 const integral=F.integral(q,u);text(36,289,`m = ${m}，r = ${r}；已积分到 t/T = ${u.toFixed(2)}`,23,C.ink);
 text(36,332,`∫₀ᵗ/ᵀ eʲ²π⁽ᵐ⁻ʳ⁾ᵛ dv = ${(Math.abs(integral.re)<1e-10?0:integral.re).toFixed(3)} ${integral.im< -1e-10?'−':'+'} j${Math.abs(integral.im).toFixed(3)}`,25,C.teal);
 note('完整周期的积分才给出正交结论',q===0?'同序号：乘积恒为 1。积分到一个完整周期并除以 T，结果为 1。':'不同整数序号：只有完成一个周期，正负贡献才完全抵消；中途的积分一般不为零。',[['实部 cos',C.teal],['虚部 sin',C.blue],['积分位置',C.orange]]);
 observed={kind:'projection',m,r,u,integral};
}
const questions=[
 {q:'一个离散、非周期的序列，它的 DTFT 频率变量是什么？',options:['连续变量，频谱以 2π 为周期','只能取离散点，频谱没有周期','只有 N 个频率，且 N 未知'],answer:0,why:'DTFT 中 ω 可连续取值；n 为整数使 e^(−j2πn) = 1，因此频谱以 2π 为周期。'},
 {q:'脉冲宽度保持 3 s，重复周期从 8 s 变成 16 s。谱线间隔与 c₀ 怎样变化？',options:['间隔减半，c₀ 不变','间隔减半，c₀ 也减半','间隔加倍，c₀ 减半'],answer:1,why:'ΔΩ = 2π/T，c₀ = 3/T。T 加倍，二者都减半；画 T|cm| 时直流高度才仍为 3。'},
 {q:'三点序列的 DTFT 在 ω = π 处等于 −1。它的幅度是多少？',options:['−1','0','1'],answer:2,why:'本例 X(eʲω) = 1 + 2 cos ω，所以 X(π) = −1；幅度是绝对值 |X(π)| = 1。'}
];
function renderQuiz(){
 const q=questions[quizIndex];quizSelection=null;$('#quiz-count').textContent=`课堂判断 ${quizIndex+1} / ${questions.length}`;$('#quiz-question').textContent=q.q;
 $('#quiz-options').innerHTML='<legend class="sr-only">选择你的判断</legend>';
 q.options.forEach((v,i)=>{const label=document.createElement('label'),input=document.createElement('input');input.type='radio';input.name='quiz';input.value=i;input.onchange=()=>{quizSelection=i;$('#quiz-check').disabled=false;$('#quiz-feedback').textContent='已选择，点击“检查判断”查看依据。';};label.append(input,v);$('#quiz-options').append(label);});
 $('#quiz-check').disabled=true;$('#quiz-feedback').textContent='请选择一个判断，答案暂不显示。';$('#quiz-next').textContent=quizIndex===questions.length-1?'回到第 1 题':'下一题 →';
}
$('#quiz-check').onclick=()=>{if(quizSelection===null)return;const q=questions[quizIndex];$('#quiz-feedback').textContent=(quizSelection===q.answer?'判断正确。':'再核对一下。')+q.why;};
$('#quiz-next').onclick=()=>{quizIndex=(quizIndex+1)%questions.length;renderQuiz();};
function draw(){
 const scale=Math.min(devicePixelRatio||1,2);if(cv.width!==900*scale||cv.height!==360*scale){cv.width=900*scale;cv.height=360*scale;}ctx.setTransform(scale,0,0,scale,0,0);ctx.clearRect(0,0,900,360);
 const kind=s().kind;observed={};$('#visual-mode').textContent=['lab','quiz'].includes(kind)?'课堂互动':'动态演示';
 cv.hidden=kind==='quiz';$('#quiz-panel').hidden=kind!=='quiz';
 if(kind==='quiz'){controls([]);note('先选择 · 后检查','可回到对应演示页验证；“下一题”不会自动展示答案。',[]);observed={kind,quizIndex};return;}
 if(kind==='overview'||kind==='matrix'){overview();return;}
 if(kind==='projection'){controls(['m','r','cycle']);projection();return;}
 if(kind==='ctft'){controls([]);continuous(kind);return;}
 if(kind==='fs'||kind==='spacing'){
  const T=manual?Number($('#period').value):(kind==='fs'?8:cue()<1?8:cue()<5?16:32);if(!manual)$('#period').value=T;
  controls(['period']);continuous(kind,T);return;
 }
 if(kind==='dtft'){controls(['omega']);discrete(kind);return;}
 if(kind==='dfs'){controls(['size']);const N=manual?Number($('#size').value):8;if(!manual)$('#size').value=N;discrete(kind,N);return;}
 if(kind==='lab'){
  const form=$('#form').value;controls(['form',...(form==='fs'?['period']:form==='dfs'?['size']:form==='dtft'?['omega']:[])]);
  if(form==='ctft'||form==='fs')continuous(form,Number($('#period').value));else discrete(form,Number($('#size').value));observed.lab=true;
 }
}
const fmt=t=>`${Math.floor(t/60)}:${String(Math.floor(t%60)).padStart(2,'0')}`;
function update(){
 const i=cue();if(i!==lastCue){$('#transcript').textContent=s().units[i].text;lastCue=i;}
 $('#cue-index').textContent=s().audio?`${i+1} / ${s().units.length}`:'自由互动';$('#clock').textContent=s().audio?`${fmt(time())} / ${fmt(s().duration)}`:'无配音';$('#seek').value=time();
 $('#prev-cue').disabled=!s().audio||i===0;$('#next-cue').disabled=!s().audio||i===s().units.length-1;draw();
}
function playing(){const on=!!s().audio&&!a.paused;$('#play').innerHTML=on?'Ⅱ<span>暂停讲解</span>':'▶<span>播放讲解</span>';$('#play').setAttribute('aria-label',on?'暂停讲解':'播放讲解');}
function tick(){update();if(!a.paused)raf=requestAnimationFrame(tick);}
function navigate(n){
 n=clamp(n,0,slides.length-1);token++;a.pause();cancelAnimationFrame(raf);page=n;manual=false;lastCue=-1;
 $('#section').textContent=`CHAPTER 03 / ${String(n+1).padStart(2,'0')}`;$('#title').textContent=s().title;$('#lead').textContent=s().lead;$('#concept').textContent=s().concept;$('#formula').innerHTML=s().formula;$('#points').innerHTML=s().points.map(p=>`<p>${p}</p>`).join('');$('#takeaway').textContent=s().takeaway;cv.setAttribute('aria-label',s().title+'。'+s().takeaway);
 $('#page-number').textContent=`${String(n+1).padStart(2,'0')} / ${slides.length}`;$('#prev').disabled=n===0;$('#next').disabled=n===slides.length-1;
 document.querySelectorAll('#pages button').forEach((b,i)=>i===n?b.setAttribute('aria-current','step'):b.removeAttribute('aria-current'));
 const active=$(`#pages button[data-page="${n}"]`),nav=$('#pages');if(active.offsetLeft<nav.scrollLeft||active.offsetLeft+active.offsetWidth>nav.scrollLeft+nav.clientWidth)nav.scrollLeft=active.offsetLeft-nav.offsetLeft;
 $('#form').value='ctft';$('#period').value='8';$('#size').value='8';$('#omega').value='0';$('#cycle').value='1';
 for(const id of ['play','reset','seek','sound','speed'])$('#'+id).disabled=!s().audio;
 if(s().audio){a.src=s().audio;a.load();a.playbackRate=Number($('#speed').value);a.muted=!$('#sound').checked;$('#seek').max=s().duration;}else{a.removeAttribute('src');a.load();$('#seek').value=0;}
 if(s().kind==='quiz'){quizIndex=0;renderQuiz();}
 $('#status').textContent=s().audio?'空格播放 / 暂停，左右键翻页；调整参数暂停讲解，再播放恢复讲稿参数。':'自由互动，无配音；先预测，再操作。';
 try{history.replaceState(null,'',`#${n+1}`);}catch(e){}playing();update();
}
async function toggle(){if(!s().audio)return;if(!a.paused){a.pause();return;}manual=false;if(time()>=s().duration-.1)a.currentTime=0;let v=token;try{await a.play();if(v===token)$('#status').textContent='讲解与演示同步播放；每屏结束后停留，便于课堂讨论。';}catch(e){if(v===token)$('#status').textContent='音频暂时无法播放，请检查 assets 文件夹。';}}
$('#pages').innerHTML=slides.map((x,i)=>`<button data-page="${i}" aria-label="第 ${i+1} 屏 ${x.nav}">${String(i+1).padStart(2,'0')} ${x.nav}</button>`).join('');
$('#pages').onclick=e=>{const b=e.target.closest('button');if(b)navigate(Number(b.dataset.page));};$('#prev').onclick=()=>navigate(page-1);$('#next').onclick=()=>navigate(page+1);$('.brand').onclick=e=>{e.preventDefault();navigate(0);};$('#play').onclick=toggle;
$('#reset').onclick=()=>{manual=false;a.pause();a.currentTime=0;update();};$('#seek').oninput=e=>{manual=false;a.currentTime=Number(e.target.value);update();};$('#sound').onchange=()=>a.muted=!$('#sound').checked;$('#speed').onchange=()=>a.playbackRate=Number($('#speed').value);
function seekCue(delta){if(!s().audio)return;manual=false;a.currentTime=s().units[clamp(cue()+delta,0,s().units.length-1)].start+.015;update();}$('#prev-cue').onclick=()=>seekCue(-1);$('#next-cue').onclick=()=>seekCue(1);
document.querySelectorAll('#controls select,#controls input').forEach(e=>e.addEventListener('input',()=>{a.pause();manual=true;draw();if(s().audio)$('#status').textContent='已暂停，正在手动观察。再次播放将恢复讲稿参数。';}));
a.onplay=()=>{cancelAnimationFrame(raf);playing();tick();};a.onpause=()=>{cancelAnimationFrame(raf);playing();update();};a.onseeked=update;a.onloadedmetadata=()=>{a.playbackRate=Number($('#speed').value);update();};a.onended=()=>{playing();update();$('#status').textContent='本屏讲解结束，可讨论或进入下一屏。';};a.onerror=()=>{if(s().audio&&a.getAttribute('src'))$('#status').textContent='未能加载音频，请检查 assets 文件夹。';};
document.addEventListener('keydown',e=>{if(e.isComposing||e.target.closest('input,textarea,select,button,summary,a')||e.altKey||e.ctrlKey||e.metaKey)return;if(e.code==='Space'){e.preventDefault();toggle();}if(e.code==='ArrowLeft'){e.preventDefault();navigate(page-1);}if(e.code==='ArrowRight'){e.preventDefault();navigate(page+1);}});
$('#full').onclick=async()=>{try{document.fullscreenElement?await document.exitFullscreen():await $('.deck').requestFullscreen();}catch(e){$('#status').textContent='可使用浏览器 F11 全屏。';}};
document.addEventListener('fullscreenchange',()=>$('#full').textContent=document.fullscreenElement?'退出全屏':'全屏投影');document.addEventListener('visibilitychange',()=>{if(document.hidden)a.pause();});window.addEventListener('resize',draw);window.addEventListener('hashchange',()=>{const n=Number(location.hash.slice(1))-1;if(Number.isInteger(n)&&n>=0&&n<slides.length&&n!==page)navigate(n);});
window.lessonState=()=>({page,time:time(),cue:cue(),manual,...observed});const hash=Number(location.hash.slice(1));navigate(hash>=1&&hash<=slides.length?hash-1:0);
})();
