local my_utility = require("my_utility/my_utility")
local my_target_selector = require("my_utility/my_target_selector")
local spell_data = require("my_utility/spell_data")
local spell_priority = require("spell_priority")
local menu = require("menu")
local enhancements_manager = require("my_utility/enhancements_manager")

-- Add fallback checks for undefined variables at the top of the file
local function safe_get_menu_element(element, fallback)
    if element and type(element.get) == "function" then
        return element:get()
    end
    return fallback
end

local function safe_get_player_position()
    local pos = get_player_position()
    if not pos then
        -- Return a default position if player position is nil
        return vec3.new(0, 0, 0)
    end
    return pos
end

local function safe_get_cursor_position()
    local pos = get_cursor_position()
    if not pos then
        -- Return a default position if cursor position is nil
        return vec3.new(0, 0, 0)
    end
    return pos
end

local function safe_get_local_player()
    local player = get_local_player()
    if not player then
        return nil
    end
    return player
end

-- Add fallback for utility functions that might not exist
local function safe_utility_is_spell_ready(spell_id)
    if utility and type(utility.is_spell_ready) == "function" then
        return utility.is_spell_ready(spell_id)
    end
    return false
end

local function safe_utility_is_spell_affordable(spell_id)
    if utility and type(utility.is_spell_affordable) == "function" then
        return utility.is_spell_affordable(spell_id)
    end
    return false
end

local function safe_utility_use_health_potion()
    if utility and type(utility.use_health_potion) == "function" then
        return utility.use_health_potion()
    end
    return false
end

local function safe_utility_is_point_walkeable(position)
    if utility and type(utility.is_point_walkeable) == "function" then
        return utility.is_point_walkeable(position)
    end
    return true -- Default to walkable if function doesn't exist
end

local function safe_utility_get_units_inside_circle_list(position, radius)
    if utility and type(utility.get_units_inside_circle_list) == "function" then
        return utility.get_units_inside_circle_list(position, radius)
    end
    return {}
end

local function safe_utility_get_units_inside_rectangle_list(start_pos, end_pos, width)
    if utility and type(utility.get_units_inside_rectangle_list) == "function" then
        return utility.get_units_inside_rectangle_list(start_pos, end_pos, width)
    end
    return {}
end

local function safe_cast_spell_position(spell_id, position, delay)
    if cast_spell and type(cast_spell.position) == "function" then
        return cast_spell.position(spell_id, position, delay or 0.0)
    end
    return false
end

local function safe_pathfinder_move_to_cpathfinder(position)
    if pathfinder and type(pathfinder.move_to_cpathfinder) == "function" then
        return pathfinder.move_to_cpathfinder(position)
    end
    return false
end

local function safe_target_selector_get_target_closer(position, range)
    if target_selector and type(target_selector.get_target_closer) == "function" then
        return target_selector.get_target_closer(position, range)
    end
    return nil
end

local function safe_target_selector_is_wall_collision(player_pos, target, distance)
    if target_selector and type(target_selector.is_wall_collision) == "function" then
        return target_selector.is_wall_collision(player_pos, target, distance)
    end
    return false
end

local function safe_auto_play_is_active()
    if auto_play and type(auto_play.is_active) == "function" then
        return auto_play.is_active()
    end
    return false
end

local function safe_auto_play_get_objective()
    if auto_play and type(auto_play.get_objective) == "function" then
        return auto_play.get_objective()
    end
    return nil
end

local function safe_loot_manager_get_all_items_chest_sort_by_distance()
    if loot_manager and type(loot_manager.get_all_items_chest_sort_by_distance) == "function" then
        return loot_manager.get_all_items_chest_sort_by_distance()
    end
    return {}
end

local function safe_loot_manager_is_lootable_item(item, is_gold, is_potion)
    if loot_manager and type(loot_manager.is_lootable_item) == "function" then
        return loot_manager.is_lootable_item(item, is_gold or false, is_potion or false)
    end
    return false
end

local function safe_loot_manager_loot_item_orbwalker(item)
    if loot_manager and type(loot_manager.loot_item_orbwalker) == "function" then
        return loot_manager.loot_item_orbwalker(item)
    end
    return false
end

local function safe_loot_manager_loot_item(item, is_gold, is_potion)
    if loot_manager and type(loot_manager.loot_item) == "function" then
        return loot_manager.loot_item(item, is_gold or false, is_potion or false)
    end
    return false
end

local function safe_loot_manager_is_potion_necessary()
    if loot_manager and type(loot_manager.is_potion_necessary) == "function" then
        return loot_manager.is_potion_necessary()
    end
    return false
end

local function safe_loot_manager_is_potion(item)
    if loot_manager and type(loot_manager.is_potion) == "function" then
        return loot_manager.is_potion(item)
    end
    return false
end

local function safe_loot_manager_is_gold(item)
    if loot_manager and type(loot_manager.is_gold) == "function" then
        return loot_manager.is_gold(item)
    end
    return false
end

local function safe_loot_manager_is_obols(item)
    if loot_manager and type(loot_manager.is_obols) == "function" then
        return loot_manager.is_obols(item)
    end
    return false
end

local function safe_actors_manager_get_enemy_npcs()
    if actors_manager and type(actors_manager.get_enemy_npcs) == "function" then
        return actors_manager.get_enemy_npcs()
    end
    return {}
end

