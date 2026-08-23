// Mercury's pool: a WebGL chrome surface in the band behind the mast.
// A height field of drifting blobs plus the pointer's dent plus click
// ripples; the normal of that field indexes a procedural reflection
// built from the theme's tokens (fg for the dark bands, surface for
// the highlights, accent tinting the mid-tones). Re-read on theme
// flips. Reduced motion: one frame. Off-screen: the loop idles.

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
  let pointer: [number, number] = [-2, -2];
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
    gl.uniform1f(uTime, ms / 1000);
    gl.uniform2f(uPointer, pointer[0], pointer[1]);
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
    pointer = y >= -0.1 && y <= 1.1 ? [x, y] : [-2, -2];
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
