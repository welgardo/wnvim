import type { ReactNode } from "react";
import { useReveal } from "../hooks";

type Props = {
  children: ReactNode;
  className?: string;
  /** delay in ms before the reveal transition starts */
  delay?: number;
};

/** Section wrapper that fades + slides its content in on scroll. */
export default function Reveal({ children, className = "", delay = 0 }: Props) {
  const ref = useReveal<HTMLDivElement>();
  return (
    <div
      ref={ref}
      className={`reveal ${className}`}
      style={delay ? { transitionDelay: `${delay}ms` } : undefined}
    >
      {children}
    </div>
  );
}