local function safe_prediction_get_future_unit_position(unit, time)
    if prediction and type(prediction.get_future_unit_position) == "function" then
        return prediction.get_future_unit_position(unit, time)
    end
    return unit and unit:get_position() or vec3.new(0, 0, 0)
end

local function safe_graphics_w2s(position)
    if graphics and type(graphics.w2s) == "function" then
        return graphics.w2s(position)
    end
    return vec3.new(0, 0, 0)
end

local function safe_graphics_circle_3d(position, radius, color, thickness, segments)
    if graphics and type(graphics.circle_3d) == "function" then
        graphics.circle_3d(position, radius, color, thickness or 1.0, segments or 36)
    end
end

-- Add fallback for evade functions
local function safe_evade_is_dangerous_position(position)
    if evade and type(evade.is_dangerous_position) == "function" then
        return evade.is_dangerous_position(position)
    end
    return false
end

-- Add fallback for orbwalker functions
local function safe_orbwalker_get_orb_mode()
    if orbwalker and type(orbwalker.get_orb_mode) == "function" then
        return orbwalker.get_orb_mode()
    end
    return 0 -- Default to none mode
end

local function safe_orbwalker_set_block_movement(block)
    if orbwalker and type(orbwalker.set_block_movement) == "function" then
        orbwalker.set_block_movement(block)
    end
end

local function safe_orbwalker_set_clear_toggle(clear)
    if orbwalker and type(orbwalker.set_clear_toggle) == "function" then
        orbwalker.set_clear_toggle(clear)
    end
end

-- Add fallback for console functions
local function safe_console_print(message)
    if console and type(console.print) == "function" then
        console.print(message)
    end
end

-- Add fallback for get_time_since_inject
local function safe_get_time_since_inject()
    if get_time_since_inject then
        return get_time_since_inject()
    end
    return 0
end

-- Add fallback for get_hash
local function safe_get_hash(key)
    if get_hash then
        return get_hash(key)
    end
    return 0
end

-- Add fallback for get_equipped_spell_ids
local function safe_get_equipped_spell_ids()
    if get_equipped_spell_ids then
        return get_equipped_spell_ids()
    end
    return {}
end

-- Add fallback for on_render_menu
local function safe_on_render_menu(callback)
    if on_render_menu then
        on_render_menu(callback)
    end
end

-- Add fallback for on_update
local function safe_on_update(callback)
    if on_update then
        on_update(callback)
    end
end

-- Add fallback for on_render
local function safe_on_render(callback)
    if on_render then
        on_render(callback)
    end
end

local local_player = safe_get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_rogue = character_id == 3;
if not is_rogue then
 return
end;

-- orbwalker settings
safe_orbwalker_set_block_movement(true);
safe_orbwalker_set_clear_toggle(true);

local spells =
{
    concealment             = require("spells/concealment"),
    caltrop                 = require("spells/caltrop"),
    puncture                = require("spells/puncture"),
    heartseeker             = require("spells/heartseeker"),
    forcefull_arrow         = require("spells/forcefull_arrow"),
    blade_shift             = require("spells/blade_shift"),
    invigorating_strike     = require("spells/invigorating_strike"),
    twisting_blade          = require("spells/twisting_blade"),
    barrage                 = require("spells/barrage"),
    rapid_fire              = require("spells/rapid_fire"),
    flurry                  = require("spells/flurry"),
    penetrating_shot        = require("spells/penetrating_shot"),
    shadow_step             = require("spells/shadow_step"),
    smoke_grenade           = require("spells/smoke_grenade"),
    poison_trap             = require("spells/poison_trap"),
    dark_shroud             = require("spells/dark_shroud"),
    shadow_imbuement        = require("spells/shadow_imbuement"),
    poison_imbuement        = require("spells/poison_imbuement"),
    cold_imbuement          = require("spells/cold_imbuement"),
    shadow_clone            = require("spells/shadow_clone"),
    death_trap              = require("spells/death_trap"),
    rain_of_arrows          = require("spells/rain_of_arrows"),
    dance_of_knives         = require("spells/dance_of_knives"),
    evade                  = require("spells/evade"),
    dash                   = require("spells/dash"),
}

-- Add tracking variables for spell timings and cooldowns
if not _G.last_death_trap_time then _G.last_death_trap_time = 0 end
if not _G.last_concealment_time then _G.last_concealment_time = 0 end
if not _G.last_heartseeker_cast_time then _G.last_heartseeker_cast_time = 0 end
if not _G.last_shadowstep_time then _G.last_shadowstep_time = 0 end
if not _G.last_health_potion_time then _G.last_health_potion_time = 0 end
if not _G.last_dash_time then _G.last_dash_time = 0 end

-- Variables for casting
local can_move = 0.0
local cast_end_time = 0.0
local cast_delay = 0.2

-- Add global enemy blacklist at the top of the file, near the other globals
if not _G.blacklisted_enemies then _G.blacklisted_enemies = {} end

-- Add these global variables near the other globals
if not _G.last_position then _G.last_position = nil end
if not _G.time_at_position then _G.time_at_position = 0 end
if not _G.stuck_detection_time then _G.stuck_detection_time = 3.0 end -- seconds to consider player stuck

