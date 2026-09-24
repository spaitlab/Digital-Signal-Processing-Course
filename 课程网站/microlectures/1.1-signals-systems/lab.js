function drawLab(){
 const cv=document.querySelector('#lab');if(!cv)return;const ctx=cv.getContext('2d');const fs=Number(document.querySelector('#fs').value),bits=Number(document.querySelector('#bits').value);
 const cfg=window.DATA.configs.find(c=>c.fs===fs&&c.bits===bits);window.currentConfig=cfg;
 const s=getComputedStyle(document.body),fg=s.getPropertyValue('--fg'),mut=s.getPropertyValue('--mut'),accent=s.getPropertyValue('--accent'),light=document.documentElement.dataset.theme==='light',gold=light?'#985000':'#ffc66f',red=light?'#b42f4f':'#fb889a';
 ctx.clearRect(0,0,1100,350);ctx.font='18px Microsoft YaHei';const px=t=>60+t*1000,py=y=>165-y*125;
 ctx.strokeStyle=mut;ctx.lineWidth=1;for(const y of [-1,0,1]){ctx.beginPath();ctx.moveTo(60,py(y));ctx.lineTo(1060,py(y));ctx.stroke();ctx.fillStyle=fg;ctx.fillText(String(y),22,py(y)+5);}
 ctx.beginPath();DATA.t.forEach((t,i)=>i?ctx.lineTo(px(t),py(DATA.wave[i])):ctx.moveTo(px(t),py(DATA.wave[i])));ctx.stroke();
 cfg.t.forEach((t,i)=>{let x=px(t),a=py(cfg.x[i]),b=py(cfg.q[i]);ctx.strokeStyle=red;ctx.lineWidth=3;ctx.beginPath();ctx.moveTo(x,a);ctx.lineTo(x,b);ctx.stroke();ctx.strokeStyle=accent;ctx.lineWidth=2;ctx.beginPath();ctx.arc(x,a,5,0,2*Math.PI);ctx.stroke();ctx.fillStyle=gold;ctx.fillRect(x-3,b-3,6,6);});
 ctx.fillStyle=fg;[0,.25,.5,.75,1].forEach(t=>ctx.fillText(String(t),px(t)-7,315));ctx.fillText('时间 t=nT (s)',895,342);
 document.querySelector('#metrics').textContent=`${fs} 个样本 / 1秒观察窗；${2**bits} 个电平；台阶 Δ=${cfg.delta.toFixed(6)}；实测最大误差=${cfg.max_error.toFixed(6)}；误差上界 Δ/2=${(cfg.delta/2).toFixed(6)}。`;
}
for(const id of ['fs','bits'])document.querySelector('#'+id).addEventListener('change',drawLab);
document.querySelector('#quiz').addEventListener('submit',e=>{e.preventDefault();const f=new FormData(e.target);if(['q1','q2','q3'].some(k=>!f.has(k))){document.querySelector('#feedback').textContent='请先完成三道题。';return;}const answers=['b','a','b'],why=['采样使时间索引离散；尚未限制幅值只能取有限电平。','固定范围内电平更多、台阶更细；采样时刻保持不变。','每个序号处的幅度乘以0.5，时间位置没有改变。'];document.querySelector('#feedback').textContent=answers.map((a,i)=>`${i+1}. ${f.get('q'+(i+1))===a?'正确':'再想一想'}：${why[i]}`).join('\n');});
