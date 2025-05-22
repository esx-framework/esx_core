import React from 'react';
import { Character } from '../types/Character';
import { Icon } from '@iconify/react';

interface CharacterCardProps {
  character: Character;
  onSelect: (id: string) => void;
  onInfoClick: (id: string) => void;
  showInfo: boolean;
  PlayCharacter: () => void;
}

const CharacterCard: React.FC<CharacterCardProps> = ({ 
  character, 
  onSelect, 
  onInfoClick,
  showInfo,
  PlayCharacter
}) => {
  return (
    <>
      <div className='flex justify-center items-center mb-4'>
        <div
          className={`
            h-[65px] w-[462px] cursor-pointer rounded-[5px] overflow-hidden group
            ${character.isActive
              ? ''
              : 'cursor-pointer rounded-[5px] overflow-hidden bg-[#38383880] border-2 border-[#ffffff50] hover:border-[#FFFFFF] hover:bg-[#38383840'}
          `}
          onClick={() => onSelect(character.id)}
        >
          <div 
            className={`
              flex items-center gap-2 transition-all duration-300
              ${character.isActive ? 'text-[#fb9b04]' : 'text-gray-400 group-hover:text-[#FFFFFF]'}
            `}
          >
            <div 
              className={`
                flex items-center rounded-[5px] p-4 overflow-hidden
                ${character.isActive 
                  ? 'h-[65px] bg-[#fb9b0440] border-2 border-[#fb9b04]' 
                  : 'h-[60px]'}
                ${character.isActive && showInfo ? 'w-full' : character.isActive ? 'w-[411px]' : 'w-full'}
              `}
            >
              <Icon
                icon="material-symbols:person-rounded"
                width="30"
                height="30"
                className={`mr-3 flex-shrink-0`}
              />
              <div className="flex justify-center items-center w-full h-full overflow-hidden">
                <span className={`font-bold text-[24px] tracking-wide whitespace-nowrap ${character.isActive ? 'truncate' : 'ml-2'}`}>
                  {character.name}
                </span>
              </div>
            </div>
            {character.isActive && (
              <div className="flex gap-2 flex-shrink-0">
                <button 
                  className={`
                    h-[65px] rounded-[5px] ${character.disabled ? 'bg-gray-500' : 'bg-orange-500 hover:bg-orange-600'} flex text-black items-center justify-center transition-all duration-300
                    ${showInfo ? 'w-0 scale-0 opacity-0 overflow-hidden' : 'w-[65px] h-[65px] scale-100 opacity-100'}
                  `}
                  onClick={(e) => {
                    e.stopPropagation();
                    PlayCharacter();
                  }}
                  disabled={character.disabled}
                >
                  <Icon
                    icon="si:play-fill"
                    width="30"
                    height="30"
                    color="#383838"
                  /> 
                </button>
                <button 
                  className="w-[65px] h-[65px] rounded-[5px] bg-orange-500 text-black flex items-center justify-center transition-colors hover:bg-orange-600 flex-shrink-0"
                  onClick={(e) => {
                    e.stopPropagation();
                    onInfoClick(character.id);
                  }}
                >
                  <Icon
                    icon="bi:info"
                    width="30"
                    height="30"
                    color="#383838"
                  />
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  )
};

export default CharacterCard;
