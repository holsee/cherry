"use strict";(()=>{var d=document.querySelector(".mercury-band"),r=d?.querySelector(".mercury-pool"),e=r?.getContext("webgl",{antialias:!1,alpha:!1});if(d&&r&&e){let m=document.createElement("div");m.style.display="none",document.body.appendChild(m);let u=t=>{m.style.color=`var(${t})`;let o=getComputedStyle(m).color.match(/[\d.]+/g);return o?[Number(o[0])/255,Number(o[1])/255,Number(o[2])/255]:[0,0,0]},x="attribute vec2 p; void main() { gl_Position = vec4(p, 0.0, 1.0); }",R=`
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
  return r * r / (d * d + 0.06);
}

float field(vec2 p) {
  vec2 A = vec2(size.x / size.y, 1.0);
  // a gentle domain warp: the surface swirls instead of translating
  p += 0.07 * vec2(sin(p.y * 2.6 + t * 0.13), cos(p.x * 2.1 + t * 0.10));
  float h = 0.0;
  h += blob(p, A * vec2(0.14 + 0.06 * sin(t * 0.11), 0.55 + 0.12 * cos(t * 0.09)), 0.32);
  h += blob(p, A * vec2(0.40 + 0.08 * cos(t * 0.10 + 1.0), 0.42 + 0.14 * sin(t * 0.08)), 0.36);
  h += blob(p, A * vec2(0.66 + 0.06 * sin(t * 0.13 + 2.0), 0.62 + 0.11 * cos(t * 0.12)), 0.32);
  h += blob(p, A * vec2(0.90 + 0.05 * cos(t * 0.09 + 4.0), 0.40 + 0.13 * sin(t * 0.10)), 0.30);
  // the pointer's dent - its position is eased CPU-side into a wake
  float pd = length(p - pointer * A);
  h -= 0.30 * exp(-pd * pd * 26.0);
  // a ripple ring expanding from the last click, slow and wide
  float age = t - ripple.z;
  if (age > 0.0 && age < 3.5) {
    float rd = length(p - ripple.xy * A);
    float ring = sin((rd - age * 0.30) * 30.0) * exp(-rd * 4.0) * exp(-age * 1.1);
    h += ring * ripple.w * 0.45;
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
  // a flatter z keeps the normals soft: viscous, not spiky
  vec3 n = normalize(vec3(-hx, -hy, e * 3.4));
  // studio lighting: a wide sky ramp, one soft key light, a tinted rim
  float sky = smoothstep(-0.6, 0.75, n.y);
  vec3 color = mix(dark, light, 0.2 + 0.58 * sky);
  vec3 L = normalize(vec3(-0.25, 0.5, 0.83));
  float spec = pow(max(dot(n, L), 0.0), 24.0);
  color += light * spec * 0.3;
  float fresnel = pow(1.0 - abs(n.z), 3.0);
  color = mix(color, tint, 0.16 * fresnel + 0.07 * (1.0 - sky));
  // the pool fades into the page well before the lede, and the whole
  // surface sits a step toward the ground so the type keeps headroom
  float fade = smoothstep(0.05, 0.55, uv.y) * 0.88;
  color = mix(ground, color, fade);
  gl_FragColor = vec4(color, 1.0);
}`,h=(t,o)=>{let n=e.createShader(t);return e.shaderSource(n,o),e.compileShader(n),n},s=e.createProgram();e.attachShader(s,h(e.VERTEX_SHADER,x)),e.attachShader(s,h(e.FRAGMENT_SHADER,R)),e.linkProgram(s),e.useProgram(s),e.bindBuffer(e.ARRAY_BUFFER,e.createBuffer()),e.bufferData(e.ARRAY_BUFFER,new Float32Array([-1,-1,3,-1,-1,3]),e.STATIC_DRAW);let v=e.getAttribLocation(s,"p");e.enableVertexAttribArray(v),e.vertexAttribPointer(v,2,e.FLOAT,!1,0,0);let i=t=>e.getUniformLocation(s,t),E=i("size"),k=i("t"),L=i("pointer"),z=i("ripple"),g=window.matchMedia("(prefers-reduced-motion: reduce)"),f=0,p=[-2,-2],c=[-2,-2],a=[0,0,-10,0],F=()=>{e.uniform3fv(i("dark"),u("--color-fg")),e.uniform3fv(i("light"),u("--color-surface")),e.uniform3fv(i("tint"),u("--color-accent")),e.uniform3fv(i("ground"),u("--color-bg"))},b=()=>{let t=Math.min(window.devicePixelRatio||1,1.5),o=d.getBoundingClientRect();r.width=Math.max(1,Math.floor(o.width*t)),r.height=Math.max(1,Math.floor(o.height*t)),e.viewport(0,0,r.width,r.height),e.uniform2f(E,r.width,r.height)},w=t=>{c=[c[0]+(p[0]-c[0])*.07,c[1]+(p[1]-c[1])*.07],e.uniform1f(k,t/1e3),e.uniform2f(L,c[0],c[1]),e.uniform4f(z,a[0],a[1],a[2],a[3]),e.drawArrays(e.TRIANGLES,0,3)},y=t=>{d.getBoundingClientRect().bottom>0&&w(t),f=requestAnimationFrame(y)},l=()=>{cancelAnimationFrame(f),F(),b(),g.matches||document.hidden?w(2):f=requestAnimationFrame(y)},A=t=>{let o=d.getBoundingClientRect();return[(t.clientX-o.left)/o.width,1-(t.clientY-o.top)/o.height]};window.addEventListener("pointermove",t=>{let[o,n]=A(t);p=n>=-.1&&n<=1.1?[o,n]:[-2,-2]}),window.addEventListener("pointerdown",t=>{let[o,n]=A(t);n<0||n>1||(a[0]=o,a[1]=n,a[2]=performance.now()/1e3,a[3]=1)}),window.addEventListener("resize",b),document.addEventListener("visibilitychange",l),g.addEventListener("change",l),new MutationObserver(l).observe(document.documentElement,{attributes:!0,attributeFilter:["data-theme"]}),window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change",l),r.dataset.ready="",l()}})();
