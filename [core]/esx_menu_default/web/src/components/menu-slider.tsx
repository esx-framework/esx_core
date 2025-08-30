import { ChevronLeft, ChevronRight } from "lucide-react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { Element } from "@/app/App";

interface Props {
  element: Element;
  isSelected?: boolean;
}

const MenuSlider: React.FC<Props> = ({ element, isSelected }) => {
  const { label, description, icon, unselectable } = element;

  const options = (element as Element).options as string[] | undefined;

  const min = options ? 0 : element.min ?? 0;
  const max = options ? Math.max(0, options.length - 1) : element.max ?? 0;

  const rawValue = element.value ?? min;
  const value = Math.min(max, Math.max(min, rawValue));

  const base = "rounded-[4px] flex items-center p-4 gap-4 justify-between";
  const sel = isSelected
    ? "bg-[#FB9B041A] border border-[#FB9B04]"
    : "bg-[#252525] border border-transparent";
  const text = isSelected ? "text-[#FB9B04]" : "text-neutral-100";

  const unSelectable = unselectable ? "opacity-50" : ""

  return (
    <div className={`${base} ${sel} ${unSelectable}`}>
      <div className="flex items-center gap-4">
        {icon && (
          <FontAwesomeIcon
            className="size-6"
            icon={icon}
            color={isSelected ? "#FB9B04" : undefined}
          />
        )}
        <div className="flex flex-col justify-center">
          {description ? (
            <>
              <p
                className={`font-semibold ${text}`}
                dangerouslySetInnerHTML={{ __html: label }}
              />
              <p
                className={`text-sm font-normal ${
                  isSelected ? "text-[#FB9B04]" : "text-neutral-200"
                }`}
                dangerouslySetInnerHTML={{ __html: description }}
              />
            </>
          ) : (
            <p
              className={`text-sm font-normal ${text}`}
              dangerouslySetInnerHTML={{ __html: label }}
            />
          )}
        </div>
      </div>

      <div className="flex items-center gap-2 select-none">
        <ChevronLeft color={isSelected ? "#FB9B04" : "white"} />
        {options ? (
          <span
            className={`${text} whitespace-nowrap overflow-hidden text-ellipsis`}
            dangerouslySetInnerHTML={{ __html: options[value] ?? "" }}
          />
        ) : (
          <span className={`${text} w-6 text-center`}>{value}</span>
        )}
        <ChevronRight color={isSelected ? "#FB9B04" : "white"} />
      </div>
    </div>
  );
};

export default MenuSlider;
