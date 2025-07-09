local my_utility = require("my_utility/my_utility")

local boss_buff_manager = {}

-- Spell IDs for the buff spells
local SPELL_IDS = {
    poison_trap = 416528,
    caltrop = 389667,
    smoke_grenade = 356162,
    penetrating_shot = 377137
}

-- Buff IDs (these may need to be updated based on actual game data)
-- Note: These are placeholder IDs. The actual buff effects may not have separate buff IDs
-- Instead, we'll track the spell cooldowns and cast times to ensure proper rotation
local BUFF_IDS = {
    poison_trap_buff = 416528, -- Use spell ID as buff ID (placeholder)
    caltrop_buff = 389667,     -- Use spell ID as buff ID (placeholder)
    smoke_grenade_buff = 356162 -- Use spell ID as buff ID (placeholder)
}

-- Buff rotation configuration
local BUFF_ROTATION = {
    { spell = "poison_trap", buff_id = BUFF_IDS.poison_trap_buff, cooldown = 4.0, priority = 1 },
    { spell = "caltrop", buff_id = BUFF_IDS.caltrop_buff, cooldown = 3.0, priority = 2 },
    { spell = "smoke_grenade", buff_id = BUFF_IDS.smoke_grenade_buff, cooldown = 4.0, priority = 3 }
}

-- Track last cast times for each buff spell
local last_cast_times = {
    poison_trap = 0,
    caltrop = 0,
    smoke_grenade = 0
}

-- Track buff refresh interval (5 seconds as requested)
local BUFF_REFRESH_INTERVAL = 5.0
local last_buff_rotation_time = 0

-- Initialize the boss buff manager
function boss_buff_manager.initialize()
    -- Reset cast times
    for spell_name, _ in pairs(last_cast_times) do
        last_cast_times[spell_name] = 0
    end
    
    last_buff_rotation_time = 0
    console.print("Boss Buff Manager: Initialized")
    return true
end

-- Check if we're in a boss/elite encounter
function boss_buff_manager.is_boss_encounter(target_list, best_target)
    if not target_list or #target_list == 0 then
        return false
    end
    
    -- Only consider actual bosses and champions, not regular elites
    if best_target then
        if best_target:is_boss() or best_target:is_champion() then
            return true
        end
    end
    
    -- Check all targets for boss/champion presence (skip regular elites)
    for _, target in ipairs(target_list) do
        if target:is_boss() or target:is_champion() then
            return true
        end
    end
    
    return false
end

-- Check if a buff spell is ready to cast
function boss_buff_manager.is_buff_spell_ready(spell_name)
    local current_time = get_time_since_inject()
    local spell_config = nil
    
    -- Find the spell configuration
    for _, config in ipairs(BUFF_ROTATION) do
        if config.spell == spell_name then
            spell_config = config
            break
        end
    end
    
    if not spell_config then
        return false
    end
    
    -- Check if spell is off cooldown
    if current_time - last_cast_times[spell_name] < spell_config.cooldown then
        return false
    end
    
    -- Check if spell is ready and affordable
    local spell_id = SPELL_IDS[spell_name]
    if not utility.is_spell_ready(spell_id) then
        return false
    end
    
    if not utility.is_spell_affordable(spell_id) then
        return false
    end
    
    return true
end



-- Cast a buff spell
function boss_buff_manager.cast_buff_spell(spell_name, target_list, target_selector_data, best_target)
    local current_time = get_time_since_inject()
    local spell_id = SPELL_IDS[spell_name]
    
    if not spell_id then
        console.print("Boss Buff Manager: Unknown spell name: " .. spell_name)
        return false
    end
    
    -- Get the spell module
    local spells = {
        poison_trap = require("spells/poison_trap"),
        caltrop = require("spells/caltrop"),
        smoke_grenade = require("spells/smoke_grenade")
    }
    
    local spell_module = spells[spell_name]
    if not spell_module or not spell_module.logics then
        console.print("Boss Buff Manager: Spell module not found: " .. spell_name)
        return false
    end
    
    -- Check if spell is enabled
    if spell_module.menu_elements and not spell_module.menu_elements.main_boolean:get() then
        return false
    end
    
    -- Cast the spell
    local success = spell_module.logics(target_list, target_selector_data, best_target)
    
    if success then
        last_cast_times[spell_name] = current_time
        console.print("Boss Buff Manager: Successfully cast " .. spell_name .. " for buff effect")
        return true
    end
    
    return false
end

-- Main buff rotation logic for boss/elite encounters
function boss_buff_manager.process_boss_buff_rotation(target_list, target_selector_data, best_target)
    local current_time = get_time_since_inject()
    
    -- Check if we're in a boss encounter
    if not boss_buff_manager.is_boss_encounter(target_list, best_target) then
        return false, nil
    end
    
    -- Check if it's time for a new buff rotation (every 5 seconds)
    local time_since_last_rotation = current_time - last_buff_rotation_time
    if time_since_last_rotation < BUFF_REFRESH_INTERVAL then
        return false, nil
    end
    
    console.print("Boss Buff Manager: Starting buff rotation (5s interval)")
    
    -- Check each buff spell in priority order
    for _, spell_config in ipairs(BUFF_ROTATION) do
        local spell_name = spell_config.spell
        
        -- If spell is ready, cast it for buff effect
        if boss_buff_manager.is_buff_spell_ready(spell_name) then
            console.print("Boss Buff Manager: Attempting to cast " .. spell_name .. " for buff effect")
            local success = boss_buff_manager.cast_buff_spell(spell_name, target_list, target_selector_data, best_target)
            if success then
                last_buff_rotation_time = current_time
                return true, spell_name
            else
                console.print("Boss Buff Manager: Failed to cast " .. spell_name)
            end
        else
            console.print("Boss Buff Manager: " .. spell_name .. " not ready (cooldown: " .. 
                         math.max(0, spell_config.cooldown - (current_time - last_cast_times[spell_name])) .. "s remaining)")
        end
    end
    
    -- If no spells were cast but it's time for rotation, update the rotation time
    if time_since_last_rotation >= BUFF_REFRESH_INTERVAL then
        last_buff_rotation_time = current_time
        console.print("Boss Buff Manager: No spells ready, updating rotation time")
    end
    
    return false, nil
end

-- Get debug information about buff status
function boss_buff_manager.get_debug_info()
    local current_time = get_time_since_inject()
    local debug_info = {
        current_time = current_time,
        last_rotation_time = last_buff_rotation_time,
        time_until_next_rotation = math.max(0, BUFF_REFRESH_INTERVAL - (current_time - last_buff_rotation_time)),
        spells = {}
    }
    
    -- Check each spell
    for _, spell_config in ipairs(BUFF_ROTATION) do
        local spell_name = spell_config.spell
        
        local spell_ready = boss_buff_manager.is_buff_spell_ready(spell_name)
        local cooldown_remaining = math.max(0, spell_config.cooldown - (current_time - last_cast_times[spell_name]))
        
        debug_info.spells[spell_name] = {
            spell_ready = spell_ready,
            cooldown_remaining = cooldown_remaining,
            last_cast_time = last_cast_times[spell_name]
        }
    end
    
    return debug_info
end

-- Reset all timers (useful for testing or when switching encounters)
function boss_buff_manager.reset_timers()
    for spell_name, _ in pairs(last_cast_times) do
        last_cast_times[spell_name] = 0
    end
    last_buff_rotation_time = 0
    console.print("Boss Buff Manager: Timers reset")
end

return boss_buff_manager 