import { useReducer, useState, useRef, useEffect } from "react";
import { fetchNui } from "@/utils/fetchNui";
import { useControls } from "@/hooks/useControls";
import { MenuData } from "@/app/App";
import MenuButton from "./menu-button";
import MenuSlider from "./menu-slider";
import { GetPosition } from "@/utils/getPosition";

interface Props {
  data: MenuData;
}

const Menu: React.FC<Props> = ({ data }) => {
  const [position, setPosition] = useState(0);
  const [, forceRender] = useReducer((v) => v + 1, 0);
  const itemRefs = useRef<(HTMLDivElement | null)[]>([]);

  const elements = data.elements;

  const payload = () => ({
    _namespace: data.namespace,
    _name: data.name,
    current: elements[position],
    elements,
  });

  const submit = () => {
    const el = elements[position];
    if (el?.usable === false) return;

    fetchNui("menu_submit", payload());
  };

  const cancel = () =>
    fetchNui("menu_cancel", { _namespace: data.namespace, _name: data.name });

  const change = () => {
    const el = elements[position];
    if (el?.usable === false) return;

    fetchNui("menu_change", payload());
  };

  const stepSelectedSlider = (delta: number) => {
    const el = elements[position];

    if (el?.usable === false) return;
    if (el?.type !== "slider") return;

    const options = (el as any).options as string[] | undefined;

    const min = options ? 0 : el.min ?? 0;
    const max = options ? Math.max(0, options.length - 1) : el.max ?? 0;

    const cur = (el.value ?? min) + delta;

    if (cur > max) {
      el.value = min;
    } else if (cur < min) {
      el.value = max;
    } else {
      el.value = cur;
    }

    forceRender();
    change();
  };

  useControls({
    elements,
    position,
    setPosition: (updater) => {
      setPosition(updater);
      change();
    },
    submit,
    cancel,
    changeLeft: () => stepSelectedSlider(-1),
    changeRight: () => stepSelectedSlider(1),
  });

  useEffect(() => {
    const el = itemRefs.current[position];
    if (el) {
      el.scrollIntoView({
        behavior: "smooth",
        block: "center",
        inline: "nearest",
      });
    }
  }, [position]);

  useEffect(() => {
    if (elements[position]?.unselectable) {
      const firstSelectable = elements.findIndex((el) => !el.unselectable);
      if (firstSelectable !== -1) setPosition(firstSelectable);
    }
  }, []);

  return (
    <div className={`absolute ${GetPosition(data.align)}`}>
      <div className="w-[26rem] h-fit max-h-[42rem] bg-[#161616] p-4 rounded-[10px] flex flex-col gap-4">
        <div className="flex justify-between items-center">
          <h1
            className="font-bold uppercase text-xl my-2 text-neutral-100"
            dangerouslySetInnerHTML={{ __html: data.title }}
          />
          <img
            className="h-10"
            src="https://media.discordapp.net/attachments/1370464258382368918/1409914889174257724/esxLogo-sNwPFb_p.png?ex=68af1d10&is=68adcb90&hm=5ce71e8e56c92753b9718188e2c930fb1682d1debae6a63d7ff6b255d2c6ce55&=&format=webp&quality=lossless&width=350&height=350"
            alt=""
          />
        </div>

        <div className="overflow-y-auto h-full flex flex-col gap-4">
          {elements.map((element, index) => {
            const isSelected = index === position;

            return (
              <div
                key={`wrapper-${element.name || element.label}-${index}`}
                ref={(el: HTMLDivElement | null) => {
                  itemRefs.current[index] = el;
                }}
              >
                {element.type === "slider" ? (
                  <MenuSlider element={element} isSelected={isSelected} />
                ) : (
                  <MenuButton element={element} isSelected={isSelected} />
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default Menu;
