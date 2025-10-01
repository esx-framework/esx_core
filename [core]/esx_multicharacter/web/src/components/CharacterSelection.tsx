import React, { useState } from 'react';
import { Plus } from 'lucide-react';
import { Character, Locale } from '../types/Character';
import CharacterCard from './CharacterCard';
import CharacterInfo from './CharacterInfo';
import Logo from '../assets/esxLogo.png';
import { fetchNui } from '../utils/fetchNui';

interface CharacterSelectionProps {
  initialCharacters: Character[];
  Candelete: boolean;
  MaxAllowedSlot : number;
  locale : Locale;
}

const CharacterSelection: React.FC<CharacterSelectionProps> = ({ initialCharacters, Candelete, MaxAllowedSlot, locale }) => {
  const [characters, setCharacters] = useState<Character[]>(initialCharacters);
  const [showInfo, setShowInfo] = useState<string | null>(null);
  const [selectedCharacter, setSelectedCharacter] = useState<Character | null>(
    characters.find(char => char.isActive) || null
  );

  const handleSelectCharacter = (id: string) => {
    if (selectedCharacter?.id === id) return;

    const updatedCharacters = characters.map(char => ({
      ...char,
      isActive: char.id === id
    }));
    
    setCharacters(updatedCharacters);
    setSelectedCharacter(updatedCharacters.find(char => char.id === id) || null);
    setShowInfo(null);
    fetchNui('SelectCharacter', {id : id})
  };

  const toggleInfo = (id: string) => {
    setShowInfo(showInfo === id ? null : id);
  };

  const PlayCharacter = () => {
    fetchNui('PlayCharacter')
  }

  const handleCreateCharacter = () => {
    fetchNui('CreateCharacter')
  }

  const handleDeleteCharacter = () => {
    if (!selectedCharacter) return;

    const updatedCharactersRaw = characters.filter(char => char.id !== selectedCharacter.id);

    fetchNui('DeleteCharacter');

    if (updatedCharactersRaw.length > 0) {
      const updatedCharacters = updatedCharactersRaw.map((char, index) => ({
        ...char,
        isActive: index === 0
      }));

      setCharacters(updatedCharacters);
      setSelectedCharacter(updatedCharacters[0]);
      setShowInfo(null);
    } else {
      setCharacters([]);
      setSelectedCharacter(null);
      setShowInfo(null);
      handleCreateCharacter();
    }
  };

  return (
    <div className="h-screen bg-[#161616F2] text-white w-[527px] border-r border-neutral-800 overflow-hidden animate-slideIn flex flex-col">
      <div className="p-4 flex-1 overflow-auto">
        <div className="flex items-center justify-between mb-6">
          <img src={Logo} alt="Logo" className="h-16 ml-1" />
          <h2 className="text-[24px] font-bold tracking-wide text-right flex-1">{locale.title}</h2>
        </div>
        
        <div className="space-y-2">
          {characters.map(character => (
            <div key={character.id}>
              <CharacterCard 
                character={character} 
                onSelect={handleSelectCharacter}
                onInfoClick={toggleInfo}
                showInfo={showInfo === character.id}
                PlayCharacter={PlayCharacter}
              />
              {character.isActive && showInfo === character.id && (
                <CharacterInfo 
                  character={character} 
                  onClose={() => setShowInfo(null)}
                  isAllowedtoDelete={Candelete}
                  PlayCharacter={PlayCharacter}
                  handleDelete={handleDeleteCharacter}
                  locale={locale}
                />
              )}
            </div>
          ))}
        </div>
      </div>
      
      <div className="p-4 border-t border-neutral-800">
        <button 
          className={`w-full h-[70px] ${characters.length >= MaxAllowedSlot ? 'bg-gray-500' : 'bg-[#FB9B04] cursor-pointer hover:bg-orange-600'} text-[#383838] p-3 rounded flex items-center justify-center transition-colors`}
          onClick={handleCreateCharacter}
          disabled={characters.length >= MaxAllowedSlot}  
        >
          <Plus size={24} />
        </button>
      </div>
    </div>
  );
};

export default CharacterSelection;