safe_on_render_menu(function()
    if not menu.menu_elements.main_tree:push("Rogue: PS | Smoke Edition") then
        return
    end

    menu.menu_elements.main_boolean:render("Enable Plugin", "")
    if safe_get_menu_element(menu.menu_elements.main_boolean, false) == false then
        menu.menu_elements.main_tree:pop()
        return
    end

    local options = {"Melee", "Ranged"}
    menu.menu_elements.mode:render("Mode", options, "")
    menu.menu_elements.evade_cooldown:render("Evade Cooldown", "")

    if menu.menu_elements.settings_tree:push("Settings") then
        menu.menu_elements.enemy_count_threshold:render("Minimum Enemy Count",
            "       Minimum number of enemies in Enemy Evaluation Radius to consider them for targeting")
        menu.menu_elements.targeting_refresh_interval:render("Targeting Refresh Interval",
            "       Time between target checks in seconds       ", 1)
        menu.menu_elements.max_targeting_range:render("Max Targeting Range",
            "       Maximum range for targeting       ")
        menu.menu_elements.min_enemy_distance:render("Minimum Enemy Distance",
            "       Minimum distance to enemies before targeting them       ", 1)
        menu.menu_elements.cursor_targeting_radius:render("Cursor Targeting Radius",
            "       Area size for selecting target around the cursor       ", 1)
        menu.menu_elements.cursor_targeting_angle:render("Cursor Targeting Angle",
            "       Maximum angle between cursor and target to cast targetted spells       ")
        menu.menu_elements.best_target_evaluation_radius:render("Enemy Evaluation Radius",
            "       Area size around an enemy to evaluate if it's the best target       \n" ..
            "       If you use huge aoe spells, you should increase this value       \n" ..
            "       Size is displayed with debug/display targets with faded white circles       ", 1)

        menu.menu_elements.enable_enemy_blacklist:render("Enable Enemy Blacklisting",
            "Temporarily avoid targeting enemies that have been skipped - helps prevent getting stuck on elites in pit")
        if safe_get_menu_element(menu.menu_elements.enable_enemy_blacklist, false) then
            menu.menu_elements.blacklist_elite_enemies:render("Blacklist Elite Enemies",
                "Prioritize blacklisting elite enemies that are causing navigation problems")
            menu.menu_elements.blacklist_duration:render("Blacklist Duration", 
                "How long (in seconds) to avoid targeting a blacklisted enemy", 1)
        end

        menu.menu_elements.custom_enemy_weights:render("Custom Enemy Weights",
            "Enable custom enemy weights for determining best targets within Enemy Evaluation Radius")
        if safe_get_menu_element(menu.menu_elements.custom_enemy_weights, false) then
            if menu.menu_elements.custom_enemy_weights_tree:push("Custom Enemy Weights") then
                menu.menu_elements.enemy_weight_normal:render("Normal Enemy Weight",
                    "Weighing score for normal enemies - default is 2")
                menu.menu_elements.enemy_weight_elite:render("Elite Enemy Weight",
                    "Weighing score for elite enemies - default is 10")
                menu.menu_elements.enemy_weight_champion:render("Champion Enemy Weight",
                    "Weighing score for champion enemies - default is 15")
                menu.menu_elements.enemy_weight_boss:render("Boss Enemy Weight",
                    "Weighing score for boss enemies - default is 50")
                menu.menu_elements.enemy_weight_damage_resistance:render("Damage Resistance Aura Enemy Weight",
                    "Weighing score for enemies with damage resistance aura - default is 25")
                menu.menu_elements.custom_enemy_weights_tree:pop()
            end
        end

        menu.menu_elements.enable_debug:render("Enable Debug", "")
        if safe_get_menu_element(menu.menu_elements.enable_debug, false) then
            if menu.menu_elements.debug_tree:push("Debug") then
                menu.menu_elements.draw_targets:render("Display Targets", menu.draw_targets_description)
                menu.menu_elements.draw_max_range:render("Display Max Range",
                    "Draw max range circle")
                menu.menu_elements.draw_melee_range:render("Display Melee Range",
                    "Draw melee range circle")
                menu.menu_elements.draw_enemy_circles:render("Display Enemy Circles",
                    "Draw enemy circles")
                menu.menu_elements.draw_cursor_target:render("Display Cursor Target", menu.cursor_target_description)
                menu.menu_elements.debug_tree:pop()
            end
        end

        menu.menu_elements.settings_tree:pop()
    end

    local equipped_spells = safe_get_equipped_spell_ids()
    table.insert(equipped_spells, spell_data.evade.spell_id) -- add evade to the list
    
    -- Create a lookup table for equipped spells
    local equipped_lookup = {}
    for _, spell_id in ipairs(equipped_spells) do
        -- Check each spell in spell_data to find matching spell_id
        for spell_name, data in pairs(spell_data) do
            if data.spell_id == spell_id then
                equipped_lookup[spell_name] = true
                break
            end
        end
    end

    if menu.menu_elements.spells_tree:push("Equipped Spells") then
        -- Display spells in priority order, but only if they're equipped
        for _, spell_name in ipairs(spell_priority) do
            if equipped_lookup[spell_name] and spells[spell_name] then
                local spell = spells[spell_name]
                if spell and spell.menu then
                    spell.menu()
                end
            end
        end
        menu.menu_elements.spells_tree:pop()
    end

    if menu.menu_elements.disabled_spells_tree:push("Inactive Spells") then
        for _, spell_name in ipairs(spell_priority) do
            local spell = spells[spell_name]
            if spell and spell.menu and (not equipped_lookup[spell_name] or 
               (spell.menu_elements and not safe_get_menu_element(spell.menu_elements.main_boolean, false))) then
                spell.menu()
            end
        end
        menu.menu_elements.disabled_spells_tree:pop()
    end

    -- Add enhancements menu
    enhancements_manager.render_enhancements_menu(menu.menu_elements)

    menu.menu_elements.main_tree:pop();
end)

