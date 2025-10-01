import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { ArrowRight } from "lucide-react";
import { Element } from "@/app/App";

interface Props {
  element: Element;
  isSelected?: boolean;
}

const MenuButton: React.FC<Props> = ({ element, isSelected }) => {
  const { label, description, icon, usable, disableRightArrow, unselectable } =
    element;
  const base = "rounded-[4px] flex items-center p-4 gap-4 justify-between";
  const sel = isSelected
    ? "bg-[#FB9B041A] border border-[#FB9B04]"
    : "bg-[#252525] border border-transparent";

  const unSelectable = unselectable ? "opacity-80" : "";

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
                className={`font-semibold ${
                  isSelected ? "text-[#FB9B04]" : "text-neutral-100"
                }`}
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
              className={`text-sm font-normal ${
                isSelected ? "text-[#FB9B04]" : "text-neutral-200"
              }`}
              dangerouslySetInnerHTML={{ __html: label }}
            />
          )}
        </div>
      </div>

      {usable !== false &&
        disableRightArrow !== true &&
        unselectable !== true && (
          <ArrowRight color={isSelected ? "#FB9B04" : "white"} size="1.6rem" />
        )}
    </div>
  );
};

export default MenuButton;
