function drawLab(){
 const cv=document.querySelector('#lab');if(!cv)return;const ctx=cv.getContext('2d'),M=Number(document.querySelector('#window').value),stage=document.querySelector('#stage').value,cfg=DATA.configs.find(c=>c.M===M);window.currentConfig=cfg;
 const s=getComputedStyle(document.body),fg=s.getPropertyValue('--fg'),mut=s.getPropertyValue('--mut'),accent=s.getPropertyValue('--accent'),light=document.documentElement.dataset.theme==='light',gold=light?'#985000':'#ffc66f';ctx.clearRect(0,0,1100,350);ctx.font='18px Microsoft YaHei';
 const range=stage==='digital'?[.2,1]:[.25,.55],px=t=>60+(t-range[0])/(range[1]-range[0])*1000,py=y=>165-y*62.5;
 ctx.strokeStyle=mut;ctx.lineWidth=1;for(const y of [-2,0,2]){ctx.beginPath();ctx.moveTo(60,py(y));ctx.lineTo(1060,py(y));ctx.stroke();ctx.fillStyle=fg;ctx.fillText(String(y),22,py(y)+5);}
 function line(ts,ys,color){ctx.strokeStyle=color;ctx.lineWidth=2;ctx.beginPath();let first=true;ts.forEach((t,i)=>{if(t<range[0]||t>range[1])return;if(first){ctx.moveTo(px(t),py(ys[i]));first=false;}else ctx.lineTo(px(t),py(ys[i]));});ctx.stroke();}
 if(stage==='digital'){line(DATA.t,DATA.q,mut);line(DATA.t,cfg.y,gold);}else{line(DATA.tc,DATA.slow_cont,mut);line(DATA.tc,cfg.zoh,gold);line(DATA.tc,cfg.smooth,accent);}
 ctx.fillStyle=fg;[range[0],(range[0]+range[1])/2,range[1]].forEach(t=>ctx.fillText(t.toFixed(2),px(t)-10,315));ctx.fillText('时间 t(s)',940,342);
 document.querySelector('#metrics').textContent=`${M}点平均；窗口中心延迟 ${cfg.delay_ms} ms；2Hz拟合幅度 ${cfg.amplitudes[0].toFixed(3)}（输入1）；15Hz拟合幅度 ${cfg.amplitudes[1].toFixed(3)}（输入0.5）。`;
 document.querySelector('#legend').textContent=stage==='digital'?'灰：量化输入；金：数字平均输出。拟合使用n≥20的区间，避开启动过渡。':'灰：原2Hz分量；金：每样本保持10ms；绿：20ms因果平滑。图形均为本次实际计算结果。';
}
for(const id of ['window','stage'])document.querySelector('#'+id).addEventListener('change',drawLab);
document.querySelector('#quiz').addEventListener('submit',e=>{e.preventDefault();const f=new FormData(e.target);if(['q1','q2','q3'].some(k=>!f.has(k))){document.querySelector('#feedback').textContent='请先完成三道题。';return;}const answers=['b','a','b'],why=['使用当前及过去四个样本；本例开始之前的历史样本补0。','窗口中心相差2个样本，每个样本10ms，共20ms。这是信号延迟。','只需数字结果时可直接保存；需要模拟输出时才经过D/A和平滑。'];document.querySelector('#feedback').textContent=answers.map((a,i)=>`${i+1}. ${f.get('q'+(i+1))===a?'正确':'再想一想'}：${why[i]}`).join('\n');});