-- Targets
local best_ranged_target = nil
local best_ranged_target_visible = nil
local best_melee_target = nil
local best_melee_target_visible = nil
local closest_target = nil
local closest_target_visible = nil
local best_cursor_target = nil
local closest_cursor_target = nil
local closest_cursor_target_angle = 0

-- Target scores
local ranged_max_score = 0
local ranged_max_score_visible = 0
local melee_max_score = 0
local melee_max_score_visible = 0
local cursor_max_score = 0

-- Targeting settings
local max_targeting_range = menu.menu_elements.max_targeting_range:get()
local collision_table = { true, 1 } -- collision width
local floor_table = { true, 5.0 }   -- floor height
local angle_table = { false, 90.0 } -- max angle

-- Cache for heavy function results
local next_target_update_time = 0.0 -- Time of next target evaluation
local next_cast_time = 0.0          -- Time of next possible cast
local targeting_refresh_interval = menu.menu_elements.targeting_refresh_interval:get()

-- Default enemy weights for different enemy types
local normal_monster_value = 2
local elite_value = 10
local champion_value = 15
local boss_value = 50
local damage_resistance_value = 25

-- Apply custom weights if enabled
if menu.menu_elements.custom_enemy_weights:get() then
    normal_monster_value = menu.menu_elements.enemy_weight_normal:get()
    elite_value = menu.menu_elements.enemy_weight_elite:get()
    champion_value = menu.menu_elements.enemy_weight_champion:get()
    boss_value = menu.menu_elements.enemy_weight_boss:get()
    damage_resistance_value = menu.menu_elements.enemy_weight_damage_resistance:get()
end

local target_selector_data_all = nil

