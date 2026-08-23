"use strict";(()=>{var i=document.querySelector(".prism-mesh"),e=i?.getContext("webgl",{antialias:!1,alpha:!1});if(i&&e){let s=function(t,n){let o=e.createShader(t);return e.shaderSource(o,n),e.compileShader(o),o},u=function(t){a.style.color=`var(${t})`;let n=getComputedStyle(a).color.match(/[\d.]+/g);return n?[Number(n[0])/255,Number(n[1])/255,Number(n[2])/255]:[0,0,0]},m=function(t,n,o){return[t[0]*o+n[0]*(1-o),t[1]*o+n[1]*(1-o),t[2]*o+n[2]*(1-o)]},h=function(){let t=u("--color-bg"),n=u("--color-accent"),o=u("--color-accent-strong");e.uniform3fv(E,t),e.uniform3fv(F,m(n,t,.5)),e.uniform3fv(R,m(o,t,.4))},d=function(){let t=Math.min(window.devicePixelRatio||1,2);i.width=Math.max(1,Math.floor(window.innerWidth*t/2)),i.height=Math.max(1,Math.floor(window.innerHeight*t/2)),e.viewport(0,0,i.width,i.height),e.uniform2f(x,i.width,i.height)},l=function(t){e.uniform1f(y,t/1e3),e.drawArrays(e.TRIANGLES,0,3)},v=function(t){l(t),f=requestAnimationFrame(v)},c=function(){cancelAnimationFrame(f),h(),d(),g.matches?l(0):f=requestAnimationFrame(v)};L=s,S=u,z=m,M=h,T=d,_=l,C=v,U=c;let A=`
attribute vec2 p;
void main() { gl_Position = vec4(p, 0.0, 1.0); }`,w=`
precision mediump float;
uniform vec2 size;
uniform float t;
uniform vec3 ground;
uniform vec3 tint1;
uniform vec3 tint2;

float blob(vec2 uv, vec2 c, float r) {
  float d = length(uv - c);
  return smoothstep(r, 0.0, d);
}

void main() {
  vec2 uv = gl_FragCoord.xy / size;
  uv.x *= size.x / size.y;

  vec2 c1 = vec2(0.25 * size.x / size.y + 0.12 * sin(t * 0.21), 0.75 + 0.10 * cos(t * 0.17));
  vec2 c2 = vec2(0.80 * size.x / size.y + 0.15 * sin(t * 0.13 + 2.1), 0.35 + 0.12 * sin(t * 0.19));
  vec2 c3 = vec2(0.55 * size.x / size.y + 0.18 * cos(t * 0.11 + 4.2), 0.85 + 0.09 * sin(t * 0.23 + 1.3));

  vec3 color = ground;
  color = mix(color, tint1, 0.55 * blob(uv, c1, 0.85));
  color = mix(color, tint2, 0.45 * blob(uv, c2, 0.95));
  color = mix(color, tint1, 0.35 * blob(uv, c3, 0.75));

  gl_FragColor = vec4(color, 1.0);
}`,r=e.createProgram();e.attachShader(r,s(e.VERTEX_SHADER,A)),e.attachShader(r,s(e.FRAGMENT_SHADER,w)),e.linkProgram(r),e.useProgram(r);let p=e.createBuffer();e.bindBuffer(e.ARRAY_BUFFER,p),e.bufferData(e.ARRAY_BUFFER,new Float32Array([-1,-1,3,-1,-1,3]),e.STATIC_DRAW);let b=e.getAttribLocation(r,"p");e.enableVertexAttribArray(b),e.vertexAttribPointer(b,2,e.FLOAT,!1,0,0);let x=e.getUniformLocation(r,"size"),y=e.getUniformLocation(r,"t"),E=e.getUniformLocation(r,"ground"),F=e.getUniformLocation(r,"tint1"),R=e.getUniformLocation(r,"tint2"),a=document.createElement("div");a.style.display="none",document.body.appendChild(a);let g=window.matchMedia("(prefers-reduced-motion: reduce)"),f=0;window.addEventListener("resize",d),g.addEventListener("change",c),new MutationObserver(c).observe(document.documentElement,{attributes:!0,attributeFilter:["data-theme"]}),window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change",c),i.dataset.ready="",c()}var L,S,z,M,T,_,C,U;})();
