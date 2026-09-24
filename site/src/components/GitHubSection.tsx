import Reveal from "./Reveal";

const GITHUB_URL = "https://github.com/welgardo/wnvim";

/**
 * Repo stats. These are placeholders until the GitHub API is wired up —
 * swap `PLACEHOLDER` for a fetch to https://api.github.com/repos/welgardo/wnvim.
 */
const PLACEHOLDER = true;
const STATS: { label: string; value: string; href: string; glyph: string }[] = [
  { label: "stars", value: "—", href: `${GITHUB_URL}/stargazers`, glyph: "★" },
  { label: "forks", value: "—", href: `${GITHUB_URL}/forks`, glyph: "⑃" },
  { label: "open issues", value: "—", href: `${GITHUB_URL}/issues`, glyph: "◎" },
  { label: "license", value: "MIT", href: `${GITHUB_URL}/blob/main/LICENSE`, glyph: "⚖" },
  { label: "contributors", value: "1+", href: `${GITHUB_URL}/graphs/contributors`, glyph: "☺" },
];

export default function GitHubSection() {
  return (
    <section id="github" className="relative mx-auto max-w-6xl scroll-mt-16 px-5 py-20 sm:px-8 md:py-28">
      <Reveal>
        <div className="mb-10 text-center">
          <p className="font-mono text-[11px] uppercase tracking-[0.25em] text-ink-faint">§ 06 — source</p>
          <h2 className="mt-2 font-serif text-4xl font-medium tracking-tight sm:text-5xl">
            Built in the <span className="uw uw-blue italic">open.</span>
          </h2>
          <p className="mx-auto mt-4 max-w-lg text-[15px] leading-relaxed text-ink-soft">
            Every line lives on GitHub. Read it, fork it, break it, send it
            back better.
          </p>
        </div>
      </Reveal>

      <Reveal>
        <div className="sheet card-lift mx-auto max-w-3xl p-6 sm:p-8">
          <span className="tape tape-top" aria-hidden="true" />
          {/* repo header like a clipped-out github card */}
          <div className="flex flex-wrap items-start justify-between gap-4 border-b border-dashed border-line pb-5">
            <div>
              <a
                href={GITHUB_URL}
                target="_blank"
                rel="noreferrer"
                className="font-serif text-xl font-medium text-pencil underline-offset-4 hover:underline sm:text-2xl"
              >
                welgardo / wnvim
              </a>
              <p className="mt-1.5 text-sm text-ink-soft">
                ⚡ A ready-to-use Neovim configuration with sensible defaults, LSP,
                Treesitter, Telescope and 10 themes.
              </p>
              <div className="mt-3 flex flex-wrap gap-2 font-mono text-[11px]">
                {["neovim", "lua", "dotfiles", "tree-sitter", "telescope", "lsp"].map((t) => (
                  <span key={t} className="rounded-full border border-pencil/40 bg-pencil/5 px-2.5 py-0.5 text-pencil">
                    {t}
                  </span>
                ))}
              </div>
            </div>
            <div className="flex items-center gap-2 border border-ink/25 bg-paper px-3 py-2 font-mono text-xs text-ink-soft">
              <span aria-hidden="true">📌</span> public repo
            </div>
          </div>

          {/* stat slips */}
          <dl className="grid grid-cols-2 gap-3 pt-5 sm:grid-cols-5">
            {STATS.map((s) => (
              <a
                key={s.label}
                href={s.href}
                target="_blank"
                rel="noreferrer"
                className="group block border border-line bg-paper/70 p-3 text-center transition-colors hover:border-ink"
                style={{ transform: `rotate(${(s.label.length % 3) - 1}deg)` }}
              >
                <dt className="order-2 mt-1 block font-mono text-[10px] uppercase tracking-wide text-ink-faint group-hover:text-ink">
                  {s.glyph} {s.label}
                </dt>
                <dd className="block font-serif text-2xl font-medium">{s.value}</dd>
              </a>
            ))}
          </dl>

          {PLACEHOLDER && (
            <p className="mt-4 text-center font-mono text-[10px] uppercase tracking-widest text-ink-faint">
              # counts pending — api integration coming soon
            </p>
          )}

          <div className="mt-7 flex flex-wrap items-center justify-center gap-4">
            <a
              href={GITHUB_URL}
              target="_blank"
              rel="noreferrer"
              className="btn-ink hand-border px-8 py-3.5 font-mono text-sm font-medium"
            >
              View source →
            </a>
            <a
              href={`${GITHUB_URL}/issues/new/choose`}
              target="_blank"
              rel="noreferrer"
              className="btn-outline hand-border-alt px-6 py-3.5 font-mono text-sm"
            >
              Report an issue
            </a>
          </div>
        </div>
      </Reveal>
    </section>
  );
}