-- Enhanced target evaluation function
local function evaluate_targets(target_list, melee_range)
    local best_ranged_target = nil
    local best_melee_target = nil
    local best_cursor_target = nil
    local closest_cursor_target = nil
    local closest_cursor_target_angle = 0

    local ranged_max_score = 0
    local melee_max_score = 0
    local cursor_max_score = 0

    local melee_range_sqr = melee_range * melee_range
    local player_position = get_player_position()
    local cursor_position = get_cursor_position()
    local cursor_targeting_radius = menu.menu_elements.cursor_targeting_radius:get()
    local cursor_targeting_radius_sqr = cursor_targeting_radius * cursor_targeting_radius
    local best_target_evaluation_radius = menu.menu_elements.best_target_evaluation_radius:get()
    local cursor_targeting_angle = menu.menu_elements.cursor_targeting_angle:get()
    local enemy_count_threshold = menu.menu_elements.enemy_count_threshold:get()
    local min_enemy_distance = menu.menu_elements.min_enemy_distance:get()
    local min_enemy_distance_sqr = min_enemy_distance * min_enemy_distance
    local closest_cursor_distance_sqr = math.huge
    
    -- Clean up expired blacklisted enemies
    local current_time = get_time_since_inject()
    if menu.menu_elements.enable_enemy_blacklist:get() then
        for id, data in pairs(_G.blacklisted_enemies) do
            if current_time > data.expiry_time then
                _G.blacklisted_enemies[id] = nil
                console.print("Removed enemy " .. id .. " from blacklist (expired)")
            end
        end
    end

    -- First check if we have enough enemies to satisfy the minimum enemy count threshold
    local total_valid_enemies = 0
    local has_boss_enemy = false
    for _, unit in ipairs(target_list) do
        total_valid_enemies = total_valid_enemies + 1
        if unit:is_boss() then
            has_boss_enemy = true
        end
    end
    
    -- If we don't have enough valid enemies total and no boss is present, return empty targets
    if total_valid_enemies < enemy_count_threshold and not has_boss_enemy then
        return {
            best_ranged_target = nil,
            best_melee_target = nil,
            best_cursor_target = nil,
            closest_cursor_target = nil,
            closest_cursor_target_angle = 0,
            ranged_max_score = 0,
            melee_max_score = 0,
            cursor_max_score = 0
        }
    end

    for _, unit in ipairs(target_list) do
        local unit_id = nil
        pcall(function() unit_id = unit:get_id() or tostring(unit) end)
        
        -- Skip blacklisted enemies
        if menu.menu_elements.enable_enemy_blacklist:get() and unit_id and _G.blacklisted_enemies[unit_id] then
            console.print("Skipping blacklisted enemy: " .. unit_id)
            goto continue
        end
        
        local unit_health = unit:get_current_health()
        local unit_name = unit:get_skin_name()
        local unit_position = unit:get_position()
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position)
        local cursor_distance_sqr = unit_position:squared_dist_to_ignore_z(cursor_position)
        local buffs = unit:get_buffs()

        -- Skip enemies that are too close based on min_enemy_distance setting
        if distance_sqr < min_enemy_distance_sqr then
            -- If we're skipping an elite enemy and blacklisting is enabled, add it to the blacklist
            if menu.menu_elements.enable_enemy_blacklist:get() and 
               menu.menu_elements.blacklist_elite_enemies:get() and
               unit:is_elite() and unit_id then
                local blacklist_duration = menu.menu_elements.blacklist_duration:get()
                _G.blacklisted_enemies[unit_id] = {
                    expiry_time = current_time + blacklist_duration,
                    position = unit_position,
                    is_elite = unit:is_elite(),
                    is_champion = unit:is_champion(),
                    is_boss = unit:is_boss()
                }
                console.print("Blacklisted elite enemy " .. unit_id .. " for " .. blacklist_duration .. " seconds")
            end
            goto continue
        end

        -- Get enemy count in range of enemy unit
        local all_units_count, normal_units_count, elite_units_count, champion_units_count, boss_units_count = my_utility.enemy_count_in_range(best_target_evaluation_radius, unit_position)

        -- Calculate total score based on enemy count and enemy type weights
        local total_score = normal_units_count * normal_monster_value
        if boss_units_count > 0 then
            total_score = total_score + boss_value * boss_units_count
        elseif champion_units_count > 0 then
            total_score = total_score + champion_value * champion_units_count
        elseif elite_units_count > 0 then
            total_score = total_score + elite_value * elite_units_count
        end

        -- Check for damage resistance buffs
        for _, buff in ipairs(buffs) do
            if spell_data.enemies and spell_data.enemies.damage_resistance and 
               buff.name_hash == spell_data.enemies.damage_resistance.spell_id then
                -- If enemy is provider of damage resistance aura
                if spell_data.enemies.damage_resistance.buff_ids and 
                   buff.type == spell_data.enemies.damage_resistance.buff_ids.provider then
                    total_score = total_score + damage_resistance_value
                    break
                else -- Enemy is receiver of damage resistance aura
                    total_score = total_score - damage_resistance_value
                    break
                end
            end
        end

        -- Add bonus score for vulnerable or recently hit enemies
        if unit:is_vulnerable() then
            total_score = total_score + 5000
        end

        -- Update best ranged target if this unit has higher score
        if distance_sqr <= max_targeting_range * max_targeting_range then
            if total_score > ranged_max_score then
                best_ranged_target = unit
                ranged_max_score = total_score
            end
        end

        -- Update best melee target if this unit is in melee range and has higher score
        if distance_sqr <= melee_range_sqr then
            if total_score > melee_max_score then
                best_melee_target = unit
                melee_max_score = total_score
            end
        end

        -- Update cursor targets
        if cursor_distance_sqr <= cursor_targeting_radius_sqr then
            local is_within_angle = my_utility.is_target_within_angle(player_position, cursor_position, unit_position, cursor_targeting_angle)
            
            if is_within_angle then
                if total_score > cursor_max_score then
                    best_cursor_target = unit
                    cursor_max_score = total_score
                end

                if cursor_distance_sqr < closest_cursor_distance_sqr then
                    closest_cursor_target = unit
                    closest_cursor_distance_sqr = cursor_distance_sqr
                    closest_cursor_target_angle = cursor_targeting_angle
                end
            end
        end
        
        ::continue::
    end

    return {
        best_ranged_target = best_ranged_target,
        best_melee_target = best_melee_target,
        best_cursor_target = best_cursor_target,
        closest_cursor_target = closest_cursor_target,
        closest_cursor_target_angle = closest_cursor_target_angle,
        ranged_max_score = ranged_max_score,
        melee_max_score = melee_max_score,
        cursor_max_score = cursor_max_score
    }
end

-- Initialize enhancements
local enhancements_initialized = false

