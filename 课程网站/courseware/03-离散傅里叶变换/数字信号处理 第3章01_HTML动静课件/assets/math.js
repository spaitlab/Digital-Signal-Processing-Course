/* Analytic models; also exported for independent numerical verification. */
window.Fourier = {
 pulse(t){return Math.abs(Math.abs(t)-1.5)<1e-10?.5:Math.abs(t)<1.5?1:0;},
 periodicPulse(t,T){return this.pulse(t-T*Math.round(t/T));},
 P(w){return Math.abs(w)<1e-10?3:2*Math.sin(1.5*w)/w;},
 coefficient(m,T){return this.P(2*Math.PI*m/T)/T;},
 X(w){return 1+2*Math.cos(w);},
 sequence(n,N=0){return N?([0,1,N-1].includes(((n%N)+N)%N)?1:0):(Math.abs(n)<=1?1:0);},
 dfs(k,N){return this.X(2*Math.PI*k/N);},
 integral(q,u){return q===0?{re:u,im:0}:{re:Math.sin(2*Math.PI*q*u)/(2*Math.PI*q),im:(1-Math.cos(2*Math.PI*q*u))/(2*Math.PI*q)};}
};
