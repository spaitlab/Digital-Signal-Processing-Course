/* Add a completed lesson to its chapter's lessons array. Paths are relative to 4-课件/index.html. */
window.COURSE_CHAPTERS = [
 {number:1,title:'数字信号处理概述',summary:'从信号、采样与量化出发，认识数字信号处理的基本过程。',topics:['信号与系统','采样与量化','参数实验'],lessons:[
  {code:'01',title:'信号与系统',description:'采样、量化、信号分类与系统，附自由参数实验。',screens:5,href:'01-数字信号处理概述/HTML动静课件样板/index.html'}
 ]},
 {number:2,title:'离散时间信号和系统分析',summary:'连接连续时间与离散时间，理解采样、混叠及信号恢复。',topics:['采样定理','频谱延拓','恢复与内插'],lessons:[
  {code:'01',title:'采样与恢复',description:'采样模型、频谱副本、采样定理与 sinc 内插，附课堂实验。',screens:12,href:'02-离散时间信号与系统分析/数字信号处理 第2章01_HTML动静课件_双Logo版/index.html'}
 ]},
 {number:3,title:'离散傅里叶变换',summary:'从四种傅里叶表示出发，建立有限长序列的频域表示。',topics:['四种傅里叶表示','DFS / DFT','频谱分析'],lessons:[
  {code:'01',title:'四种傅里叶变换',description:'CTFT、FS、DTFT 与 DFS，含正交投影、谱线间隔、课堂判断和自由实验。',screens:10,href:'03-离散傅里叶变换/数字信号处理 第3章01_HTML动静课件/index.html'}
 ]},
 {number:4,title:'快速傅里叶变换',summary:'从计算量出发，理解 FFT 如何分解并加速离散傅里叶变换。',topics:['按时间抽取','按频率抽取','FFT 应用'],lessons:[]},
 {number:5,title:'数字滤波器的结构',summary:'把系统关系转化为可实现的结构，比较不同实现形式。',topics:['IIR 结构','FIR 结构','级联与并联'],lessons:[]},
 {number:6,title:'IIR 数字滤波器设计',summary:'从模拟原型走向数字滤波器，梳理指标、变换与设计流程。',topics:['巴特沃思','切比雪夫','双线性变换'],lessons:[]},
 {number:7,title:'FIR 数字滤波器设计',summary:'围绕线性相位、窗函数与频率采样，理解 FIR 的设计方法。',topics:['线性相位','窗函数法','频率采样法'],lessons:[]}
];