safe_on_update(function()
    local local_player = safe_get_local_player()
    if not local_player or not safe_get_menu_element(menu.menu_elements.main_boolean, false) then
        return
    end

    local current_time = safe_get_time_since_inject()

    -- Initialize enhancements if not done already
    if not enhancements_initialized then
        enhancements_initialized = enhancements_manager.initialize(menu.menu_elements)
    end
    
    -- Process stuck detection and auto-blacklisting
    local player_position = safe_get_player_position()
    if player_position then
        if not _G.last_position then
            _G.last_position = player_position
            _G.time_at_position = current_time
        else
            local movement_threshold = 1.0 -- Units of movement to consider player moved
            local distance_moved = player_position:dist_to(_G.last_position)
            
            if distance_moved > movement_threshold then
                -- Player moved, reset timer
                _G.last_position = player_position
                _G.time_at_position = current_time
            else
                -- Check if player is stuck
                local time_stuck = current_time - _G.time_at_position
                if time_stuck > _G.stuck_detection_time and safe_get_menu_element(menu.menu_elements.enable_enemy_blacklist, false) then
                    -- Player might be stuck, blacklist nearby elite enemies
                    console.print("Possible stuck detected! Blacklisting nearby elite enemies")
                    
                    -- Get nearby enemies
                    local danger_radius = 20.0
                    local enemies = safe_utility_get_units_inside_circle_list(player_position, danger_radius)
                    local blacklisted_count = 0
                    
                    for _, enemy in ipairs(enemies) do
                        if (enemy:is_elite() or enemy:is_champion()) and blacklisted_count < 3 then
                            local enemy_id = nil
                            pcall(function() enemy_id = enemy:get_id() or tostring(enemy) end)
                            
                            if enemy_id and not _G.blacklisted_enemies[enemy_id] then
                                local blacklist_duration = safe_get_menu_element(menu.menu_elements.blacklist_duration, 15.0) * 2 -- Double duration for stuck detection
                                _G.blacklisted_enemies[enemy_id] = {
                                    expiry_time = current_time + blacklist_duration,
                                    position = enemy:get_position(),
                                    is_elite = enemy:is_elite(),
                                    is_champion = enemy:is_champion(),
                                    is_boss = enemy:is_boss()
                                }
                                blacklisted_count = blacklisted_count + 1
                                console.print("Auto-blacklisted enemy " .. enemy_id .. " for " .. blacklist_duration .. " seconds")
                            end
                        end
                    end
                    
                    -- Reset timer to prevent constant blacklisting
                    _G.time_at_position = current_time
                    
                    -- Force a new path calculation
                    if blacklisted_count > 0 then
                                            -- Try to use dash or shadow step to escape
                    if safe_utility_is_spell_ready(spells.dash.spell_id) then
                        -- Get random direction away from current position
                        local random_angle = math.random() * 2 * math.pi
                        local escape_dir = vec3.new(math.cos(random_angle), math.sin(random_angle), 0)
                        local dash_pos = player_position:add(escape_dir:multiply(5.0))
                        
                        if safe_utility_is_point_walkeable(dash_pos) then
                            if safe_cast_spell_position(spells.dash.spell_id, dash_pos, 0.1) then
                                _G.last_dash_time = current_time
                                safe_console_print("Auto-used Dash to escape stuck position")
                                cast_end_time = current_time + 0.2
                            end
                        end
                    end
                    end
                end
            end
        end
    end
    
    -- Process enhanced evade if enabled
    if menu.menu_elements.enhanced_evade and safe_get_menu_element(menu.menu_elements.enhanced_evade, false) then
        -- Wrap evade processing in pcall to prevent script errors
        local evaded = false
        local evade_success = pcall(function()
            evaded = enhancements_manager.process_evade(menu.menu_elements)
        end)
        
        if evade_success and evaded then
            -- Successfully evaded, skip the rest of this frame
            return
        end
    end
    
    -- Manage buffs if enabled
    if menu.menu_elements.auto_buff_management and safe_get_menu_element(menu.menu_elements.auto_buff_management, false) then
        -- Wrap buff management in pcall to prevent script errors
        local buff_managed, buff_action = false, nil
        local buff_success = pcall(function()
            buff_managed, buff_action = enhancements_manager.manage_buffs(menu.menu_elements)
        end)
        
        if buff_success and buff_managed then
            -- Buff management took action, skip the rest of this frame
            return
        end
    end
    
    -- Position optimization if enabled and we're not casting
    if menu.menu_elements.position_optimization and safe_get_menu_element(menu.menu_elements.position_optimization, false) and current_time > cast_end_time then
        -- Wrap position optimization in pcall to prevent script errors
        local position_result = { should_move = false }
        local position_success = pcall(function()
            position_result = enhancements_manager.optimize_position(menu.menu_elements)
        end)
        
        if position_success and position_result and position_result.should_move then
            -- Temporarily disable orbwalker movement blocking
            safe_orbwalker_set_block_movement(false)
            -- Let the script handle movement this frame
            return
        end
    end

    -- Check auto-play objective to adapt behavior
    if my_utility.is_auto_play_enabled() then
        local current_objective = safe_auto_play_get_objective()
        
        -- Skip combat logic for non-combat objectives
        if current_objective == objective.loot then
            -- Only handle loot functionality
            local nearby_items = safe_loot_manager_get_all_items_chest_sort_by_distance()
            for _, item in ipairs(nearby_items) do
                if safe_loot_manager_is_lootable_item(item, false, false) then
                    safe_loot_manager_loot_item_orbwalker(item)
                    return
                end
            end
            return
        elseif current_objective == objective.sell or current_objective == objective.repair then
            -- Skip combat rotation during selling/repairing
            return
        elseif current_objective == objective.travel then
            -- During travel, only use mobility spells and avoid combat
            if spells.evade and spells.evade.out_of_combat and current_time - _G.last_dash_time > 5.0 then
                spells.evade.out_of_combat()
            end
            return
        end
        -- Continue with combat rotation for objective.fight
    end

    -- Target selection setup with improved cached targeting
    local player_position = safe_get_player_position()
    local target_list = {}
    local target_evaluation = {}
    
    if current_time >= next_target_update_time then
        -- Only run heavy targeting operations when necessary
        max_targeting_range = safe_get_menu_element(menu.menu_elements.max_targeting_range, 30)
        targeting_refresh_interval = safe_get_menu_element(menu.menu_elements.targeting_refresh_interval, 0.2)
        
        collision_table = {false, 1.0}
        floor_table = {true, 3.0}
        angle_table = {false, 90.0}

        target_list = my_target_selector.get_target_list(
        player_position,
            max_targeting_range,
        collision_table,
        floor_table,
        angle_table)

        target_selector_data_all = my_target_selector.get_target_selector_data(
        player_position,
            target_list)
            
        -- Get all targeting information
        local melee_range = (menu.menu_elements.mode:get() <= 0) and 9.0 or 2.0
        target_evaluation = evaluate_targets(target_list, melee_range)
        
        -- Cache results
        best_ranged_target = target_evaluation.best_ranged_target
        best_melee_target = target_evaluation.best_melee_target
        best_cursor_target = target_evaluation.best_cursor_target
        closest_cursor_target = target_evaluation.closest_cursor_target
        closest_cursor_target_angle = target_evaluation.closest_cursor_target_angle
        ranged_max_score = target_evaluation.ranged_max_score
        melee_max_score = target_evaluation.melee_max_score
        cursor_max_score = target_evaluation.cursor_max_score
        
        next_target_update_time = current_time + targeting_refresh_interval
    end

    if not target_selector_data_all or not target_selector_data_all.is_valid then
        return
    end

    -- Range setup based on mode
    local is_auto_play_active = safe_auto_play_is_active()
    local max_range = 26.0
    local mode_id = safe_get_menu_element(menu.menu_elements.mode, 0)
    local is_ranged = mode_id >= 1
    if mode_id <= 0 then -- melee
        max_range = 10.0
    end

    if is_auto_play_active then
        max_range = 12.0
    end

    -- Determine primary target based on configuration and context
    local best_target = nil
    local closest_target = target_selector_data_all.closest_unit
    
    if is_ranged then
        best_target = best_ranged_target
    else
        best_target = best_melee_target
    end
    
    if not best_target then
        best_target = closest_target
    end

    -- Heartseeker build check
    local spell_id_heartseeker = 363402
    local is_heartseeker_build = is_ranged and safe_utility_is_spell_ready(spell_id_heartseeker)
    local is_best_target_exception = false

    if is_heartseeker_build and best_target then
        if best_target:is_vulnerable() then
            is_best_target_exception = true
        end

        if not is_best_target_exception then
            local buffs = best_target:get_buffs()
            if buffs then
                for _, debuff in ipairs(buffs) do
                    if debuff.name_hash == 39809 or debuff.name_hash == 298962 then
                        is_best_target_exception = true
                        break
                    end
                end
            end
        end
    end

    -- Main spell rotation with prioritization
    -- Iterate through spell priority list for better organized rotation
    for _, spell_name in ipairs(spell_priority) do
        local spell = spells[spell_name]
        if not spell or not spell.logics then
            goto continue
        end
        
        -- Skip if spell isn't enabled or loaded
        if spell.menu_elements and not spell.menu_elements.main_boolean:get() then
            goto continue
        end
        
        -- Different spell types have different parameter requirements
        local result = false
        
        if spell_name == "shadow_clone" then
            result = spell.logics()
            if result then
                cast_end_time = current_time + 0.4
                return
            end
        elseif spell_name == "shadow_imbuement" or 
               spell_name == "poison_imbuement" or 
               spell_name == "cold_imbuement" or
               spell_name == "dark_shroud" or
               spell_name == "concealment" or
               spell_name == "dance_of_knives" then
            -- Self-cast spells
            result = spell.logics()
            if result then
        cast_end_time = current_time + 0.3
                if spell_name == "concealment" then
                    _G.last_concealment_time = current_time
                    cast_end_time = current_time + 0.6
                end
        return
    end
        elseif spell_name == "death_trap" or
               spell_name == "poison_trap" or
               spell_name == "smoke_grenade" or
               spell_name == "penetrating_shot" or
               spell_name == "rain_of_arrows" or
               spell_name == "caltrop" then
            -- Area spells that need target_list and data
            result = spell.logics(target_list, target_selector_data_all, best_target)
            if result then
                cast_end_time = current_time + (spell_name == "death_trap" and 0.05 or 0.3)
                if spell_name == "death_trap" then
                    _G.last_death_trap_time = current_time
                end
        return
    end
        elseif spell_name == "shadow_step" then
            -- Special case for shadow step
            result = spell.logics(target_list, target_selector_data_all, best_target, closest_target)
            if result then
                cast_end_time = current_time + 0.2
                return
            end
        elseif spell_name == "evade" then
            -- Special case for evade
            result = spell.logics(best_target)
            if result then
                cast_end_time = current_time + 0.2
                return
            end
        elseif spell_name == "dash" then
            -- Special case for dash
            result = spell.logics(best_target)
            if result then
                _G.last_dash_time = current_time
                cast_end_time = current_time + 0.2
                return
            end
        elseif spell_name == "heartseeker" then
            -- Special case for heartseeker that uses sorted entity list
            if is_best_target_exception then
    local sorted_entities = {}
                for i, v in ipairs(target_list) do
        sorted_entities[i] = v
    end

    table.sort(sorted_entities, function(a, b)
        return my_target_selector.get_unit_weight(a) > my_target_selector.get_unit_weight(b)
    end)

    for _, unit in ipairs(sorted_entities) do
                    if spell.logics(unit) then
                        _G.last_heartseeker_cast_time = current_time
                        cast_end_time = current_time + spell.menu_elements_heartseeker_base.spell_cast_delay:get()
                        return
                    end
                end
            end
        else
            -- Standard target spells
            result = spell.logics(best_target)
            if result then
                cast_end_time = current_time + 0.3
            return
        end
        end
        
        ::continue::
    end

    -- After the main rotation and all other logic, cast Penetrating Shot as aggressively as possible
    while true do
        local spell = spells["penetrating_shot"]
        if not spell or not spell.logics then break end
        if spell.menu_elements and not spell.menu_elements.main_boolean:get() then break end
        -- Only check if spell is off cooldown and ready
        if not utility.is_spell_ready(377137) then break end
        local result = spell.logics(target_list, target_selector_data_all, best_target)
        if not result then break end
        cast_end_time = current_time + 0.1
    end

    -- Auto-play movement logic
    if current_time >= can_move and my_utility.is_auto_play_enabled() then
        local is_dangerous = false
        -- Safely check if evade has is_dangerous_position function
        if spells.evade and type(spells.evade.is_dangerous_position) == "function" then
            is_dangerous = spells.evade.is_dangerous_position(player_position)
        end
        
        if not is_dangerous then
            local closer_target = safe_target_selector_get_target_closer(player_position, 15.0)
            if closer_target then
                local move_pos = closer_target:get_position():get_extended(player_position, 4.0)
                if safe_pathfinder_move_to_cpathfinder(move_pos) then
                    can_move = current_time + 1.50
                end
            end
        end
    end

    -- Out of combat evade
    if spells.evade and spells.evade.menu_elements and safe_get_menu_element(spells.evade.menu_elements.use_out_of_combat, false) then
        if spells.evade.out_of_combat() then
                    return
        end
    end
    
    -- Enhanced loot management during combat
    if safe_get_menu_element(menu.menu_elements.main_boolean, false) then
        -- Attempt to loot potions if needed
        if safe_loot_manager_is_potion_necessary() then
            local nearby_items = safe_loot_manager_get_all_items_chest_sort_by_distance()
            for _, item in ipairs(nearby_items) do
                if safe_loot_manager_is_potion(item) and safe_loot_manager_is_lootable_item(item, false, true) then
                    local item_pos = item:get_position()
                    if player_position:dist_to(item_pos) < 4.0 then
                        if safe_loot_manager_loot_item(item, false, true) then
                            safe_console_print("Looted potion during combat")
                            _G.last_health_potion_time = current_time
                            return
                        end
                    end
                end
            end
        end
        
        -- Check for high-value items (gold, obols) in close proximity
        local nearby_items = safe_loot_manager_get_all_items_chest_sort_by_distance()
        for _, item in ipairs(nearby_items) do
            if (safe_loot_manager_is_gold(item) or safe_loot_manager_is_obols(item)) and 
               not safe_evade_is_dangerous_position(player_position) then
                local item_pos = item:get_position()
                if player_position:dist_to(item_pos) < 2.0 then
                    if safe_loot_manager_loot_item(item, true, false) then
                        safe_console_print("Looted currency during combat")
                        return
                    end
                end
            end
        end
    end
end)

