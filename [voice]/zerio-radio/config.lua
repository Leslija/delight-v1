Config = {}

Config.Channels = {
    [1] = {
        label = "Police Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [2] = {
        label = "Police Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [3] = {
        label = "Police Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [4] = {
        label = "Police Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [5] = {
        label = "Police Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [6] = {
        label = "Medic Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [7] = {
        label = "Medic Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [8] = {
        label = "Medic Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [9] = {
        label = "Medic Radio",
        jobs = {
            "police",
            "ambulance"
        }
    },
    [10] = {
        label = "Department Radio",
        jobs = {
            "police",
            "ambulance",
            "mechanic"
        }
    }
}

Config.Locale = "en"

-- pma-voice, mumble-voip or saltychat
Config.VoiceScript = "pma-voice"

-- item -> Opens through the Config.Item itemname
-- command -> Opens through the command /radio
-- keybind -> Opens through a button press (Config.Button)
-- custom -> Opens through the event "zerio-radio:client:open"
Config.OpenType = "item"

Config.Item = "radio"
-- Full keybind list exists here, https://docs.fivem.net/docs/game-references/controls/ 
-- (Only important if Config.OpenType is keybind)
Config.Button = 318

-- ONLY FOR MUMBLE-VOIP, has to be the same as the talking key for the animation to work
Config.RadioKey = 137




-- DONT CHANGE THIS IF YOU DONT KNOW WHAT YOU ARE DOING!!!!!!!!!!!!!!!!
Config.EventNames = {
    PlayerLoaded = "QBCore:Client:OnPlayerLoaded"
}

Config.messages = {
    ["turn_radio"] = "You're turn on radio",
    ["joined_to_radio"] = "You're connected to: ",
    ["you_leave"] = "You left the channel.",
}