import React, { useEffect, useState } from "react";
import { useNuiEvent } from "@/hooks/useNuiEvent";
import { AnimatePresence, HTMLMotionProps, motion } from "framer-motion";
import Menu from "@/components/menu";
import { IconProp } from "@fortawesome/fontawesome-svg-core";

export interface Element {
    label: string;
    name: string;
    description?: string;
    icon?: IconProp;
    value?: number;
    type?: "slider";
    min: number;
    max: number;
    options?: string[];
    usable?: boolean;
    unselectable?: boolean;
    disableRightArrow?: boolean;
}

export interface MenuData {
    title: string;
    namespace: string;
    name: string;
    align: "top-left" | "top-right" | "bottom-left" | "bottom-right" | "center" | "left-center" | "right-center";
    elements: Element[];
}

export interface CloseData {
    namespace: string;
    name: string;
}

const visibility_animation: HTMLMotionProps<"div"> = {
    initial: { opacity: 0 },
    animate: {
        opacity: 1,
        transition: { duration: 0.3, ease: [0, 0, 0.2, 1] },
    },
    exit: {
        opacity: 0,
        transition: { duration: 0.3, ease: [0.4, 0, 1, 1] },
    },
};

const App: React.FC = () => {
    const [_, setCreatedMenus] = useState<Record<string, MenuData[]>>({});

    const [currentMenu, setCurrentMenu] = useState<MenuData | null>(null);

    useNuiEvent<MenuData>("openMenu", (data) => {
        setCreatedMenus((prev) => {
            const list = prev[data.namespace] ?? [];
            return {
                ...prev,
                [data.namespace]: [...list, data],
            };
        });

        setCurrentMenu(data);
    });

    useNuiEvent<CloseData>("closeMenu", ({ namespace, name }) => {
        setCreatedMenus((prev) => {
            const list = prev[namespace] ?? [];
            const nextList = list.filter((m) => m.name !== name);

            const next = { ...prev };
            if (nextList.length > 0) {
                next[namespace] = nextList;
            } else {
                delete next[namespace];
            }

            const all = Object.values(next).flat();
            setCurrentMenu(all.length > 0 ? all[all.length - 1] : null);

            return next;
        });
    });

    return (
        <AnimatePresence mode="wait">
            {currentMenu && (
                <motion.div key={`${currentMenu.namespace}:${currentMenu.name}`} {...visibility_animation}>
                    <Menu data={currentMenu} />
                </motion.div>
            )}
        </AnimatePresence>
    );
};

export default App;
