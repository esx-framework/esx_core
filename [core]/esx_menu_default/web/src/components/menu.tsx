import { useReducer, useState } from "react";
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
  const elements = data.elements;

  const payload = () => ({
    _namespace: data.namespace,
    _name: data.name,
    current: elements[position],
    elements,
  });

  const submit = () => fetchNui("menu_submit", payload());
  const cancel = () =>
    fetchNui("menu_cancel", { _namespace: data.namespace, _name: data.name });
  const change = () => fetchNui("menu_change", payload());

  const stepSelectedSlider = (delta: number) => {
    const el = elements[position];
    if (el?.type !== "slider") return;
    const min = el.min ?? 0;
    const max = el.max ?? 0;
    const cur = (el.value ?? min) + delta;
    el.value = Math.min(max, Math.max(min, cur));
    forceRender();
    change();
  };

  useControls({
    length: elements.length,
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

  return (
    <div className={`absolute ${GetPosition(data.align)}`}>
      <div className="w-[26rem] h-fit bg-[#161616] p-4 rounded-[10px] flex flex-col gap-4">
        <h1
          className="font-bold uppercase text-xl my-2 text-neutral-100"
          dangerouslySetInnerHTML={{ __html: data.title }}
        />
        {elements.map((element, index) => {
          const isSelected = index === position;
          return element.type === "slider" ? (
            <MenuSlider
              key={`slider-${element.name || element.label}-${index}`}
              element={element}
              isSelected={isSelected}
            />
          ) : (
            <MenuButton
              key={`button-${element.name || element.label}-${index}`}
              label={element.label}
              description={element.description}
              icon={element.icon}
              isSelected={isSelected}
            />
          );
        })}
      </div>
    </div>
  );
};

export default Menu;
