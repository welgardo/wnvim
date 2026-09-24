import CopyCommand from "./CopyCommand";
import Reveal from "./Reveal";

const STEPS = [
  { n: "1", cmd: "git clone https://github.com/welgardo/wnvim.git", hint: "grab the repository" },
  { n: "2", cmd: "cd wnvim", hint: "step inside" },
  { n: "3", cmd: "./install.sh", hint: "the installer backs up any existing config first — never deletes" },
];

export default function Installation() {
  return (
    <section id="install" className="relative scroll-mt-16 border-y border-line bg-paper-deep/50 px-5 py-20 sm:px-8 md:py-28">
      <div className="mx-auto max-w-3xl">
        <Reveal>
          <div className="sheet relative rotate-[0.3deg] p-7 sm:p-10">
            {/* punch holes down the left margin */}
            <div className="pointer-events-none absolute inset-y-8 left-4 hidden flex-col justify-between sm:flex" aria-hidden="true">
              {[0, 1, 2, 3, 4].map((i) => (
                <span key={i} className="h-3 w-3 rounded-full border border-line bg-paper shadow-inner" />
              ))}
            </div>
            <span className="tape tape-top" aria-hidden="true" />

            <p className="font-mono text-[11px] uppercase tracking-[0.25em] text-ink-faint">§ 05 — installation</p>
            <h2 className="mt-2 font-serif text-4xl font-medium tracking-tight sm:text-5xl">
              Start <span className="uw italic">here.</span>
            </h2>
            <p className="mt-4 max-w-md text-[15px] leading-relaxed text-ink-soft">
              Three lines and a keystroke. Requires Neovim ≥ 0.9, git and bash.
              A Nerd Font is recommended for icons.
            </p>

            <ol className="mt-9 space-y-7">
              {STEPS.map((s) => (
                <li key={s.n}>
                  <div className="mb-2 flex items-baseline gap-3">
                    <span className="grid h-6 w-6 shrink-0 place-items-center rounded-full border border-ink font-serif text-sm italic">
                      {s.n}
                    </span>
                    <span className="font-hand text-lg text-pencil">{s.hint}</span>
                  </div>
                  <CopyCommand text={s.cmd} className="ml-1" />
                </li>
              ))}

              <li>
                <div className="mb-2 flex items-baseline gap-3">
                  <span className="grid h-6 w-6 shrink-0 place-items-center rounded-full border border-ink bg-ink font-serif text-sm italic text-paper">
                    ✓
                  </span>
                  <span className="font-hand text-lg text-pencil">launch it — that&apos;s the whole ritual</span>
                </div>
                <CopyCommand text="wnvim" className="ml-1" label="run" />
              </li>
            </ol>

            <div className="mt-9 border-t border-dashed border-line pt-5">
              <p className="font-mono text-[12px] leading-relaxed text-ink-soft">
                <span className="text-accent">#</span> prefer plain{" "}
                <code className="border border-line bg-paper px-1">nvim</code>? Install in{" "}
                <em>standard</em> mode. Want both configs side by side? Choose{" "}
                <em>custom</em> mode and the launcher keeps{" "}
                <code className="border border-line bg-paper px-1">~/.config/nvim</code>{" "}
                untouched.
              </p>
              <p className="floaty mt-4 font-hand text-xl text-accent [--tilt:-1deg]">
                uninstall.sh puts your old config exactly back. pinky promise.
              </p>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
