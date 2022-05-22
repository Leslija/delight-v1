Config = Config or {}

Config.DEBUG = false -- make sure it's false
-- ============================
--       Server Config
-- ============================
Config.sv_dataClearnigTimer = 1000 * 60 * 60 -- 1000 per sec
Config.sv_maxTableSize = 5000 -- saved entites in table

-- End

-- Let players slaughter every animal without bait
-- only animals spawned by baits give rewards
-- note: in my tests if it's true you need to restart QB-target first and then keep-hunting afterward
Config.SlughterEveryAnimal = false

-- protection system againts players
-- if hunters have this weapons they can't shoot players with it!
Config.ShootingProtection = true
Config.ProtectedWeapons = { 'weapon_musket' }
-- End

Config.BaitCooldown = 1000 * 120 -- 1000 per sec
Config.SpawningTimer = 1000 * 20 -- script will wait until "SpawningTimer" time out then it will spwan animal

Config.AnimalsEatingSpeed = 1000 * 15 -- how much animals will wait in baits location
Config.AnimalsFleeView = 15.0 -- animal Flee range if they get to see players

Config.BaitPlacementSpeed = math.random(1000 * 10, 1000 * 15)
Config.SlaughteringSpeed = math.random(1000 * 15, 1000 * 20)

Config.maxSpawnDistance = 100 -- animal spwan radius from placed bait
Config.minSpawnDistance = 60 -- animal spwan radius from placed bait
Config.spawnAngle = { 0, 360 } -- animal spwan radius from placed bait

Config.animalDespawnRange = 150.0

Config.spawnedAnimalsBlips = true -- when animals spawend it will appears in map with blips on them
Config.AnimalBlip = {
    sprite = 463, -- icon https://docs.fivem.net/docs/game-references/blips/
    color = 5
}
-- 25 , 75 => 25% chance to call police
-- 100 , 0 => 100% chance to call police
-- 0 , 100 => 0% chance to call police
Config.callPoliceChance = { 25, 75 }

Config.llegalHuntingNotification = function(animalCoord)
    TriggerEvent("police:client:policeAlert", animalCoord, "illegal Hunting in area")
    exports['ps-dispatch']:illegal_hunting(animalCoord)
end

-- loot Multiplier settings
Config.activateLootMultiplier = true
Config.maxMultiplier = 10

Config.weaponQualityMultiplier = {
    ['weapon_musket'] = 5,
    ['default'] = 1 -- animal died by anything else
}

Config.boneHitMultiplier = {
    ['head'] = {
        bondeId = 31086,
        multiplier = 5, -- SKEL_Head
        lastHit = true -- headshot => if animal died by shooting this bone once
    },
    ['SKEL_ROOT'] = {
        bondeId = 0,
        multiplier = -1, -- SKEL_ROOT
    },
    ['default'] = {
        multiplier = -1 -- everything else
    }
}

Config.Animals = { {
    model = "a_c_deer",
    -- {legal area spawn chance , illegal area spawn chance}
    spwanRarity = { 70, 0 },
    hash = -664053099,
    -- HOW to use "Loots" element:
    -- { {"ITEMNAME" , Chance , Sell Price} , {"ITEMNAME" , Chance , Sell Price} ,  ....}
    -- note: 100% chance means every time players gonna get that item no RNG involves.
    -- IMPORTANT: script will skip duplicate loots and only use one of them (first one)
    -- script will skip other prices and only uses the first seen value.
    -- IMPORTANT: if you leave the price with nil value players can't sell those items to Vendor.
    Loots = { { "meatdeer", 100, 200 },}
}, {
    model = "a_c_pig",
    spwanRarity = { 0, 0 },
    hash = -1323586730,
    Loots = { { "meatpig", 100, 120 },}
}, {
    model = "a_c_boar",
    spwanRarity = { 0, 50 },
    hash = -832573324,
    Loots = { { "meatpig", 100, 200},}
}, {
    model = "a_c_mtlion",
    spwanRarity = { 0, 10 },
    hash = 307287994,
    Loots = { { "meatlion", 100, 300 },}
}, {
    model = "a_c_cow",
    spwanRarity = { 0, 0 },
    hash = -50684386,
    Loots = { { "meatcow", 100, 80 },}
}, {
    model = "a_c_coyote",
    spwanRarity = { 0, 20 },
    hash = 1682622302,
    Loots = { { "meatcoyote", 100, 250 },}
}, {
    model = "a_c_rabbit_01",
    spwanRarity = { 30, 0 },
    hash = -541762431,
    Loots = { { "meatrabbit", 100, 100 },}
}, {
    model = "a_c_pigeon",
    spwanRarity = { 0, 0 },
    hash = 111281960,
    Loots = { { "meatbird", 100, 90 },}
}, {
    model = "a_c_seagull",
    spwanRarity = { 0, 0 },
    hash = -745300483,
    Loots = { { "meatbird", 100, 90 },}
} }

Config.HuntingArea = { {
    name = "llegal hunting Area",
    coord = vector3(-840.6, 4183.3, 215.29),
    radius = 1000.0,
    llegal = true,
    showBlip = true
}, {
    name = "illlegal hunting Area",
    coord = vector3(870.01, 5158.01, 452.54),
    radius = 500.0,
    llegal = false,
    showBlip = true
} }

Config.SellSpots = { {
    BlipsCoords = vector3(570.34, 2796.46, 42.01),
    name = 'sell hunting stuff!',
    showBlip = true,
    SellerNpc = {
        model = 'csb_chef',
        coords = vector4(570.34, 2796.46, 42.01, 294.27),
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        flag = 1,
        currentpednumber = 0
    }
} }