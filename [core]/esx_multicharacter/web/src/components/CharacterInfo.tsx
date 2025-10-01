import React from 'react';
import { Info, Cake, User2, Briefcase, Trash2 } from 'lucide-react';
import { Character, Locale } from '../types/Character';
import { Icon } from '@iconify/react';

interface CharacterInfoProps {
  character: Character;
  onClose: () => void;
  isAllowedtoDelete: boolean;
  PlayCharacter : () => void;
  handleDelete: () => void;
  locale: Locale;
}

const CharacterInfo: React.FC<CharacterInfoProps> = ({ character, onClose, isAllowedtoDelete , PlayCharacter, handleDelete, locale}) => {
  if (!character) return null;

  return (
    <div className='flex justify-center items-center'>
      <div className="w-[462px] bg-neutral-900 rounded-b-lg p-4 animate-slideDown">
        <div className="mb-4">
          <h3 className="text-gray-400 uppercase text-sm mb-3 font-semibold flex items-center">
            <Info className="mr-2" size={16} /> {locale.char_info_title}
          </h3>
          
          <div className="grid grid-cols-2 gap-2">
            <div className="bg-neutral-800 p-3 rounded flex items-center">
              <Cake className="mr-3 text-white" size={18} />
              <div className="flex justify-center w-full">
                <span className="text-white mr-1">{character.birthDate}</span>
              </div>
            </div>
            <div className="bg-neutral-800 p-3 rounded flex items-center">
              <User2 className="mr-3 text-white-400" size={18} />
              <div className="flex justify-center w-full">
                <span className="text-white mr-6">{character.gender}</span>
              </div>
            </div>
            <div className="bg-neutral-800 p-3 rounded flex items-center col-span-2">
              <Briefcase className="mr-3 text-white-400" size={18} />
              <div className="flex justify-center w-full">
                <span className="text-white mr-6">{character.occupation}</span>
              </div>
            </div>
          </div>
        </div>

        <div className="flex gap-2">
          <button
            className={`flex-1 ${character.disabled ? 'bg-gray-500' : 'bg-neutral-800 hover:bg-[#FFA31A] hover:text-[#383838]'} text-white py-2 px-4 font-semibold text-[16px] rounded-[5px] flex items-center justify-center transition-colors`}
            onClick={PlayCharacter}
            disabled={character.disabled}
          >
            <Icon icon="flowbite:play-solid" width={23} height={23} className="mr-2" />
            {locale.play}
          </button>
          {isAllowedtoDelete && (
            <button
              className="bg-neutral-800 text-white p-2 rounded hover:bg-red-900 transition-colors"
              onClick={handleDelete}
            >
              <Trash2 size={18} />
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default CharacterInfo;