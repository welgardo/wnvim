import Terminal from "./Terminal";

const GITHUB_URL = "https://github.com/welgardo/wnvim";

/** Hand-drawn arrow pointing from annotation to the terminal. */
function ScribbleArrow({ className = "", flip = false }: { className?: string; flip?: boolean }) {
  return (
    <svg
      viewBox="0 0 120 60"
      fill="none"
      className={className}
      style={flip ? { transform: "scaleX(-1)" } : undefined}
      aria-hidden="true"
    >
      <path
        d="M4 8 C 34 4, 78 12, 96 40 M96 40 l-10 -8 M96 40 l12 -3"
        stroke="#232019"
        strokeWidth="2"
        strokeLinecap="round"
        pathLength={1}
        className="draw-path"
      />
    </svg>
  );
}

export default function Hero() {
  return (
    <header className="ruled relative overflow-hidden">
      {/* margin rule line */}
      <div className="pointer-events-none absolute inset-y-0 left-10 hidden w-px bg-accent/30 md:block lg:left-16" />

      <nav className="mx-auto flex max-w-6xl items-center justify-between px-5 pb-4 pt-6 sm:px-8">
        <a href="#top" className="flex items-baseline gap-2">
          <span className="font-serif text-2xl font-semibold italic tracking-tight">wnvim</span>
          <span className="hidden font-mono text-[10px] uppercase tracking-[0.2em] text-ink-faint sm:inline">
            v0.1.0 · MIT
          </span>
        </a>
        <div className="flex items-center gap-1 sm:gap-2">
          {[
            ["themes", "#themes"],
            ["features", "#features"],
            ["install", "#install"],
          ].map(([label, href]) => (
            <a
              key={label}
              href={href}
              className="px-2 py-1 font-mono text-xs text-ink-soft underline-offset-4 hover:text-ink hover:underline sm:text-[13px]"
            >
              {label}
            </a>
          ))}
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noreferrer"
            className="ml-1 border border-ink/60 bg-card px-2.5 py-1 font-mono text-xs transition-colors hover:bg-ink hover:text-paper sm:px-3"
          >
            GitHub ↗
          </a>
        </div>
      </nav>

      <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 pb-20 pt-10 sm:px-8 md:grid-cols-[1.05fr_1fr] md:pb-28 md:pt-16">
        {/* left column — the big type */}
        <div className="relative">
          <p className="mb-5 inline-block -rotate-1 border border-dashed border-ink/40 bg-card px-3 py-1 font-mono text-[11px] uppercase tracking-[0.18em] text-ink-soft">
            open source · neovim configuration
          </p>
          <h1 className="font-serif text-[clamp(2.9rem,7vw,5.2rem)] font-medium leading-[0.98] tracking-tight">
            Your Neovim.
            <br />
            <span className="uw italic">Your way.</span>
          </h1>
          <p className="mt-8 max-w-md text-[15px] leading-relaxed text-ink-soft sm:text-base">
            wnvim is a ready-to-use Neovim configuration designed to turn a
            fresh installation into a powerful development environment — one
            command, no dotfiles archaeology.
          </p>

          <div className="mt-9 flex flex-wrap items-center gap-4">
            <a href="#install" className="btn-ink hand-border px-6 py-3 font-mono text-sm font-medium">
              Install wnvim ↓
            </a>
            <a
              href={GITHUB_URL}
              target="_blank"
              rel="noreferrer"
              className="btn-outline hand-border-alt px-6 py-3 font-mono text-sm font-medium"
            >
              View on GitHub
            </a>
          </div>

          <p className="mt-8 font-hand text-xl text-pencil [--tilt:-1.5deg] floaty">
            backup-first installer — your current config is never deleted.
          </p>
        </div>

        {/* right column — taped sheet with curl + terminal */}
        <div className="relative mx-auto w-full max-w-lg">
          <ScribbleArrow className="absolute -left-16 top-24 z-20 hidden h-14 w-28 md:block" flip />
          <p className="absolute -top-9 left-2 z-20 -rotate-3 font-hand text-2xl text-accent md:-left-8">
            one command. that&apos;s it.
          </p>

          <div className="sheet card-lift rotate-[0.6deg] p-4 sm:p-5">
            <span className="tape tape-top" aria-hidden="true" />
            <CopyLine command="curl -fsSL https://raw.githubusercontent.com/welgardo/wnvim/main/install.sh | sh" />
            <div className="mt-4">
              <Terminal />
            </div>
            <p className="mt-3 flex items-center justify-between font-mono text-[10px] uppercase tracking-widest text-ink-faint">
              <span>fig. 1 — first launch</span>
              <span>~40s on a clean machine</span>
            </p>
          </div>

          {/* small sticky note */}
          <div className="absolute -bottom-8 -right-2 w-40 rotate-3 bg-[#f2e6b8] p-3 shadow-[0_10px_18px_-10px_rgba(35,32,25,0.5)] sm:-right-8">
            <p className="font-hand text-lg leading-snug text-ink">
              10 themes × day/night. try{" "}
              <span className="font-semibold">Tokyo Neon</span> first.
            </p>
          </div>
        </div>
      </div>
    </header>
  );
}

function CopyLine({ command }: { command: string }) {
  return (
    <div className="flex items-center gap-3 border border-line bg-paper/70 px-3 py-2.5">
      <span className="select-none font-mono text-sm text-accent">$</span>
      <code className="min-w-0 flex-1 overflow-x-auto whitespace-pre font-mono text-[12px] text-ink [scrollbar-width:none] sm:text-[13px]">
        {command}
      </code>
      <span aria-hidden="true" className="shrink-0 font-mono text-[10px] uppercase tracking-wide text-ink-faint">
        enter ↵
      </span>
    </div>
  );
}
