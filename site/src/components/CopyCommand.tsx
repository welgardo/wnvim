import { useState } from "react";

type Props = {
  text: string;
  label?: string;
  className?: string;
};

/** Monospace command line with a paper copy button. */
export default function CopyCommand({ text, label = "copy", className = "" }: Props) {
  const [copied, setCopied] = useState(false);

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(text);
    } catch {
      // clipboard unavailable — fall back silently
      const ta = document.createElement("textarea");
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      try {
        document.execCommand("copy");
      } catch {
        /* noop */
      }
      document.body.removeChild(ta);
    }
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1600);
  };

  return (
    <div
      className={`flex items-center gap-3 border border-line bg-paper/60 px-3 py-2.5 sm:px-4 ${className}`}
    >
      <span aria-hidden="true" className="select-none font-mono text-sm text-accent">
        $
      </span>
      <code className="min-w-0 flex-1 overflow-x-auto whitespace-pre font-mono text-[13px] leading-5 text-ink sm:text-sm">
        {text}
      </code>
      <button
        type="button"
        onClick={copy}
        aria-label={`Copy: ${text}`}
        className="shrink-0 border border-ink/50 bg-card px-2.5 py-1 font-mono text-[11px] uppercase tracking-wide text-ink transition-colors hover:bg-ink hover:text-paper"
      >
        {copied ? "✓ copied" : label}
      </button>
    </div>
  );
}
