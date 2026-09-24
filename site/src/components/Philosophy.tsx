import Reveal from "./Reveal";

export default function Philosophy() {
  return (
    <section id="philosophy" className="relative mx-auto max-w-6xl scroll-mt-16 px-5 py-20 sm:px-8 md:py-28">
      <div className="grid gap-12 md:grid-cols-[1.35fr_1fr] md:gap-16">
        <Reveal>
          <div className="relative">
            <p className="font-mono text-[11px] uppercase tracking-[0.25em] text-ink-faint">§ 04 — philosophy</p>
            <h2 className="mt-3 max-w-xl font-serif text-[clamp(1.9rem,4vw,3rem)] font-medium leading-[1.08] tracking-tight">
              Neovim shouldn&apos;t start as a{" "}
              <span className="circled italic text-accent">blank page.</span>
            </h2>

            <div className="mt-8 max-w-xl space-y-5 text-[15px] leading-relaxed text-ink-soft">
              <p>
                A fresh Neovim gives you an editor and a challenge: build the
                environment yourself, from blog posts and half-maintained
                dotfiles. wnvim skips that part. It hands you a complete,
                coherent setup — LSP, completion, themes, keymaps — assembled
                from boring, reliable choices.
              </p>
              <p>
                But it is not a black box. Every option lives in a small,
                commented Lua module. No magic tables, no framework of your
                senior engineer&apos;s invention. Read it like a notebook;
                edit it like your own.
              </p>
              <p className="border-l-2 border-accent pl-4 font-serif text-lg italic text-ink">
                “A starting point, not a destination.”
              </p>
            </div>

            <p className="mt-10 font-hand text-3xl text-accent [--tilt:-1.5deg] floaty">
              You can change <span className="uw underline decoration-2">everything.</span>
            </p>
          </div>
        </Reveal>

        {/* diagram card */}
        <Reveal delay={120}>
          <div className="sheet card-lift -rotate-1 p-6">
            <span className="tape tape-tl" aria-hidden="true" />
            <p className="mb-4 font-mono text-[10px] uppercase tracking-widest text-ink-faint">
              fig. 2 — how a config is allowed to feel
            </p>
            <svg viewBox="0 0 300 220" className="w-full" role="img" aria-label="Diagram: blank nvim plus wnvim equals a ready editor; everything editable flows back out.">
              <g fill="none" stroke="#232019" strokeWidth="1.6">
                <rect x="10" y="20" width="110" height="46" rx="4" strokeDasharray="4 3" />
                <rect x="170" y="20" width="120" height="46" rx="4" />
                <rect x="90" y="150" width="120" height="46" rx="4" />
                <path d="M65 66 v30 h150 M215 66 v30" pathLength={1} className="draw-path" />
                <path d="M150 96 v48 m0 0 l-6 -8 m6 8 l6 -8" pathLength={1} className="draw-path" />
                <path d="M90 173 H30 V90" strokeDasharray="5 4" pathLength={1} className="draw-path" />
                <path d="M30 90 l-5 8 h10 z" fill="#a8423e" stroke="none" />
              </g>
              <g fontFamily="JetBrains Mono, monospace" fontSize="11" fill="#232019">
                <text x="24" y="40">vanilla nvim</text>
                <text x="24" y="56" fontSize="9" fill="#8b8578">empty · silent</text>
                <text x="184" y="40">+ wnvim</text>
                <text x="184" y="56" fontSize="9" fill="#8b8578">opinionated defaults</text>
                <text x="112" y="170">ready editor</text>
                <text x="112" y="186" fontSize="9" fill="#8b8578">in ~40 seconds</text>
                <text x="34" y="84" fontSize="9" fill="#a8423e" fontStyle="italic">← still yours to edit</text>
              </g>
            </svg>
            <ul className="mt-4 space-y-2 border-t border-dashed border-line pt-4 font-mono text-[12px] text-ink-soft">
              <li>□ one repo, zero submodules</li>
              <li>□ pinned plugin revisions (lazy-lock)</li>
              <li>□ reversible install &amp; uninstall</li>
              <li>□ MIT — fork it, keep it</li>
            </ul>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
