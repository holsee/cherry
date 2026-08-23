// Warp's field: streaks of light rushing outward from a vanishing point
// left of centre, painted by a small hand-written WebGL fragment shader
// on the band canvas at the top of the page. No three.js, no requests.
//
// Colours come from the theme's tokens through the probe bridge (ground
// and accent family), re-read on [data-theme] flips and on system scheme
// changes. No WebGL leaves the CSS gradient band; reduced motion paints
// one frame and stops.

const canvas = document.querySelector<HTMLCanvasElement>(".warp-field");
const gl = canvas?.getContext("webgl", { antialias: false, alpha: false });

if (canvas && gl) {
  const VERT = `
attribute vec2 p;
void main() { gl_Position = vec4(p, 0.0, 1.0); }`;

  // Polar streaks: quantise the angle into rays, hash each ray for a
  // phase and a length, and sweep a bright segment outward along it.
  const FRAG = `
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
}`;

  function compile(type: number, source: string): WebGLShader {
    const shader = gl!.createShader(type)!;
    gl!.shaderSource(shader, source);
    gl!.compileShader(shader);
    return shader;
  }

  const program = gl.createProgram()!;
  gl.attachShader(program, compile(gl.VERTEX_SHADER, VERT));
  gl.attachShader(program, compile(gl.FRAGMENT_SHADER, FRAG));
  gl.linkProgram(program);
  gl.useProgram(program);

  const quad = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, quad);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
  const loc = gl.getAttribLocation(program, "p");
  gl.enableVertexAttribArray(loc);
  gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);

  const uSize = gl.getUniformLocation(program, "size");
  const uTime = gl.getUniformLocation(program, "t");
  const uGround = gl.getUniformLocation(program, "ground");
  const uTint = gl.getUniformLocation(program, "tint");
  const uHot = gl.getUniformLocation(program, "hot");

  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);

  type RGB = [number, number, number];

  function tokenRGB(name: string): RGB {
    probe.style.color = `var(${name})`;
    const rgb = getComputedStyle(probe).color.match(/[\d.]+/g);
    if (!rgb) return [0, 0, 0];
    return [Number(rgb[0]) / 255, Number(rgb[1]) / 255, Number(rgb[2]) / 255];
  }

  function mix(a: RGB, b: RGB, t: number): RGB {
    return [a[0] * t + b[0] * (1 - t), a[1] * t + b[1] * (1 - t), a[2] * t + b[2] * (1 - t)];
  }

  function loadTokens(): void {
    const ground = tokenRGB("--color-bg");
    const accent = tokenRGB("--color-accent");
    const strong = tokenRGB("--color-accent-strong");
    gl!.uniform3fv(uGround, ground);
    gl!.uniform3fv(uTint, mix(accent, ground, 0.45));
    gl!.uniform3fv(uHot, strong);
  }

  function resize(): void {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const rect = canvas!.getBoundingClientRect();
    canvas!.width = Math.max(1, Math.floor(rect.width * dpr));
    canvas!.height = Math.max(1, Math.floor(rect.height * dpr));
    gl!.viewport(0, 0, canvas!.width, canvas!.height);
    gl!.uniform2f(uSize, canvas!.width, canvas!.height);
  }

  function frame(ms: number): void {
    gl!.uniform1f(uTime, ms / 1000);
    gl!.drawArrays(gl!.TRIANGLES, 0, 3);
  }

  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  let raf = 0;

  function loop(ms: number): void {
    // The band scrolls away: stop drawing once it is off screen.
    if (canvas!.getBoundingClientRect().bottom > 0) frame(ms);
    raf = requestAnimationFrame(loop);
  }

  function start(): void {
    cancelAnimationFrame(raf);
    loadTokens();
    resize();
    if (still.matches || document.hidden) {
      frame(1.7);
    } else {
      raf = requestAnimationFrame(loop);
    }
  }

  window.addEventListener("resize", resize);
  document.addEventListener("visibilitychange", start);
  still.addEventListener("change", start);
  new MutationObserver(start).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"],
  });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);

  canvas.dataset.ready = "";
  start();
}

export {};
