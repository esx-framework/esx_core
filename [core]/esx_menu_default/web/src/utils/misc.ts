// Will return whether the current environment is in a regular browser

import { useEffect, useState } from "react";

// and not CEF
export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

// Basic no operation function
export const noop = () => { };

export const IsInputFocused = () => {
    const [isFocused, setIsFocused] = useState(false);

    useEffect(() => {
        const checkFocused = () => {
            const element = document.activeElement as HTMLElement | null;

            if (element) {
                setIsFocused(
                    element.tagName == "INPUT" ||
                    element.tagName == "TEXTAREA" ||
                    element.tagName == "SELECT"
                );
            } else {
                setIsFocused(false);
            }
        };

        document.addEventListener("focusin", checkFocused);
        document.addEventListener("focusout", checkFocused);

        checkFocused();

        return () => {
            document.removeEventListener("focusin", checkFocused);
            document.removeEventListener("focusout", checkFocused);
        };
    }, []);

    return isFocused;
};