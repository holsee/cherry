// Prism's gradient mesh: a fixed full-viewport canvas painted by a small
// hand-written WebGL fragment shader — no three.js, no requests.
//
// The colours are not baked in: the shader's uniforms are read from the
// theme's own CSS custom properties (the token → uniform bridge), so a
// site's `tokens:` override restyles the mesh exactly like it restyles
// a link. The uniforms are re-read when the theme toggle flips
// [data-theme] and when the system scheme changes.
//
// Honest degradation: no WebGL (or reduced motion) leaves the body's
// CSS poster gradient doing the job; reduced motion still gets one
// painted frame if WebGL exists, then the loop stops.

const canvas = document.querySelector<HTMLCanvasElement>(".prism-mesh");
const gl = canvas?.getContext("webgl", { antialias: false, alpha: false });

if (canvas && gl) {
  const VERT = `
attribute vec2 p;
void main() { gl_Position = vec4(p, 0.0, 1.0); }`;

  // Three blobs of the accent family drifting over the ground colour;
  // cheap value noise would cost more instructions than these moving
  // radial fields and look no better at blur scale.
  const FRAG = `
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
  const uTint1 = gl.getUniformLocation(program, "tint1");
  const uTint2 = gl.getUniformLocation(program, "tint2");

  // The token → uniform bridge: resolve a custom property to rgb 0..1.
  // Painting the value onto a probe element lets the browser do every
  // conversion (hex, light-dark(), color-mix()) for us.
  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);

  function tokenRGB(name: string): [number, number, number] {
    probe.style.color = `var(${name})`;
    const rgb = getComputedStyle(probe).color.match(/[\d.]+/g);
    if (!rgb) return [0, 0, 0];
    return [Number(rgb[0]) / 255, Number(rgb[1]) / 255, Number(rgb[2]) / 255];
  }

  function mix(a: [number, number, number], b: [number, number, number], t: number): number[] {
    return [a[0] * t + b[0] * (1 - t), a[1] * t + b[1] * (1 - t), a[2] * t + b[2] * (1 - t)];
  }

  function loadTokens(): void {
    const ground = tokenRGB("--color-bg");
    const accent = tokenRGB("--color-accent");
    const strong = tokenRGB("--color-accent-strong");
    gl!.uniform3fv(uGround, ground);
    // The tints are the accent family diluted toward the ground, so the
    // mesh always reads as atmosphere, never as a poster over the text.
    gl!.uniform3fv(uTint1, mix(accent, ground, 0.5));
    gl!.uniform3fv(uTint2, mix(strong, ground, 0.4));
  }

  function resize(): void {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    // Half resolution: the mesh is pure low-frequency gradient, and the
    // browser upscales it for free.
    canvas!.width = Math.max(1, Math.floor((window.innerWidth * dpr) / 2));
    canvas!.height = Math.max(1, Math.floor((window.innerHeight * dpr) / 2));
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
    frame(ms);
    raf = requestAnimationFrame(loop);
  }

  function start(): void {
    cancelAnimationFrame(raf);
    loadTokens();
    resize();
    if (still.matches) {
      frame(0); // one honest frame, then stillness
    } else {
      raf = requestAnimationFrame(loop);
    }
  }

  window.addEventListener("resize", resize);
  still.addEventListener("change", start);
  // Re-read the uniforms whenever the rendition changes: the toggle
  // writes [data-theme] on <html>, the OS flips prefers-color-scheme.
  new MutationObserver(start).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"],
  });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);

  canvas.dataset.ready = "";
  start();
}

export {};
