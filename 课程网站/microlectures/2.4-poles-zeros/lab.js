let currentConfig;
const canvas=document.querySelector('#lab'),ctx=canvas.getContext('2d');
function drawLab(){
 const c=DATA.cases[+document.querySelector('#radius').value],k=+document.querySelector('#gain').value,j=+document.querySelector('#omega').value,mode=document.querySelector('#mode').value,w=DATA.w_pi[j]*Math.PI,amp=c.amp[j]*k,phase=c.phase[j];
 currentConfig={r:c.r,gain:k,index:j,omega:w,amp,phase,peak:c.peak*k,peak_w_pi:c.peak_w_pi,mode};
 const light=document.documentElement.dataset.theme==='light',fg=light?'#182e43':'#eaf2f7',green=light?'#007b6c':'#4dd7c2',gold=light?'#985000':'#ffc66f',red=light?'#b42f4f':'#fb889a';ctx.fillStyle=light?'#e3ebf1':'#183043';ctx.fillRect(0,0,1100,460);ctx.lineWidth=2;
 const point=[Math.cos(w),Math.sin(w)],p=c.r/Math.sqrt(2),pts=[[0,0],[-1,0],[p,p],[p,-p]],xy=z=>[245+140*z[0],230-140*z[1]];
 function line(a,b,col){ctx.strokeStyle=col;ctx.beginPath();ctx.moveTo(...a);ctx.lineTo(...b);ctx.stroke();}
 ctx.strokeStyle=fg;ctx.beginPath();ctx.arc(245,230,140,0,7);ctx.stroke();line([50,230],[460,230],fg);line([245,50],[245,410],fg);
 pts.forEach((z,i)=>{const [x,y]=xy(z),col=i<2?green:red;line([x,y],xy(point),col);ctx.strokeStyle=col;if(i<2){ctx.beginPath();ctx.arc(x,y,6,0,7);ctx.stroke();}else{line([x-7,y-7],[x+7,y+7],col);line([x-7,y+7],[x+7,y-7],col);}});
 ctx.fillStyle=gold;ctx.beginPath();ctx.arc(...xy(point),6,0,7);ctx.fill();ctx.fillStyle=fg;ctx.font='21px sans-serif';ctx.fillText('○ 零点 0、−1；× 共轭极点',45,32);ctx.fillText('单位圆：测试点 z=e^{jω}',50,440);
 const l=580,r=1040,t=80,b=352,lo=mode==='phase'?-Math.PI:0,hi=mode==='phase'?Math.PI:60,to=(n,v)=>[l+n/800*(r-l),b-(v-lo)/(hi-lo)*(b-t)];
 ctx.font='17px sans-serif';for(const v of [...new Set([lo,0,hi])]){let yy=to(0,v)[1];line([l,yy],[r,yy],fg);ctx.fillText(v.toFixed(2),l-51,yy-5);}
 ctx.fillText('0',l,b+26);ctx.fillText('1',r,b+26);ctx.fillText('ω/π',r-30,b+55);ctx.font='22px sans-serif';ctx.fillText(mode==='phase'?'相位（弧度）':'幅值 |H|（固定纵轴）',l,35);
 const arrays=mode==='phase'?[[c.phase,green],[c.phase.map((v,i)=>v===null?null:Math.atan2(Math.sin(v-DATA.w_pi[i]*Math.PI),Math.cos(v-DATA.w_pi[i]*Math.PI))),red]]:[[c.amp.map(v=>v*k),gold]];
 for(const [ys,col] of arrays){ctx.strokeStyle=col;ctx.beginPath();let prev=null;ys.forEach((v,i)=>{if(v===null){prev=null;return;}const q=to(i,v);if(prev===null||(mode==='phase'&&Math.abs(v-prev)>Math.PI))ctx.moveTo(...q);else ctx.lineTo(...q);prev=v;});ctx.stroke();if(ys[j]!==null){ctx.fillStyle=col;ctx.beginPath();ctx.arc(...to(j,ys[j]),5,0,7);ctx.fill();}}
 const ds=pts.map(z=>Math.hypot(point[0]-z[0],point[1]-z[1]));
 document.querySelector('#metrics').textContent=`ω/π=${(w/Math.PI).toFixed(4)}；|H|=${amp.toFixed(5)}；相位${phase===null?'未定义（零响应）':'='+phase.toFixed(5)+' rad'}；网格峰位≈${c.peak_w_pi.toFixed(5)}π，峰高≈${(c.peak*k).toFixed(4)}。`;
 document.querySelector('#legend').textContent=`距离比：${k} × ${ds[0].toFixed(3)} × ${ds[1].toFixed(3)} / (${ds[2].toFixed(3)} × ${ds[3].toFixed(3)})。`+(mode==='phase'?'绿线为完整相位；红线漏掉原点零点，少了ω项（按模2π）。主值跳变处断线。':'绿向量来自零点，红向量来自极点；改变正实增益只缩放幅值。');
}
for(const id of ['radius','gain','omega','mode'])document.querySelector('#'+id).addEventListener(id==='omega'?'input':'change',drawLab);
document.querySelector('#quiz').addEventListener('submit',e=>{e.preventDefault();const f=new FormData(e.target),a=['q1','q2','q3'];document.querySelector('#feedback').textContent=a.some(k=>!f.has(k))?'请先完成三道题。':a.map((k,i)=>`${i+1}：${f.get(k)===['b','a','b'][i]?'正确':'再想一想'}。${['原点向量长度为1、角度为ω。','峰位由全部零极点及因子决定。','零初始启动仍可能有衰减暂态。'][i]}`).join(' ');});
drawLab();
