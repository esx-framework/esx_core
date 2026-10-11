/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

import React, { useEffect, useRef, useState } from 'react';
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
  const pending = useRef(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedCharacter, setSelectedCharacter] = useState<Character | null>(
    characters.find(char => char.isActive) || null
  );

  useEffect(() => {
    setCharacters(initialCharacters);
    setSelectedCharacter(initialCharacters.find(char => char.isActive) || initialCharacters[0] || null);
    setShowInfo(null);
  }, [initialCharacters]);

  const runAction = async (event: string, id?: string) => {
    if (pending.current) return false;
    pending.current = true;
    setBusy(true);
    setError(null);
    try {
      const result = await fetchNui<{ success: boolean }>(event, id ? { id } : {});

      if (!result?.success) {
        setError(locale.action_failed || 'The action could not be completed. Please try again.');
        return false;
      }

      return true;
    } catch {
      setError(locale.action_failed || 'The action could not be completed. Please try again.');
      
      return false;
    } finally {
      pending.current = false;
      setBusy(false);
    }
  };

  const handleSelectCharacter = async (id: string) => {
    if (pending.current || selectedCharacter?.id === id) return;
    if (!await runAction('SelectCharacter', id)) return;

    const updatedCharacters = characters.map(char => ({
      ...char,
      isActive: char.id === id
    }));
    
    setCharacters(updatedCharacters);
    setSelectedCharacter(updatedCharacters.find(char => char.id === id) || null);
    setShowInfo(null);
  };

  const toggleInfo = (id: string) => {
    setShowInfo(showInfo === id ? null : id);
  };

  const PlayCharacter = () => {
    if (selectedCharacter && !selectedCharacter.disabled) {
      void runAction('PlayCharacter', selectedCharacter.id);
    }
  }

  const handleCreateCharacter = () => {
    void runAction('CreateCharacter');
  }

  const handleDeleteCharacter = () => {
    if (!selectedCharacter || !Candelete) return;
    void runAction('DeleteCharacter', selectedCharacter.id);
  };

  return (
    <div className="h-screen bg-[#161616F2] text-white w-[527px] border-r border-neutral-800 overflow-hidden animate-slideIn flex flex-col">
      <div className="p-4 flex-1 overflow-auto">
        <div className="flex items-center justify-between mb-6">
          <img src={Logo} alt="Logo" className="h-16 ml-1" />
          <h2 className="text-[24px] font-bold tracking-wide text-right flex-1">{locale.title}</h2>
        </div>
        
        <div className="space-y-2">
          {busy && <p role="status" className="text-gray-300 text-sm">{locale.action_pending || 'Please wait...'}</p>}
          {error && <p role="alert" className="text-red-400 text-sm">{error}</p>}
          {characters.map(character => (
            <div key={character.id}>
              <CharacterCard 
                character={character} 
                onSelect={handleSelectCharacter}
                onInfoClick={toggleInfo}
                showInfo={showInfo === character.id}
                PlayCharacter={PlayCharacter}
                busy={busy}
              />
              {character.isActive && showInfo === character.id && (
                <CharacterInfo 
                  character={character} 
                  onClose={() => setShowInfo(null)}
                  isAllowedtoDelete={Candelete}
                  PlayCharacter={PlayCharacter}
                  handleDelete={handleDeleteCharacter}
                  locale={locale}
                  busy={busy}
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
          disabled={busy || characters.length >= MaxAllowedSlot}
        >
          <Plus size={24} />
        </button>
      </div>
    </div>
  );
};

export default CharacterSelection;