-- Enhanced rendering logic
safe_on_render(function()
    if not safe_get_menu_element(menu.menu_elements.main_boolean, false) or not safe_get_menu_element(menu.menu_elements.enable_debug, false) then
        return
    end

    local local_player = safe_get_local_player()
    if not local_player then
        return
    end

    local player_position = local_player:get_position()
    local player_screen_position = safe_graphics_w2s(player_position)
    if player_screen_position:is_zero() then
        return
    end

    -- Draw player range circles
    if safe_get_menu_element(menu.menu_elements.draw_max_range, false) then
        safe_graphics_circle_3d(player_position, safe_get_menu_element(menu.menu_elements.max_targeting_range, 30), color_white(85), 3.5, 144)
    end
    
    if safe_get_menu_element(menu.menu_elements.draw_melee_range, false) then
        safe_graphics_circle_3d(player_position, 7.0, color_white(85), 2.5, 144)
    end

    -- Draw cursor target radius
    if safe_get_menu_element(menu.menu_elements.draw_cursor_target, false) then
        local cursor_position = safe_get_cursor_position()
        safe_graphics_circle_3d(cursor_position, safe_get_menu_element(menu.menu_elements.cursor_targeting_radius, 5.0), color_yellow(85), 1.0, 72)
    end

    -- Draw enemy circles and positions
    if safe_get_menu_element(menu.menu_elements.draw_enemy_circles, false) then
        for _, obj in ipairs(safe_actors_manager_get_enemy_npcs()) do
            local position = obj:get_position()
            safe_graphics_circle_3d(position, 1, color_white(100))
            safe_graphics_circle_3d(safe_prediction_get_future_unit_position(obj, 0.4), 0.5, color_yellow(100))
        end
    end

    -- Draw targets
    if safe_get_menu_element(menu.menu_elements.draw_targets, false) then
        -- Draw best ranged target
        if best_ranged_target then
            safe_graphics_circle_3d(best_ranged_target:get_position(), 1.5, color_green(150), 2.0, 36)
        end
        
        -- Draw best melee target
        if best_melee_target then
            safe_graphics_circle_3d(best_melee_target:get_position(), 1.5, color_blue(150), 2.0, 36)
        end
        
        -- Draw cursor targets
        if best_cursor_target then
            safe_graphics_circle_3d(best_cursor_target:get_position(), 1.5, color_purple(150), 2.0, 36)
        end
        
        if closest_cursor_target then
            safe_graphics_circle_3d(closest_cursor_target:get_position(), 1.5, color_red(150), 2.0, 36)
        end
    end

    -- Call enhanced rendering if debug is enabled
    enhancements_manager.on_render(menu.menu_elements)
end);

safe_console_print("Rogue Penetrating Shot Smoke | Version 1")