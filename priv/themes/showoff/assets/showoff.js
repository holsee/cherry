"use strict";(()=>{var f=window.matchMedia("(prefers-reduced-motion: reduce)"),x=window.matchMedia("(pointer: fine)");document.documentElement.classList.add("so-js");var p=document.createElement("div");p.style.display="none";document.body.appendChild(p);function h(t){p.style.color=`var(${t})`;let n=getComputedStyle(p).color.match(/[\d.]+/g);return n?[Number(n[0])/255,Number(n[1])/255,Number(n[2])/255]:[0,0,0]}function M(t,n,o){return[t[0]*o+n[0]*(1-o),t[1]*o+n[1]*(1-o),t[2]*o+n[2]*(1-o)]}var s=document.querySelector(".so-aurora"),e=s?.getContext("webgl",{antialias:!1,alpha:!1});if(s&&e){let t="attribute vec2 p; void main() { gl_Position = vec4(p, 0.0, 1.0); }",n=`
precision mediump float;
uniform vec2 size;
uniform float t;
uniform vec3 ground;
uniform vec3 c1;
uniform vec3 c2;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float fbm(vec2 p) {
  float v = 0.0;
  v += 0.5 * noise(p); p *= 2.1;
  v += 0.25 * noise(p); p *= 2.1;
  v += 0.125 * noise(p);
  return v;
}

void main() {
  vec2 uv = gl_FragCoord.xy / size;
  float a = uv.x * size.x / size.y;
  float n1 = fbm(vec2(a * 1.4 + t * 0.05, uv.y * 0.9 - t * 0.03));
  float n2 = fbm(vec2(a * 0.9 - t * 0.04 + 5.0, uv.y * 1.6 + t * 0.02));
  float curtain = smoothstep(0.3, 0.7, n1) * (0.4 + 0.6 * uv.y);
  float veil = smoothstep(0.4, 0.8, n2) * (1.0 - uv.y * 0.5);
  vec3 color = ground;
  color = mix(color, c1, curtain * 0.9);
  color = mix(color, c2, veil * 0.75);
  gl_FragColor = vec4(color, 1.0);
}`,o=(a,F)=>{let y=e.createShader(a);return e.shaderSource(y,F),e.compileShader(y),y},r=e.createProgram();e.attachShader(r,o(e.VERTEX_SHADER,t)),e.attachShader(r,o(e.FRAGMENT_SHADER,n)),e.linkProgram(r),e.useProgram(r),e.bindBuffer(e.ARRAY_BUFFER,e.createBuffer()),e.bufferData(e.ARRAY_BUFFER,new Float32Array([-1,-1,3,-1,-1,3]),e.STATIC_DRAW);let c=e.getAttribLocation(r,"p");e.enableVertexAttribArray(c),e.vertexAttribPointer(c,2,e.FLOAT,!1,0,0);let l=e.getUniformLocation(r,"size"),m=e.getUniformLocation(r,"t"),i=e.getUniformLocation(r,"ground"),g=e.getUniformLocation(r,"c1"),b=e.getUniformLocation(r,"c2"),w=0,R=()=>{let a=h("--color-bg");e.uniform3fv(i,a),e.uniform3fv(g,M(h("--color-accent"),a,.85)),e.uniform3fv(b,M(h("--color-accent-strong"),a,.8))},A=()=>{let a=Math.min(window.devicePixelRatio||1,2);s.width=Math.max(1,Math.floor(window.innerWidth*a/2)),s.height=Math.max(1,Math.floor(window.innerHeight*a/2)),e.viewport(0,0,s.width,s.height),e.uniform2f(l,s.width,s.height)},E=a=>{e.uniform1f(m,a/1e3),e.drawArrays(e.TRIANGLES,0,3)},L=a=>{E(a),w=requestAnimationFrame(L)},u=()=>{cancelAnimationFrame(w),R(),A(),f.matches||document.hidden?E(3):w=requestAnimationFrame(L)};window.addEventListener("resize",A),document.addEventListener("visibilitychange",u),f.addEventListener("change",u),new MutationObserver(u).observe(document.documentElement,{attributes:!0,attributeFilter:["data-theme"]}),window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change",u),s.dataset.ready="",u()}var v=document.querySelector(".so-comet"),d=v?.getContext("2d",{alpha:!0});if(v&&d&&x.matches&&!f.matches){let t=[],n="255, 255, 255",o=0,r=0,c=()=>{let i=Math.min(window.devicePixelRatio||1,2);o=window.innerWidth,r=window.innerHeight,v.width=Math.floor(o*i),v.height=Math.floor(r*i),d.setTransform(i,0,0,i,0,0)},l=()=>{let[i,g,b]=h("--color-accent");n=`${Math.round(i*255)}, ${Math.round(g*255)}, ${Math.round(b*255)}`};window.addEventListener("pointermove",i=>{t.push({x:i.clientX,y:i.clientY,life:1}),t.length>40&&t.shift()});let m=()=>{d.clearRect(0,0,o,r);for(let i of t)i.life-=.035,!(i.life<=0)&&(d.fillStyle=`rgba(${n}, ${(i.life*.6).toFixed(3)})`,d.beginPath(),d.arc(i.x,i.y,2+10*i.life,0,Math.PI*2),d.fill());for(;t.length&&t[0].life<=0;)t.shift();requestAnimationFrame(m)};window.addEventListener("resize",c),new MutationObserver(l).observe(document.documentElement,{attributes:!0,attributeFilter:["data-theme"]}),c(),l(),requestAnimationFrame(m)}if(x.matches&&!f.matches){let t=Array.from(document.querySelectorAll(".site-nav a"));window.addEventListener("pointermove",n=>{for(let o of t){let r=o.getBoundingClientRect(),c=n.clientX-(r.left+r.width/2),l=n.clientY-(r.top+r.height/2),m=Math.hypot(c,l);o.style.transform=m<80?`translate(${c/80*6}px, ${l/80*6}px)`:""}})}if(x.matches&&!f.matches)for(let t of Array.from(document.querySelectorAll(".so-card")))t.addEventListener("pointermove",n=>{let o=t.getBoundingClientRect(),r=(n.clientX-o.left)/o.width,c=(n.clientY-o.top)/o.height;t.style.transform=`rotateX(${(.5-c)*8}deg) rotateY(${(r-.5)*8}deg)`,t.style.setProperty("--so-x",`${r*100}%`),t.style.setProperty("--so-y",`${c*100}%`)}),t.addEventListener("pointerleave",()=>{t.style.transform=""});var S=Array.from(document.querySelectorAll("main .so-panel > *, main .so-card, main .profile > *, main .cv > *"));if("IntersectionObserver"in window&&!f.matches){let t=new IntersectionObserver(n=>{for(let o of n)o.isIntersecting&&(o.target.classList.add("is-seen"),t.unobserve(o.target))},{rootMargin:"0px 0px -8% 0px",threshold:.05});for(let n of S)n.classList.add("so-reveal"),t.observe(n)}})();
