/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

import CharacterSelection from "./components/CharacterSelection";
import { useState, useEffect } from "react";
import { useNuiEvent } from "./utils/useNuiEvent";
import { Character, Locale } from "./types/Character";
import { fetchNui } from "./utils/fetchNui";

function App() {
  const [isVisible, setIsVisible] = useState<boolean>(false);
  const [characters, setCharacters] = useState<Character[]>([]);
  const [Candelete, setCandelete] = useState<boolean>(false);
  const [MaxAllowedSlot, setMaxAllowedSlot] = useState<number>(0);
  const [locale, setLocale] = useState<Locale>({
    char_info_title: "",
    play: "",
    title: "",
  });

  useEffect(() => {
    fetchNui("nuiReady");
  }, []);

  useNuiEvent("ToggleMulticharacter", (data: any) => {
    if (data.show) {
      const validCharacters = Object.values(data.Characters || {}).filter(
        (char: any) => char && char.id != null
      ).sort((left: any, right: any) => Number(left.id) - Number(right.id));
      const parsedCharacters: Character[] = validCharacters.map(
        (char: any, index: number) => ({
          id: char.id.toString(),
          name: `${char.firstname} ${char.lastname}`,
          birthDate: char.dateofbirth,
          gender: char.sex,
          occupation: char.job,
          disabled: char.disabled === true || char.disabled === 1 || char.disabled === "1",
          isActive: index === 0,
        })
      );

      setIsVisible(true);
      setCharacters(parsedCharacters);
      setCandelete(data.CanDelete);
      setMaxAllowedSlot(data.AllowedSlot);
      setLocale(data.Locale);
    } else {
      setIsVisible(false);
      setCharacters([]);
    }
  });

  return (
    isVisible && (
      <CharacterSelection
        initialCharacters={characters}
        Candelete={Candelete}
        MaxAllowedSlot={MaxAllowedSlot}
        locale={locale}
      />
    )
  );
}

export default App;
