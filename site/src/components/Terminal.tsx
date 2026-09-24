import { useEffect, useRef, useState } from "react";
import { usePrefersReducedMotion, useInView } from "../hooks";

type Line =
  | { kind: "prompt"; text: string }
  | { kind: "step"; text: string }
  | { kind: "ok"; text: string };

const SCRIPT: Line[] = [
  { kind: "prompt", text: "wnvim" },
  { kind: "step", text: "checking dependencies…" },
  { kind: "step", text: "installing configuration…" },
  { kind: "step", text: "applying theme…" },
  { kind: "step", text: "configuring plugins…" },
  { kind: "ok", text: "wnvim is ready — :help wnvim" },
];

/** Paper-framed terminal that types out a wnvim install run. */
export default function Terminal() {
  const reduced = usePrefersReducedMotion();
  const { ref, inView } = useInView<HTMLDivElement>({ threshold: 0.35 });
  const [visible, setVisible] = useState<Line[]>(reduced ? SCRIPT : []);
  const [typing, setTyping] = useState(reduced ? "" : null as string | null);
  const startedRef = useRef(false);

  useEffect(() => {
    if (reduced) {
      setVisible(SCRIPT);
      setTyping("");
      return;
    }
    if (!inView || startedRef.current) return;
    startedRef.current = true;

    let cancelled = false;
    let li = 0;
    const timers: number[] = [];

    const typeLine = (line: Line) => {
      const full = line.kind === "prompt" ? `$ ${line.text}` : `→ ${line.text}`;
      let ci = 0;
      const tick = () => {
        if (cancelled) return;
        ci += 1;
        setTyping(full.slice(0, ci));
        if (ci < full.length) {
          timers.push(window.setTimeout(tick, 14 + Math.random() * 26));
        } else {
          timers.push(
            window.setTimeout(() => {
              if (cancelled) return;
              setVisible((v) => [...v, line]);
              setTyping("");
              li += 1;
              if (li < SCRIPT.length) {
                timers.push(window.setTimeout(() => typeLine(SCRIPT[li]), line.kind === "prompt" ? 380 : 240));
              } else {
                timers.push(window.setTimeout(() => setTyping(null), 200));
              }
            }, 160)
          );
        }
      };
      tick();
    };

    timers.push(window.setTimeout(() => typeLine(SCRIPT[0]), 500));
    return () => {
      cancelled = true;
      timers.forEach(clearTimeout);
    };
  }, [inView, reduced]);

  const renderLine = (line: Line, key: string, partial?: string) => {
    if (line.kind === "prompt") {
      return (
        <div key={key} className="text-[#e8e2d4]">
          <span className="text-[#c9a86a]">$ </span>
          <span className="font-medium">{partial ?? line.text}</span>
        </div>
      );
    }
    if (line.kind === "ok") {
      return (
        <div key={key} className="text-[#7ec98f]">
          <span>{"✓ "}</span>
          {partial ?? line.text}
        </div>
      );
    }
    return (
      <div key={key} className="text-[#9fb4cc]">
        <span>{"→ "}</span>
        {partial ?? line.text}
      </div>
    );
  };

  const nextLine = typing !== null && visible.length < SCRIPT.length ? SCRIPT[visible.length] : undefined;

  return (
    <div ref={ref}>
      <div
        className="overflow-hidden border border-black/60 font-mono shadow-[0_18px_40px_-18px_rgba(35,32,25,0.55)]"
        style={{ background: "#16150f" }}
        role="img"
        aria-label="Terminal showing wnvim installing and finishing with 'wnvim is ready'"
      >
        {/* title bar */}
        <div className="flex items-center gap-2 border-b border-white/10 bg-[#211f17] px-3 py-2">
          <span className="h-2.5 w-2.5 rounded-full bg-[#a8423e]" />
          <span className="h-2.5 w-2.5 rounded-full bg-[#9a7330]" />
          <span className="h-2.5 w-2.5 rounded-full bg-[#4c7a4f]" />
          <span className="ml-2 text-[11px] tracking-wide text-[#8b8578]">
            user@dev — ~/code — zsh
          </span>
        </div>
        {/* body */}
        <div className="min-h-[168px] space-y-1 px-4 py-3 text-[12.5px] leading-relaxed sm:min-h-[180px] sm:text-[13px]">
          {visible.map((l, i) => renderLine(l, String(i)))}
          {nextLine && renderLine(nextLine, "typing", typing ?? undefined)}
          {typing === null && !reduced && (
            <div className="text-[#e8e2d4]">
              <span className="text-[#c9a86a]">$ </span>
              <span className="cursor-blink inline-block h-[1em] w-[0.55em] translate-y-[2px] bg-[#e8e2d4]" />
            </div>
          )}
          {(reduced || typing === null) && (
            <div className="pt-1 text-[11px] text-[#8b8578]">
              -- TERMINAL --&nbsp;&nbsp;wnvim v0.1.0&nbsp;&nbsp;·&nbsp;&nbsp;MIT
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
