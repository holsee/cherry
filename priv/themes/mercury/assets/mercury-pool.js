"use strict";(()=>{var s=document.querySelector(".mercury-band"),r=s?.querySelector(".mercury-pool"),e=r?.getContext("webgl",{antialias:!1,alpha:!1});if(s&&r&&e){let d=document.createElement("div");d.style.display="none",document.body.appendChild(d);let m=t=>{d.style.color=`var(${t})`;let o=getComputedStyle(d).color.match(/[\d.]+/g);return o?[Number(o[0])/255,Number(o[1])/255,Number(o[2])/255]:[0,0,0]},w="attribute vec2 p; void main() { gl_Position = vec4(p, 0.0, 1.0); }",x=`
precision mediump float;
uniform vec2 size;
uniform float t;
uniform vec2 pointer;
uniform vec4 ripple; // x, y, start time, strength
uniform vec3 dark;
uniform vec3 light;
uniform vec3 tint;
uniform vec3 ground;

float blob(vec2 p, vec2 c, float r) {
  float d = length(p - c);
  return r * r / (d * d + 0.02);
}

float field(vec2 p) {
  vec2 A = vec2(size.x / size.y, 1.0);
  float h = 0.0;
  h += blob(p, A * vec2(0.12 + 0.08 * sin(t * 0.31), 0.5 + 0.2 * cos(t * 0.23)), 0.22);
  h += blob(p, A * vec2(0.36 + 0.1 * cos(t * 0.27 + 1.0), 0.45 + 0.22 * sin(t * 0.19)), 0.26);
  h += blob(p, A * vec2(0.6 + 0.08 * sin(t * 0.37 + 2.0), 0.6 + 0.18 * cos(t * 0.29)), 0.2);
  h += blob(p, A * vec2(0.8 + 0.1 * sin(t * 0.17 + 3.0), 0.7 + 0.15 * sin(t * 0.41)), 0.18);
  h += blob(p, A * vec2(0.95 + 0.06 * cos(t * 0.21 + 4.0), 0.35 + 0.2 * sin(t * 0.33)), 0.2);
  // the pointer's dent
  float pd = length(p - pointer * A);
  h -= 0.35 * exp(-pd * pd * 40.0);
  // a ripple ring expanding from the last click
  float age = t - ripple.z;
  if (age > 0.0 && age < 2.5) {
    float rd = length(p - ripple.xy * A);
    float ring = sin((rd - age * 0.35) * 40.0) * exp(-rd * 6.0) * exp(-age * 1.6);
    h += ring * ripple.w * 0.4;
  }
  return h;
}

void main() {
  vec2 uv = gl_FragCoord.xy / size;
  vec2 p = vec2(uv.x * size.x / size.y, uv.y);
  float e = 0.004;
  float h = field(p);
  float hx = field(p + vec2(e, 0.0)) - h;
  float hy = field(p + vec2(0.0, e)) - h;
  vec3 n = normalize(vec3(-hx, -hy, e * 2.2));
  // a chrome reflection: bands by the normal's vertical component
  float band = n.y * 0.5 + 0.5 + 0.15 * sin(n.x * 9.0);
  float stripes = smoothstep(0.35, 0.5, band) - smoothstep(0.5, 0.62, band) * 0.6 + 0.5 * smoothstep(0.78, 0.95, band);
  float fresnel = pow(1.0 - abs(n.z), 2.0);
  vec3 color = mix(dark, light, clamp(stripes + fresnel * 0.6, 0.0, 1.0));
  color = mix(color, tint, 0.18 * smoothstep(0.45, 0.7, band) * (1.0 - fresnel));
  // the pool fades into the page at the bottom of the band
  float fade = smoothstep(0.0, 0.28, uv.y);
  color = mix(ground, color, fade);
  gl_FragColor = vec4(color, 1.0);
}`,p=(t,o)=>{let n=e.createShader(t);return e.shaderSource(n,o),e.compileShader(n),n},c=e.createProgram();e.attachShader(c,p(e.VERTEX_SHADER,w)),e.attachShader(c,p(e.FRAGMENT_SHADER,x)),e.linkProgram(c),e.useProgram(c),e.bindBuffer(e.ARRAY_BUFFER,e.createBuffer()),e.bufferData(e.ARRAY_BUFFER,new Float32Array([-1,-1,3,-1,-1,3]),e.STATIC_DRAW);let h=e.getAttribLocation(c,"p");e.enableVertexAttribArray(h),e.vertexAttribPointer(h,2,e.FLOAT,!1,0,0);let i=t=>e.getUniformLocation(c,t),R=i("size"),E=i("t"),L=i("pointer"),F=i("ripple"),v=window.matchMedia("(prefers-reduced-motion: reduce)"),u=0,f=[-2,-2],a=[0,0,-10,0],S=()=>{e.uniform3fv(i("dark"),m("--color-fg")),e.uniform3fv(i("light"),m("--color-surface")),e.uniform3fv(i("tint"),m("--color-accent")),e.uniform3fv(i("ground"),m("--color-bg"))},b=()=>{let t=Math.min(window.devicePixelRatio||1,1.5),o=s.getBoundingClientRect();r.width=Math.max(1,Math.floor(o.width*t)),r.height=Math.max(1,Math.floor(o.height*t)),e.viewport(0,0,r.width,r.height),e.uniform2f(R,r.width,r.height)},g=t=>{e.uniform1f(E,t/1e3),e.uniform2f(L,f[0],f[1]),e.uniform4f(F,a[0],a[1],a[2],a[3]),e.drawArrays(e.TRIANGLES,0,3)},A=t=>{s.getBoundingClientRect().bottom>0&&g(t),u=requestAnimationFrame(A)},l=()=>{cancelAnimationFrame(u),S(),b(),v.matches||document.hidden?g(2):u=requestAnimationFrame(A)},y=t=>{let o=s.getBoundingClientRect();return[(t.clientX-o.left)/o.width,1-(t.clientY-o.top)/o.height]};window.addEventListener("pointermove",t=>{let[o,n]=y(t);f=n>=-.1&&n<=1.1?[o,n]:[-2,-2]}),window.addEventListener("pointerdown",t=>{let[o,n]=y(t);n<0||n>1||(a[0]=o,a[1]=n,a[2]=performance.now()/1e3,a[3]=1)}),window.addEventListener("resize",b),document.addEventListener("visibilitychange",l),v.addEventListener("change",l),new MutationObserver(l).observe(document.documentElement,{attributes:!0,attributeFilter:["data-theme"]}),window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change",l),r.dataset.ready="",l()}})();
