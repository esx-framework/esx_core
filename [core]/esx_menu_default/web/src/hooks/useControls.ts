import { useEffect, useRef } from "react";

export type Control = "TOP" | "DOWN" | "ENTER" | "BACKSPACE" | "LEFT" | "RIGHT";

interface Props {
  elements: any[];
  position: number;
  setPosition: (p: number) => void;
  submit: (position?: number) => void;
  cancel: () => void;
  change: (position?: number) => void;
  changeLeft: (position?: number) => void;
  changeRight: (position?: number) => void;
}

export const useControls = ({
  elements,
  position,
  setPosition,
  submit,
  cancel,
  change,
  changeLeft,
  changeRight,
}: Props) => {
  const positionRef = useRef(position);

  useEffect(() => {
    positionRef.current = position;
  }, [position]);

  useEffect(() => {
    const onMessage = (
      ev: MessageEvent<{ action: string; control: Control }>
    ) => {
      if (ev.data.action !== "controlPressed") return;

      const skipUp = (p: number) => {
        let next = p === 0 ? elements.length - 1 : p - 1;
        while (elements[next]?.unselectable) {
          next = next === 0 ? elements.length - 1 : next - 1;
        }
        return next;
      };

      const skipDown = (p: number) => {
        let next = p === elements.length - 1 ? 0 : p + 1;
        while (elements[next]?.unselectable) {
          next = next === elements.length - 1 ? 0 : next + 1;
        }
        return next;
      };

      const moveTo = (next: number) => {
        positionRef.current = next;
        setPosition(next);
        change(next);
      };

      switch (ev.data.control) {
        case "TOP":
          moveTo(skipUp(positionRef.current));
          break;
        case "DOWN":
          moveTo(skipDown(positionRef.current));
          break;
        case "ENTER":
          if (!elements[positionRef.current]?.unselectable) submit(positionRef.current);
          break;
        case "BACKSPACE":
          cancel();
          break;
        case "LEFT":
          changeLeft(positionRef.current);
          break;
        case "RIGHT":
          changeRight(positionRef.current);
          break;
      }
    };

    window.addEventListener("message", onMessage);
    return () => window.removeEventListener("message", onMessage);
  }, [
    elements,
    position,
    setPosition,
    submit,
    cancel,
    change,
    changeLeft,
    changeRight,
  ]);
};
