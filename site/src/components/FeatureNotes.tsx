import Reveal from "./Reveal";

type Feature = { title: string; note: string; glyph: string; key?: string };

const FEATURES: Feature[] = [
  { title: "Smart defaults", note: "numbered lines, undofile tree, clipboard integration — the options you'd set anyway.", glyph: "✎" },
  { title: "LSP support", note: "servers auto-installed & managed via Mason. Open a file, get a language server.", glyph: "⇌", key: ":Mason" },
  { title: "Treesitter", note: "real syntax highlighting and structural movement for every major language.", glyph: "❦" },
  { title: "Telescope", note: "fuzzy-find files, text, help pages and git history from one prompt.", glyph: "◎", key: "<Space> f f" },
  { title: "Git integration", note: "inline signs, blame in the corner, hunks you can stage with a keystroke.", glyph: "⑂" },
  { title: "Autocompletion", note: "nvim-cmp with snippets, paths and LSP items — never intrusive.", glyph: "⇥" },
  { title: "Diagnostics", note: "errors and warnings inline, in the gutter, and summarized on demand.", glyph: "⚑", key: "]d" },
  { title: "Formatting", note: "one keypress runs conform.nvim — formatters install themselves.", glyph: "≡", key: "<Space> f B" },
  { title: "File navigation", note: "a tree that stays out of your way until the moment you need it.", glyph: "▤", key: "<Space> e" },
  { title: "Fast startup", note: "lazy-loaded plugin spec, pinned by lazy-lock.json. Cold start stays quiet.", glyph: "⟫" },
  { title: "Keyboard-first", note: "every action reachable; which-key shows you the map as you learn it.", glyph: "⌨" },
  { title: "Custom themes", note: "10 styles × day/night, generated from one transparent palette file.", glyph: "◐", key: ":WnvimTheme" },
];

export default function FeatureNotes() {
  return (
    <section id="features" className="relative scroll-mt-16 border-y border-line bg-paper-deep/50">
      {/* torn edge dots */}
      <div className="mx-auto flex max-w-6xl justify-between px-8 pt-6" aria-hidden="true">
        {Array.from({ length: 14 }).map((_, i) => (
          <span key={i} className="h-1.5 w-1.5 rounded-full bg-ink/20" />
        ))}
      </div>

      <div className="mx-auto max-w-6xl px-5 py-16 sm:px-8 md:py-24">
        <Reveal>
          <div className="mb-12 max-w-2xl">
            <p className="font-mono text-[11px] uppercase tracking-[0.25em] text-ink-faint">§ 03 — contents</p>
            <h2 className="mt-2 font-serif text-4xl font-medium tracking-tight sm:text-5xl">
              What&apos;s <span className="uw uw-blue italic">inside?</span>
            </h2>
            <p className="mt-4 text-[15px] leading-relaxed text-ink-soft">
              Twelve pinned notes from the config itself. Nothing experimental,
              nothing abandoned — each piece earns its place or gets cut.
            </p>
          </div>
        </Reveal>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((f, i) => (
            <Reveal key={f.title} delay={(i % 3) * 70}>
              <article
                className="sheet card-lift group h-full p-5"
                style={{ transform: `rotate(${i % 2 === 0 ? 0.4 : -0.5}deg)` }}
              >
                {i % 3 === 1 && <span className="pin" aria-hidden="true" />}
                {i % 3 === 0 && <span className="tape tape-tr" aria-hidden="true" />}
                <div className="flex items-start gap-3">
                  <span className="grid h-9 w-9 shrink-0 place-items-center border border-ink/50 bg-paper font-mono text-base transition-colors group-hover:bg-ink group-hover:text-paper">
                    {f.glyph}
                  </span>
                  <div>
                    <h3 className="font-serif text-lg font-medium leading-snug">{f.title}</h3>
                    {f.key && (
                      <code className="mt-0.5 inline-block border border-dashed border-pencil/50 px-1.5 font-mono text-[10px] text-pencil">
                        {f.key}
                      </code>
                    )}
                  </div>
                </div>
                <p className="mt-3 text-sm leading-relaxed text-ink-soft">{f.note}</p>
              </article>
            </Reveal>
          ))}
        </div>

        <Reveal>
          <p className="floaty mt-12 text-center font-hand text-xl text-accent [--tilt:1deg]">
            ← every note maps to a file you can read in five minutes →
          </p>
        </Reveal>
      </div>
    </section>
  );
}
