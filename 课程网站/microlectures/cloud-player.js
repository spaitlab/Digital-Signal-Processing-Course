(() => {
 const select=document.querySelector('#video-version'), frame=document.querySelector('#drive-player'), open=document.querySelector('#drive-open');
 if(!select||!frame||!open)return;
 select.addEventListener('change',()=>{ const id=select.value; frame.src='https://drive.google.com/file/d/'+id+'/preview'; open.href='https://drive.google.com/file/d/'+id+'/view'; });
})();
