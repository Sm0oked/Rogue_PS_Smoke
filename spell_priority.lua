-- Spell priority configuration for Rogue class
-- NEW: Custom rotation as per latest fighting logic
-- 1. Caltrops (overlap before expiring)
-- 2. Smoke Grenade
-- 3. Poison Trap
-- 4. Shadow Imbuement (always maintain)
-- 5. Shadow Clone (every 5 seconds)
-- 6. Penetrating Shot (spam)
-- 7. Dash and Shadow Step for mobility
-- 8. Dark Shroud (added for additional utility)

local spell_priority = {
    "caltrop",
    "smoke_grenade",
    "poison_trap",
    "shadow_imbuement",
    "shadow_clone",
    "penetrating_shot",
    "dash",
    "shadow_step",
    "dark_shroud"
}

return spell_priority
