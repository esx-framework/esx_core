import { useEffect } from "react";

export type Control = "TOP" | "DOWN" | "ENTER" | "BACKSPACE" | "LEFT" | "RIGHT";

interface Props {
  elements: any[];
  position: number;
  setPosition: (p: number | ((prev: number) => number)) => void;
  submit: () => void;
  cancel: () => void;
  changeLeft: () => void;
  changeRight: () => void;
}

export const useControls = ({
  elements,
  position,
  setPosition,
  submit,
  cancel,
  changeLeft,
  changeRight,
}: Props) => {
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

      switch (ev.data.control) {
        case "TOP":
          setPosition((p) => skipUp(typeof p === "number" ? p : position));
          break;
        case "DOWN":
          setPosition((p) => skipDown(typeof p === "number" ? p : position));
          break;
        case "ENTER":
          if (!elements[position]?.unselectable) submit();
          break;
        case "BACKSPACE":
          cancel();
          break;
        case "LEFT":
          changeLeft();
          break;
        case "RIGHT":
          changeRight();
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
    changeLeft,
    changeRight,
  ]);
};
