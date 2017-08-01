using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CitizenFX.Core;
using CitizenFX.Core.UI;
using CitizenFX.Core.Native;

namespace skinchanger
{
    public class Main : BaseScript
    {
        public Main()
        {
            Tick += OnTick;

            EventHandlers["skinchanger:LoadDefaultModel"] += new Action<dynamic>(async (dynamic LoadMale) =>
            {
                await LoadDefaultModel((bool) LoadMale);
 
                TriggerEvent("skinchanger:modelLoaded");
            });

        }

        public async Task LoadDefaultModel(bool LoadMale)
        {

            PedHash CharacterModel;

            if (LoadMale)
                 CharacterModel = PedHash.FreemodeMale01;
            else
                CharacterModel = PedHash.FreemodeFemale01;

            Model characterModel = new Model(CharacterModel);

            characterModel.Request(500);

            if (characterModel.IsInCdImage && characterModel.IsValid)
            {
                while (!characterModel.IsLoaded)
                    await BaseScript.Delay(0);

                Function.Call(Hash.SET_PLAYER_MODEL, Game.Player, characterModel.Hash);
                Function.Call(Hash.SET_PED_DEFAULT_COMPONENT_VARIATION, Game.Player.Character.Handle);
            }

            characterModel.MarkAsNoLongerNeeded();
        }

        public async Task OnTick()
        {

        }
    }
}
