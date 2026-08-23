// Showoff's island: five parts, each guarded, all token-driven.
//   1. aurora  - WebGL value-noise curtains on a fixed canvas
//   2. comet   - a canvas2d trail behind the pointer
//   3. magnet  - nav links leaning toward the pointer
//   4. tilt    - index cards rotating in 3D under the pointer
//   5. reveal  - blocks rising into view
// Reduced motion: one aurora frame, and parts 2-5 stay off.

const still = window.matchMedia("(prefers-reduced-motion: reduce)");
const fine = window.matchMedia("(pointer: fine)");
document.documentElement.classList.add("so-js");

const probe = document.createElement("div");
probe.style.display = "none";
document.body.appendChild(probe);

type RGB = [number, number, number];

function tokenRGB(name: string): RGB {
  probe.style.color = `var(${name})`;
  const m = getComputedStyle(probe).color.match(/[\d.]+/g);
  return m ? [Number(m[0]) / 255, Number(m[1]) / 255, Number(m[2]) / 255] : [0, 0, 0];
}

function mix(a: RGB, b: RGB, t: number): RGB {
  return [a[0] * t + b[0] * (1 - t), a[1] * t + b[1] * (1 - t), a[2] * t + b[2] * (1 - t)];
}

// ---- 1. aurora ----
const aurora = document.querySelector<HTMLCanvasElement>(".so-aurora");
const gl = aurora?.getContext("webgl", { antialias: false, alpha: false });

if (aurora && gl) {
  const VERT = `attribute vec2 p; void main() { gl_Position = vec4(p, 0.0, 1.0); }`;
  const FRAG = `
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
}`;

  const compile = (type: number, src: string): WebGLShader => {
    const s = gl.createShader(type)!;
    gl.shaderSource(s, src);
    gl.compileShader(s);
    return s;
  };
  const program = gl.createProgram()!;
  gl.attachShader(program, compile(gl.VERTEX_SHADER, VERT));
  gl.attachShader(program, compile(gl.FRAGMENT_SHADER, FRAG));
  gl.linkProgram(program);
  gl.useProgram(program);
  gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
  const loc = gl.getAttribLocation(program, "p");
  gl.enableVertexAttribArray(loc);
  gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
  const uSize = gl.getUniformLocation(program, "size");
  const uTime = gl.getUniformLocation(program, "t");
  const uGround = gl.getUniformLocation(program, "ground");
  const uC1 = gl.getUniformLocation(program, "c1");
  const uC2 = gl.getUniformLocation(program, "c2");
  let raf = 0;

  const loadTokens = (): void => {
    const ground = tokenRGB("--color-bg");
    gl.uniform3fv(uGround, ground);
    gl.uniform3fv(uC1, mix(tokenRGB("--color-accent"), ground, 0.85));
    gl.uniform3fv(uC2, mix(tokenRGB("--color-accent-strong"), ground, 0.8));
  };
  const resize = (): void => {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    aurora.width = Math.max(1, Math.floor((window.innerWidth * dpr) / 2));
    aurora.height = Math.max(1, Math.floor((window.innerHeight * dpr) / 2));
    gl.viewport(0, 0, aurora.width, aurora.height);
    gl.uniform2f(uSize, aurora.width, aurora.height);
  };
  const frame = (ms: number): void => {
    gl.uniform1f(uTime, ms / 1000);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  };
  const loop = (ms: number): void => {
    frame(ms);
    raf = requestAnimationFrame(loop);
  };
  const start = (): void => {
    cancelAnimationFrame(raf);
    loadTokens();
    resize();
    if (still.matches || document.hidden) frame(3);
    else raf = requestAnimationFrame(loop);
  };
  window.addEventListener("resize", resize);
  document.addEventListener("visibilitychange", start);
  still.addEventListener("change", start);
  new MutationObserver(start).observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);
  aurora.dataset.ready = "";
  start();
}

// ---- 2. comet ----
const comet = document.querySelector<HTMLCanvasElement>(".so-comet");
const c2d = comet?.getContext("2d", { alpha: true });

if (comet && c2d && fine.matches && !still.matches) {
  type Dot = { x: number; y: number; life: number };
  const dots: Dot[] = [];
  let tint = "255, 255, 255";
  let w = 0;
  let h = 0;
  const resize = (): void => {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    w = window.innerWidth;
    h = window.innerHeight;
    comet.width = Math.floor(w * dpr);
    comet.height = Math.floor(h * dpr);
    c2d.setTransform(dpr, 0, 0, dpr, 0, 0);
  };
  const loadTint = (): void => {
    const [r, g, b] = tokenRGB("--color-accent");
    tint = `${Math.round(r * 255)}, ${Math.round(g * 255)}, ${Math.round(b * 255)}`;
  };
  window.addEventListener("pointermove", (e) => {
    dots.push({ x: e.clientX, y: e.clientY, life: 1 });
    if (dots.length > 40) dots.shift();
  });
  const tick = (): void => {
    c2d.clearRect(0, 0, w, h);
    for (const d of dots) {
      d.life -= 0.035;
      if (d.life <= 0) continue;
      c2d.fillStyle = `rgba(${tint}, ${(d.life * 0.6).toFixed(3)})`;
      c2d.beginPath();
      c2d.arc(d.x, d.y, 2 + 10 * d.life, 0, Math.PI * 2);
      c2d.fill();
    }
    while (dots.length && dots[0]!.life <= 0) dots.shift();
    requestAnimationFrame(tick);
  };
  window.addEventListener("resize", resize);
  new MutationObserver(loadTint).observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
  resize();
  loadTint();
  requestAnimationFrame(tick);
}

// ---- 3. magnet ----
if (fine.matches && !still.matches) {
  const links = Array.from(document.querySelectorAll<HTMLElement>(".site-nav a"));
  window.addEventListener("pointermove", (e) => {
    for (const a of links) {
      const r = a.getBoundingClientRect();
      const dx = e.clientX - (r.left + r.width / 2);
      const dy = e.clientY - (r.top + r.height / 2);
      const d = Math.hypot(dx, dy);
      a.style.transform = d < 80 ? `translate(${(dx / 80) * 6}px, ${(dy / 80) * 6}px)` : "";
    }
  });
}

// ---- 4. tilt ----
if (fine.matches && !still.matches) {
  for (const card of Array.from(document.querySelectorAll<HTMLElement>(".so-card"))) {
    card.addEventListener("pointermove", (e) => {
      const r = card.getBoundingClientRect();
      const px = (e.clientX - r.left) / r.width;
      const py = (e.clientY - r.top) / r.height;
      card.style.transform = `rotateX(${(0.5 - py) * 8}deg) rotateY(${(px - 0.5) * 8}deg)`;
      card.style.setProperty("--so-x", `${px * 100}%`);
      card.style.setProperty("--so-y", `${py * 100}%`);
    });
    card.addEventListener("pointerleave", () => {
      card.style.transform = "";
    });
  }
}

// ---- 5. reveal ----
const blocks = Array.from(document.querySelectorAll<HTMLElement>("main .so-panel > *, main .so-card, main .profile > *, main .cv > *"));
if ("IntersectionObserver" in window && !still.matches) {
  const seen = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        entry.target.classList.add("is-seen");
        seen.unobserve(entry.target);
      }
    },
    { rootMargin: "0px 0px -8% 0px", threshold: 0.05 }
  );
  for (const el of blocks) {
    el.classList.add("so-reveal");
    seen.observe(el);
  }
}

export {};
