/**
 * Client for Cherry's built-in search (`search: "cherry"`).
 *
 * The index is built by `Cherry.Search.Index` and fetched on first use,
 * so a visitor who never searches never pays for it. Ranking is
 * tf-idf over the emitted weights: no wasm, no runtime dependency.
 *
 * Query tokenizing must match `Cherry.Search.Index.tokenize/1`. Stopwords
 * are deliberately not filtered here — a stopword is simply absent from
 * the index and contributes nothing.
 */

interface IndexDoc {
  u: string;
  t: string;
  e: string;
  d?: string;
}

interface SearchIndex {
  v: number;
  docs: IndexDoc[];
  terms: Record<string, [number, number][]>;
}

const MIN_TOKEN_LENGTH = 2;
const MAX_RESULTS = 8;
const DEBOUNCE_MS = 120;

function fold(token: string): string {
  const long = token.length > 3;
  if (long && token.endsWith("s") && !token.endsWith("ss")) return token.slice(0, -1);
  return token;
}

function tokenize(text: string): string[] {
  return text
    .toLowerCase()
    .split(/[^\p{L}\p{N}]+/u)
    .filter((token) => token.length >= MIN_TOKEN_LENGTH)
    .map(fold);
}

/** Documents scored by tf-idf, with more query terms matched winning ties. */
function search(index: SearchIndex, query: string): IndexDoc[] {
  const tokens = tokenize(query);
  if (tokens.length === 0) return [];

  const total = index.docs.length;
  const scores = new Map<number, { score: number; matched: number }>();

  for (const token of tokens) {
    const postings = index.terms[token];
    if (!postings) continue;

    const idf = Math.log(1 + total / postings.length);
    for (const [id, weight] of postings) {
      const current = scores.get(id) ?? { score: 0, matched: 0 };
      current.score += weight * idf;
      current.matched += 1;
      scores.set(id, current);
    }
  }

  return [...scores.entries()]
    .sort((a, b) => b[1].matched - a[1].matched || b[1].score - a[1].score)
    .slice(0, MAX_RESULTS)
    .map(([id]) => index.docs[id])
    .filter((doc): doc is IndexDoc => doc !== undefined);
}

function resultItem(doc: IndexDoc): HTMLLIElement {
  const item = document.createElement("li");
  const link = document.createElement("a");
  link.href = doc.u;

  const title = document.createElement("span");
  title.className = "site-search-title";
  title.textContent = doc.t;
  link.appendChild(title);

  if (doc.d) {
    const date = document.createElement("time");
    date.className = "site-search-date";
    date.dateTime = doc.d;
    date.textContent = doc.d;
    link.appendChild(date);
  }

  if (doc.e) {
    const excerpt = document.createElement("span");
    excerpt.className = "site-search-excerpt";
    excerpt.textContent = doc.e;
    link.appendChild(excerpt);
  }

  item.appendChild(link);
  return item;
}

function mount(root: HTMLElement): void {
  const input = root.querySelector<HTMLInputElement>("input");
  const output = root.querySelector<HTMLElement>("[data-search-results]");
  const source = root.dataset["search"];
  if (!input || !output || !source) return;

  let index: Promise<SearchIndex> | undefined;
  let timer: number | undefined;

  const load = (): Promise<SearchIndex> => {
    index ??= fetch(source).then((response) => response.json() as Promise<SearchIndex>);
    return index;
  };

  const render = (results: IndexDoc[], query: string): void => {
    output.textContent = "";
    root.classList.toggle("site-search-open", query.length > 0);
    if (query.length === 0) return;

    if (results.length === 0) {
      const empty = document.createElement("p");
      empty.className = "site-search-empty";
      empty.textContent = "No matches.";
      output.appendChild(empty);
      output.setAttribute("aria-label", "No matches");
      return;
    }

    const list = document.createElement("ul");
    results.forEach((doc) => list.appendChild(resultItem(doc)));
    output.appendChild(list);
    output.setAttribute("aria-label", `${results.length} result${results.length === 1 ? "" : "s"}`);
  };

  const run = (): void => {
    const query = input.value.trim();
    if (query.length === 0) {
      render([], "");
      return;
    }
    // Failure is silent by design: search is an enhancement, and a
    // visitor who cannot reach the index still has the whole site.
    load()
      .then((loaded) => render(search(loaded, query), query))
      .catch(() => undefined);
  };

  // Same affordance the Pagefind island offers, so the two engines feel
  // identical from the outside.
  const mac = /Mac|iP/.test(navigator.platform || "");
  input.placeholder = `Search (${mac ? "⌘" : "Ctrl+"}K)`;

  window.addEventListener("keydown", (event: KeyboardEvent) => {
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      input.focus();
      input.select();
    }
  });

  input.addEventListener("focus", () => void load(), { once: true });

  input.addEventListener("input", () => {
    window.clearTimeout(timer);
    timer = window.setTimeout(run, DEBOUNCE_MS);
  });

  input.addEventListener("keydown", (event: KeyboardEvent) => {
    if (event.key === "Escape") {
      input.value = "";
      render([], "");
    }
  });
}

function init(): void {
  document.querySelectorAll<HTMLElement>("[data-search]").forEach(mount);
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}

export {};
