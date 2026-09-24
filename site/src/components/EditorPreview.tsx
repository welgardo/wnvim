import type { Palette } from "../data/themes";

type Props = {
  p: Palette;
  name: string;
  /** compact = card thumbnail size, large = modal size */
  compact?: boolean;
};

type Tok = { t: string; c?: keyof Palette };

/** Miniature Neovim window rendered with a theme palette. */
export default function EditorPreview({ p, name, compact = true }: Props) {
  const code: Tok[][] = [
    [{ t: "-- wnvim · ", c: "comment" }, { t: name, c: "comment" }],
    [{ t: "local" }, { t: " statusline ", c: "cyan" }, { t: "=" }, { t: "require", c: "blue" }, { t: "(" }, { t: '"wnvim.ui"', c: "green" }, { t: ")" }],
    [],
    [{ t: "local function" }, { t: " setup", c: "yellow" }, { t: "(opts)" }],
    [{ t: "  if" }, { t: " not" }, { t: " vim.o.termguicolors ", c: "cyan" }, { t: "then" }],
    [{ t: "    background " }, { t: "=" }, { t: ' "night"', c: "green" }, { t: "  -- safe default", c: "comment" }],
    [{ t: "  end" }],
    [{ t: "  return" }, { t: " { ok = ", c: "fg" }, { t: "true", c: "red" }, { t: ", style = " }, { t: "10", c: "magenta" }, { t: " }" }],
  ];

  const fs = compact ? "text-[8px] leading-[13px]" : "text-[12px] leading-[21px]";
  const chrome = compact ? 8 : 12;

  return (
    <div
      className="w-full overflow-hidden border select-none"
      style={{ background: p.bg, borderColor: p.border }}
      aria-hidden="true"
    >
      {/* tabline */}
      <div
        className="flex items-center font-mono"
        style={{
          background: p.bg_alt,
          borderBottom: `1px solid ${p.border}`,
          fontSize: chrome,
          height: compact ? 17 : 26,
        }}
      >
        <span
          className="flex h-full items-center px-2 font-medium"
          style={{ background: p.bg, color: p.fg, borderRight: `1px solid ${p.border}` }}
        >
          init.lua
        </span>
        <span className="px-2" style={{ color: p.fg_gutter }}>
          themes.lua
        </span>
        <span className="ml-auto pr-2 italic" style={{ color: p.accent }}>
          wn[{name}]
        </span>
      </div>

      {/* buffer */}
      <div className={`font-mono ${fs}`} style={{ color: p.fg, padding: compact ? "5px 0 3px" : "10px 0 8px" }}>
        {code.map((line, i) => (
          <div key={i} className="flex">
            <span
              className="shrink-0 text-right"
              style={{ color: p.fg_gutter, width: compact ? "2.4em" : "2.6em", paddingRight: "0.6em" }}
            >
              {String(i + 1).padStart(2, "0")}
            </span>
            <span className="w-[1.1em] shrink-0 text-center" style={{ color: p.fg_gutter }}>
              {i === 3 ? "+" : " "}
            </span>
            <span className="min-w-0 flex-1 truncate whitespace-pre pr-2">
              {line.map((tok, j) => (
                <span key={j} style={{ color: tok.c ? p[tok.c] : p.fg }}>
                  {tok.t}
                </span>
              ))}
              {i === 5 && <span style={{ background: p.accent, color: p.bg }}> </span>}
            </span>
          </div>
        ))}
        <div className="truncate pl-[3.5em] pt-0.5" style={{ color: p.error }}>
          {"↖ E5100: missing plugin spec"}
        </div>
      </div>

      {/* statusline */}
      <div
        className="flex items-center justify-between font-mono font-medium"
        style={{
          background: p.accent,
          color: p.bg,
          fontSize: chrome,
          height: compact ? 15 : 22,
          padding: compact ? "0 6px" : "0 10px",
        }}
      >
        <span className="flex items-center gap-2">
          <span>{compact ? "NORMAL" : "-- NORMAL --"}</span>
          <span>init.lua</span>
        </span>
        <span className="flex items-center gap-2">
          <span>lua</span>
          <span>utf-8</span>
          <span>{compact ? "8,1" : "ln 8, col 1"}</span>
        </span>
      </div>

      {/* command line */}
      <div
        className="flex items-center font-mono"
        style={{
          background: p.bg,
          color: p.fg,
          fontSize: chrome,
          height: compact ? 14 : 20,
          padding: compact ? "0 6px" : "0 10px",
        }}
      >
        <span style={{ color: p.green }}>{":"}</span>
        <span style={{ color: p.fg_gutter }}>WnvimTheme ▍</span>
      </div>
    </div>
  );
}
