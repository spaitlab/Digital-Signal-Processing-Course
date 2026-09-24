let currentConfig;
const canvas=document.querySelector('#lab'),ctx=canvas.getContext('2d');
function drawLab(){
 const id=+document.querySelector('#case').value,N=+document.querySelector('#count').value,left=id===4;
 document.querySelector('#count').disabled=left;
 const d=window.DATA,c=left?{n:d.nl,h:d.hl,step:d.left_step,stable:true,causal:false}:d.configs[id];
 const xs=left?c.n:c.n.slice(0,N),hs=left?c.h:c.h.slice(0,N),ys=left?c.step:c.step.slice(0,N),ns=left?d.tn:xs;
 currentConfig={...c,N,partial:hs.reduce((a,b)=>a+Math.abs(b),0),last:ys.at(-1)};
 const light=document.documentElement.dataset.theme==='light',fg=light?'#182e43':'#eaf2f7',green=light?'#007b6c':'#4dd7c2',gold=light?'#985000':'#ffc66f';
 ctx.fillStyle=light?'#e3ebf1':'#183043';ctx.fillRect(0,0,1100,450);
 function plot(x,n,y,color,title){
  const l=x+58,r=x+485,t=85,b=338,lo=Math.min(0,...y),hi=Math.max(0,...y),span=hi-lo||1;
  const xy=(k,v)=>[l+(k-n[0])/(n.at(-1)-n[0])*(r-l),b-(v-lo)/span*(b-t)];
  ctx.fillStyle=fg;ctx.font='22px sans-serif';ctx.fillText(title,x+30,40);ctx.font='17px sans-serif';
  for(const v of [lo,hi]){let yy=xy(n[0],v)[1];ctx.fillText(v.toPrecision(3),x+3,yy-5);ctx.strokeStyle=fg;ctx.beginPath();ctx.moveTo(l,yy);ctx.lineTo(r,yy);ctx.stroke();}
  ctx.fillText(n[0],l,363);ctx.fillText(n.at(-1),r-20,363);ctx.fillText('n',r,392);
  ctx.strokeStyle=color;ctx.fillStyle=color;ctx.lineWidth=2;
  n.forEach((k,i)=>{const [px,py]=xy(k,y[i]);ctx.beginPath();ctx.moveTo(px,xy(k,0)[1]);ctx.lineTo(px,py);ctx.stroke();ctx.beginPath();ctx.arc(px,py,2.5,0,7);ctx.fill();});
 }
 plot(0,xs,hs,green,'脉冲响应 h[n]');plot(550,ns,ys,gold,'输入 u[n] 的输出 y[n]');
 document.querySelector('#metrics').textContent=`有限窗口 Σ|h|=${currentConfig.partial.toPrecision(6)}；输出末点=${currentConfig.last.toPrecision(6)}。定理判断：${c.stable?'稳定':'不稳定'}，${c.causal?'因果':'非因果'}。`;
 document.querySelector('#legend').textContent=left?'左图仅显示n=−40…0，右图显示n=−10…10；输出使用无限级数解析式，n<0已出现响应。无限绝对和为5；依赖未来输入。':id===3?'h[n]虽趋于0，但调和级数每个倍增分组之和≥1/2，因此阶跃输出无界。':id===0?'几何级数绝对和为5；对任意|x[n]|≤M，有|y[n]|≤5M。':id===1?'h[n]=u[n]；阶跃输出y[n]=n+1，无界。':'因果h[n]=1.2^n u[n]，阶跃输出指数增长，无界。';
}
for(const id of ['case','count'])document.querySelector('#'+id).addEventListener('change',drawLab);
document.querySelector('#quiz').addEventListener('submit',e=>{e.preventDefault();const f=new FormData(e.target),a=['q1','q2','q3'];document.querySelector('#feedback').textContent=a.some(k=>!f.has(k))?'请先完成三道题。':a.map((k,i)=>`${i+1}：${f.get(k)===['b','a','b'][i]?'正确':'再想一想'}。${['衰减不是绝对可和的充分条件。','绝对可和给出所有有界输入的统一上界。','稳定取决于ROC是否包含单位圆。'][i]}`).join(' ');});
drawLab();
