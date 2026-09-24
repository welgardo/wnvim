import { useEffect, useState } from "react";
import { themes, type Theme } from "../data/themes";
import EditorPreview from "./EditorPreview";
import Reveal from "./Reveal";

type Mode = "day" | "night";

const PALETTE_KEYS = ["bg", "fg", "comment", "red", "green", "blue", "magenta", "accent"] as const;

function ThemeCard({
  theme,
  mode,
  tilt,
  onPreview,
}: {
  theme: Theme;
  mode: Mode;
  tilt: number;
  onPreview: () => void;
}) {
  const p = theme[mode];
  return (
    <div
      className="sheet card-lift flex flex-col p-3.5 sm:p-4"
      style={{ transform: `rotate(${tilt}deg)` }}
    >
      <div className="mb-2.5 flex items-start justify-between gap-2">
        <div>
          <h3 className="font-serif text-lg font-medium leading-tight">{theme.name}</h3>
          <p className="mt-0.5 font-mono text-[10px] uppercase tracking-widest text-ink-faint">
            style {String(theme.id).padStart(2, "0")} · {mode}
          </p>
        </div>
        <span
          className="mt-1 inline-flex shrink-0 items-center gap-1 border border-line bg-paper px-1.5 py-0.5 font-mono text-[10px] text-ink-soft"
          title={`${mode} variant`}
        >
          {mode === "day" ? "☀ light" : "☾ dark"}
        </span>
      </div>

      <div className="overflow-hidden border border-black/30 shadow-inner">
        <EditorPreview p={p} name={theme.name} compact />
      </div>

      <div className="mt-3 flex items-center justify-between gap-2">
        <div className="flex gap-1" aria-label={`${theme.name} palette`}>
          {PALETTE_KEYS.map((k) => (
            <span
              key={k}
              className="h-3.5 w-3.5 border border-black/20"
              style={{ background: p[k] }}
              title={`${k} ${p[k]}`}
            />
          ))}
        </div>
        <button
          type="button"
          onClick={onPreview}
          className="border border-ink/60 bg-card px-2.5 py-1 font-mono text-[11px] transition-colors hover:bg-ink hover:text-paper"
        >
          Preview ↗
        </button>
      </div>
      <p className="mt-2.5 border-t border-dashed border-line pt-2 font-hand text-base leading-snug text-pencil">
        {theme.tagline}
      </p>
    </div>
  );
}

export default function ThemeGallery() {
  const [mode, setMode] = useState<Mode>("night");
  const [open, setOpen] = useState<number | null>(null);

  const active = open !== null ? themes[open] : null;

  useEffect(() => {
    if (active === null) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && setOpen(null);
    window.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      window.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [active]);

  return (
    <section id="themes" className="relative mx-auto max-w-6xl scroll-mt-16 px-5 py-20 sm:px-8 md:py-28">
      <Reveal>
        <div className="mb-10 flex flex-wrap items-end justify-between gap-6">
          <div>
            <p className="font-mono text-[11px] uppercase tracking-[0.25em] text-ink-faint">§ 02 — theming</p>
            <h2 className="mt-2 font-serif text-4xl font-medium tracking-tight sm:text-5xl">
              Pick your <span className="uw italic">mood.</span>
            </h2>
            <p className="mt-4 max-w-xl text-[15px] leading-relaxed text-ink-soft">
              Ten hand-authored styles, each with a Day and a Night palette —
              twenty looks in total. Switch instantly with{" "}
              <code className="border border-line bg-card px-1.5 py-0.5 font-mono text-[12px]">:WnvimTheme</code>{" "}
              or <kbd className="border border-line bg-card px-1.5 py-0.5 font-mono text-[11px]">&lt;Space&gt; t h</kbd>, no restart needed.
            </p>
          </div>

          {/* day/night switch */}
          <div className="flex items-center gap-3">
            <span className="font-hand text-lg text-ink-soft">show me:</span>
            <div className="inline-flex border border-ink bg-card p-1" role="tablist" aria-label="Palette mode">
              {(["day", "night"] as Mode[]).map((m) => (
                <button
                  key={m}
                  role="tab"
                  aria-selected={mode === m}
                  onClick={() => setMode(m)}
                  className={`px-4 py-1.5 font-mono text-xs uppercase tracking-wide transition-colors ${
                    mode === m ? "bg-ink text-paper" : "text-ink hover:bg-paper-deep"
                  }`}
                >
                  {m === "day" ? "☀ day" : "☾ night"}
                </button>
              ))}
            </div>
          </div>
        </div>
      </Reveal>

      <div className="grid grid-cols-1 gap-7 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {themes.map((t, i) => (
          <Reveal key={t.id} delay={(i % 4) * 60}>
            <ThemeCard
              theme={t}
              mode={mode}
              tilt={[0.5, -0.6, 0.35, -0.4][i % 4]}
              onPreview={() => setOpen(i)}
            />
          </Reveal>
        ))}
      </div>

      <Reveal>
        <p className="floaty mt-10 text-center font-hand text-xl text-accent [--tilt:-1deg]">
          every palette lives in one readable lua file — nothing hidden in plugins.
        </p>
      </Reveal>

      {/* preview modal */}
      {active && (
        <div
          className="fixed inset-0 z-[60] flex items-center justify-center bg-ink/60 p-4 backdrop-blur-[2px]"
          onClick={() => setOpen(null)}
          role="dialog"
          aria-modal="true"
          aria-label={`${active.name} theme preview`}
        >
          <div
            className="sheet relative w-full max-w-3xl p-4 sm:p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <span className="tape tape-top" aria-hidden="true" />
            <div className="mb-4 flex items-center justify-between gap-4">
              <div>
                <h3 className="font-serif text-2xl font-medium">{active.name}</h3>
                <p className="font-mono text-[11px] uppercase tracking-widest text-ink-faint">
                  style {active.id} · {mode} · {active[mode].bg}
                </p>
              </div>
              <div className="flex items-center gap-2">
                <div className="hidden border border-ink sm:flex">
                  {(["day", "night"] as Mode[]).map((m) => (
                    <button
                      key={m}
                      onClick={() => setMode(m)}
                      className={`px-3 py-1 font-mono text-[11px] uppercase ${
                        mode === m ? "bg-ink text-paper" : "bg-card text-ink"
                      }`}
                    >
                      {m}
                    </button>
                  ))}
                </div>
                <button
                  onClick={() => setOpen(null)}
                  aria-label="Close preview"
                  className="border border-ink bg-card px-3 py-1 font-mono text-sm hover:bg-ink hover:text-paper"
                >
                  ✕
                </button>
              </div>
            </div>
            <div className="overflow-hidden border border-black/40 shadow-[0_14px_30px_-16px_rgba(35,32,25,0.6)]">
              <EditorPreview p={active[mode]} name={active.name} compact={false} />
            </div>
            <div className="mt-4 flex flex-wrap items-center justify-between gap-3">
              <div className="flex gap-1.5">
                {Object.entries(active[mode])
                  .filter(([k]) => ["bg", "fg", "red", "green", "yellow", "blue", "magenta", "cyan", "accent"].includes(k))
                  .map(([k, v]) => (
                    <span key={k} className="h-5 w-5 border border-black/25" style={{ background: v }} title={`${k} ${v}`} />
                  ))}
              </div>
              <p className="font-hand text-lg text-pencil">{active.tagline}</p>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
