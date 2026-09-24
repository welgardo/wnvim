const GITHUB_URL = "https://github.com/welgardo/wnvim";

export default function Footer() {
  return (
    <footer className="border-t border-line bg-paper-deep/60">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-6 px-5 py-12 sm:px-8 md:flex-row md:justify-between">
        <div className="text-center md:text-left">
          <p className="font-serif text-2xl font-semibold italic tracking-tight">wnvim</p>
          <p className="mt-1 font-mono text-xs text-ink-soft">Neovim, configured your way.</p>
        </div>

        <nav aria-label="Footer" className="flex flex-wrap items-center justify-center gap-x-6 gap-y-2 font-mono text-[13px]">
          <a className="text-ink-soft hover:text-ink hover:underline" href={GITHUB_URL} target="_blank" rel="noreferrer">GitHub</a>
          <a className="text-ink-soft hover:text-ink hover:underline" href={`${GITHUB_URL}/blob/main/README.md`} target="_blank" rel="noreferrer">Documentation</a>
          <a className="text-ink-soft hover:text-ink hover:underline" href={`${GITHUB_URL}/issues`} target="_blank" rel="noreferrer">Issues</a>
          <a className="text-ink-soft hover:text-ink hover:underline" href={`${GITHUB_URL}/blob/main/LICENSE`} target="_blank" rel="noreferrer">License</a>
        </nav>
      </div>

      <div className="border-t border-dashed border-line">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-2 px-5 py-5 sm:flex-row sm:px-8">
          <p className="font-hand text-lg text-accent [--tilt:-1.2deg]">
            made for people who live in their terminal.
          </p>
          <p className="font-mono text-[11px] text-ink-faint">
            © {new Date().getFullYear()} wnvim · MIT · no trackers, no cookies
          </p>
        </div>
      </div>
    </footer>
  );
}
