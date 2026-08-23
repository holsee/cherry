// Mercury's pool: a WebGL liquid-metal surface in the band behind the
// mast. A domain-warped height field of slow blobs plus the pointer's
// eased dent (a wake, not a spotlight) plus click ripples; the normal
// of that field drives a soft studio ramp built from the theme's
// tokens (fg for the depths, surface for the sheen, accent in the
// fresnel rim). The range is deliberately compressed - mercury reads
// in the mid-tones, and the type above it needs the headroom.
// Re-read on theme flips. Reduced motion: one frame. Off-screen: idle.

const band = document.querySelector<HTMLElement>(".mercury-band");
const canvas = band?.querySelector<HTMLCanvasElement>(".mercury-pool");
const gl = canvas?.getContext("webgl", { antialias: false, alpha: false });

if (band && canvas && gl) {
  type RGB = [number, number, number];
  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);
  const tokenRGB = (name: string): RGB => {
    probe.style.color = `var(${name})`;
    const m = getComputedStyle(probe).color.match(/[\d.]+/g);
    return m ? [Number(m[0]) / 255, Number(m[1]) / 255, Number(m[2]) / 255] : [0, 0, 0];
  };

  const VERT = `attribute vec2 p; void main() { gl_Position = vec4(p, 0.0, 1.0); }`;
  const FRAG = `
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
  const u = (name: string): WebGLUniformLocation | null => gl.getUniformLocation(program, name);
  const uSize = u("size");
  const uTime = u("t");
  const uPointer = u("pointer");
  const uRipple = u("ripple");

  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  let raf = 0;
  // target follows the pointer; drawn follows target with viscous lag
  let target: [number, number] = [-2, -2];
  let drawn: [number, number] = [-2, -2];
  const ripple: [number, number, number, number] = [0, 0, -10, 0];

  const loadTokens = (): void => {
    gl.uniform3fv(u("dark"), tokenRGB("--color-fg"));
    gl.uniform3fv(u("light"), tokenRGB("--color-surface"));
    gl.uniform3fv(u("tint"), tokenRGB("--color-accent"));
    gl.uniform3fv(u("ground"), tokenRGB("--color-bg"));
  };
  const resize = (): void => {
    const dpr = Math.min(window.devicePixelRatio || 1, 1.5);
    const r = band.getBoundingClientRect();
    canvas.width = Math.max(1, Math.floor(r.width * dpr));
    canvas.height = Math.max(1, Math.floor(r.height * dpr));
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.uniform2f(uSize, canvas.width, canvas.height);
  };
  const frame = (ms: number): void => {
    // ease the drawn dent toward the pointer: the lag is the wake
    drawn = [drawn[0] + (target[0] - drawn[0]) * 0.07, drawn[1] + (target[1] - drawn[1]) * 0.07];
    gl.uniform1f(uTime, ms / 1000);
    gl.uniform2f(uPointer, drawn[0], drawn[1]);
    gl.uniform4f(uRipple, ripple[0], ripple[1], ripple[2], ripple[3]);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  };
  const loop = (ms: number): void => {
    if (band.getBoundingClientRect().bottom > 0) frame(ms);
    raf = requestAnimationFrame(loop);
  };
  const start = (): void => {
    cancelAnimationFrame(raf);
    loadTokens();
    resize();
    if (still.matches || document.hidden) frame(2.0);
    else raf = requestAnimationFrame(loop);
  };

  const toBand = (e: PointerEvent): [number, number] => {
    const r = band.getBoundingClientRect();
    return [(e.clientX - r.left) / r.width, 1 - (e.clientY - r.top) / r.height];
  };
  window.addEventListener("pointermove", (e) => {
    const [x, y] = toBand(e);
    target = y >= -0.1 && y <= 1.1 ? [x, y] : [-2, -2];
  });
  window.addEventListener("pointerdown", (e) => {
    const [x, y] = toBand(e);
    if (y < 0 || y > 1) return;
    ripple[0] = x;
    ripple[1] = y;
    ripple[2] = performance.now() / 1000;
    ripple[3] = 1;
  });
  window.addEventListener("resize", resize);
  document.addEventListener("visibilitychange", start);
  still.addEventListener("change", start);
  new MutationObserver(start).observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);
  canvas.dataset.ready = "";
  start();
}

export {};
