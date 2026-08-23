"use strict";(()=>{var r=document.querySelector(".warp-field"),t=r?.getContext("webgl",{antialias:!1,alpha:!1});if(r&&t){let u=function(e,o){let n=t.createShader(e);return t.shaderSource(n,o),t.compileShader(n),n},s=function(e){c.style.color=`var(${e})`;let o=getComputedStyle(c).color.match(/[\d.]+/g);return o?[Number(o[0])/255,Number(o[1])/255,Number(o[2])/255]:[0,0,0]},g=function(e,o,n){return[e[0]*n+o[0]*(1-n),e[1]*n+o[1]*(1-n),e[2]*n+o[2]*(1-n)]},v=function(){let e=s("--color-bg"),o=s("--color-accent"),n=s("--color-accent-strong");t.uniform3fv(R,e),t.uniform3fv(F,g(o,e,.45)),t.uniform3fv(L,n)},l=function(){let e=Math.min(window.devicePixelRatio||1,2),o=r.getBoundingClientRect();r.width=Math.max(1,Math.floor(o.width*e)),r.height=Math.max(1,Math.floor(o.height*e)),t.viewport(0,0,r.width,r.height),t.uniform2f(A,r.width,r.height)},d=function(e){t.uniform1f(E,e/1e3),t.drawArrays(t.TRIANGLES,0,3)},f=function(e){r.getBoundingClientRect().bottom>0&&d(e),m=requestAnimationFrame(f)},i=function(){cancelAnimationFrame(m),v(),l(),b.matches||document.hidden?d(1.7):m=requestAnimationFrame(f)};S=u,x=s,M=g,C=v,T=l,_=d,U=f,z=i;let p=`
attribute vec2 p;
void main() { gl_Position = vec4(p, 0.0, 1.0); }`,w=`
precision mediump float;
uniform vec2 size;
uniform float t;
uniform vec3 ground;
uniform vec3 tint;
uniform vec3 hot;

float hash(float n) { return fract(sin(n * 127.1) * 43758.5453); }

void main() {
  vec2 uv = (gl_FragCoord.xy - vec2(size.x * 0.32, size.y * 0.62)) / size.y;
  float r = length(uv);
  float a = atan(uv.y, uv.x);
  float glow = 0.0;
  for (int i = 0; i < 3; i++) {
    float rays = 140.0 + float(i) * 60.0;
    float ray = floor(a * rays / 6.2831853) + float(i) * 977.0;
    float h = hash(ray);
    float h2 = hash(ray + 31.0);
    float speed = 0.35 + 0.65 * h2;
    float along = fract(r * (1.8 + h) - t * speed - h * 7.0);
    float seg = smoothstep(0.0, 0.08, along) * smoothstep(0.55, 0.2, along);
    float edge = 1.0 - smoothstep(0.0, 0.5 / rays, abs(fract(a * rays / 6.2831853) - 0.5) - 0.25);
    glow += seg * edge * (0.25 + 0.75 * h) * smoothstep(0.02, 0.35, r);
  }
  glow = clamp(glow, 0.0, 1.0);
  vec3 color = mix(ground, tint, glow * 0.7);
  color = mix(color, hot, pow(glow, 3.0) * 0.35);
  gl_FragColor = vec4(color, 1.0);
}`,a=t.createProgram();t.attachShader(a,u(t.VERTEX_SHADER,p)),t.attachShader(a,u(t.FRAGMENT_SHADER,w)),t.linkProgram(a),t.useProgram(a);let y=t.createBuffer();t.bindBuffer(t.ARRAY_BUFFER,y),t.bufferData(t.ARRAY_BUFFER,new Float32Array([-1,-1,3,-1,-1,3]),t.STATIC_DRAW);let h=t.getAttribLocation(a,"p");t.enableVertexAttribArray(h),t.vertexAttribPointer(h,2,t.FLOAT,!1,0,0);let A=t.getUniformLocation(a,"size"),E=t.getUniformLocation(a,"t"),R=t.getUniformLocation(a,"ground"),F=t.getUniformLocation(a,"tint"),L=t.getUniformLocation(a,"hot"),c=document.createElement("div");c.style.display="none",document.body.appendChild(c);let b=window.matchMedia("(prefers-reduced-motion: reduce)"),m=0;window.addEventListener("resize",l),document.addEventListener("visibilitychange",i),b.addEventListener("change",i),new MutationObserver(i).observe(document.documentElement,{attributes:!0,attributeFilter:["data-theme"]}),window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change",i),r.dataset.ready="",i()}var S,x,M,C,T,_,U,z;})();
