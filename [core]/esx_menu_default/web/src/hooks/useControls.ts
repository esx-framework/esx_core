// hooks/useControls.ts
import { useEffect } from "react";

export type Control = "TOP" | "DOWN" | "ENTER" | "BACKSPACE" | "LEFT" | "RIGHT";

interface Props {
  length: number;
  position: number;
  setPosition: (p: number | ((prev: number) => number)) => void; // you'll wrap this to call change()
  submit: () => void;
  cancel: () => void;
  changeLeft: () => void;
  changeRight: () => void;
}

export const useControls = ({
  length,
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

      switch (ev.data.control) {
        case "TOP":
          setPosition((p) => (p === 0 ? length - 1 : p - 1));
          break;
        case "DOWN":
          setPosition((p) => (p === length - 1 ? 0 : p + 1));
          break;
        case "ENTER":
          submit();
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
  }, [length, position, setPosition, submit, cancel, changeLeft, changeRight]);
};
