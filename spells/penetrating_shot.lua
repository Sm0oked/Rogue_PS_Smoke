local my_utility = require("my_utility/my_utility")
local menu_module = require("menu")
-- Add enhanced targeting and enhancements manager
local enhanced_targeting = require("my_utility/enhanced_targeting")
local enhancements_manager = require("my_utility/enhancements_manager")
local my_target_selector = require("my_utility/my_target_selector");

local menu_elements =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "pen_shot_base_main_bool")),

    trap_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "pen_shot_base_mode")),
    keybind               = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "pen_shot_base_keybind_pos")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(my_utility.plugin_label .. "pen_shot_base_keybind_ignore_min_hitstrap_base_pos")),

    min_hits              = slider_int:new(1, 20, 2, get_hash(my_utility.plugin_label .. "pen_shot_base_min_hits_to_casttrap_base_pos")),  -- Reduced default from 4 to 2
    
    allow_percentage_hits = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_percentage_hits_pen_shot_base_pos")),
    min_percentage_hits   = slider_float:new(0.1, 1.0, 0.50, get_hash(my_utility.plugin_label .. "min_percentage_hits_pen_shot_base_pos")),
    soft_score            = slider_float:new(2.0, 15.0, 3.0, get_hash(my_utility.plugin_label .. "min_percentage_hits_pen_shot_base_soft_core_pos")),  -- Reduced default from 6.0 to 3.0

    spell_range   = slider_float:new(1.0, 15.0, 10.0, get_hash(my_utility.plugin_label .. "pen_shot_base_spell_range")),
    spell_radius   = slider_float:new(0.50, 5.0, 1.50, get_hash(my_utility.plugin_label .. "pen_shot_base_spell_radius")),
}

local function render_menu()
    
    if menu_elements.tree_tab:push("Penetrating Shot") then
        menu_elements.main_boolean:render("Enable Spell", "");

        local options =  {"Auto", "Keybind"};
        menu_elements.trap_mode:render("Mode", options, "");

        menu_elements.keybind:render("Keybind", "");
        menu_elements.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");

        menu_elements.min_hits:render("Min Hits", "");

        menu_elements.allow_percentage_hits:render("Allow Percentage Hits", "");
        if menu_elements.allow_percentage_hits:get() then
            menu_elements.min_percentage_hits:render("Min Percentage Hits", "", 1);
            menu_elements.soft_score:render("Soft Score", "", 1);
        end       

        menu_elements.spell_range:render("Spell Range", "", 1)
        menu_elements.spell_radius:render("Spell Radius", "", 1)

        menu_elements.tree_tab:pop();
    end
end

local spell_id_penetration_shot = 377137;
local spell_data_penetration_shot = spell_data:new(
    1.50,                        -- radius
    20.0,                        -- range
    .02,                        -- cast_delay
    5.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_penetration_shot,           -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)
local next_time_allowed_cast = 0.0;
local global_penetration_shot_last_cast_position = nil;

local function logics(entity_list, target_selector_data, best_target)
    
    local menu_boolean = menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_penetration_shot);

    if not is_logic_allowed then
        console.print("Penetrating shot: Logic not allowed")
        return false;
    end;

    local player_position = get_player_position()
    local keybind_used = menu_elements.keybind:get_state();
    local trap_mode = menu_elements.trap_mode:get();
    if trap_mode == 1 then
        if  keybind_used == 0 then   
            return false;
        end;
    end;

    local keybind_ignore_hits = menu_elements.keybind_ignore_hits:get();
   
    ---@type boolean
    local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;
    
    -- Get spell parameters
    local spell_radius = menu_elements.spell_radius:get()
    local spell_range = menu_elements.spell_range:get()
    
    -- Update spell range info for visualization
    enhancements_manager.update_spell_range("penetrating_shot", spell_range, spell_radius, global_penetration_shot_last_cast_position)
    
    -- Simplified targeting for maximum casting speed
    local all_units_count, normal_units_count, elite_units_count, champion_units_count, boss_units_count = 
        my_utility.enemy_count_in_range(spell_radius, player_position)
    
    -- Check if we're fighting a boss
    local is_boss_fight = false
    if best_target and (best_target:is_boss() or best_target:is_champion()) then
        is_boss_fight = true
    end
    
    -- In boss fights, use a larger range to ensure we can target the boss
    if is_boss_fight then
        local boss_range = 25.0 -- Extended range for boss fights
        local boss_units_count = my_utility.enemy_count_in_range(boss_range, player_position)
        if boss_units_count >= 1 then
            all_units_count = boss_units_count -- Use the boss range count instead
            spell_range = boss_range -- Temporarily extend spell range for boss fights
        end
    end
    
    -- Allow casting if there's at least 1 enemy (simplified logic)
    if all_units_count < 1 then
        if is_boss_fight then
            console.print("Penetrating shot: No enemies in range (count: " .. all_units_count .. ")")
        end
        return false
    end
    
    -- Get a simple target - prefer best_target if available, otherwise use closest enemy
    local target_to_cast_at = best_target
    if not target_to_cast_at then
        -- Find closest enemy as fallback
        local closest_enemy = nil
        local closest_distance = 999999
        
        for _, entity in ipairs(entity_list) do
            if entity:is_enemy() then
                local dist = player_position:dist_to(entity:get_position())
                if dist < closest_distance and dist <= spell_range then
                    closest_distance = dist
                    closest_enemy = entity
                end
            end
        end
        
        target_to_cast_at = closest_enemy
    end
    
    if not target_to_cast_at or not target_to_cast_at:is_enemy() then
        if is_boss_fight then
            console.print("Penetrating shot: No valid target found")
        end
        return false
    end
    
    -- In boss fights, try to find a better cast position to avoid wall collision
    if is_boss_fight and target_to_cast_at then
        local boss_pos = nil
        local success = pcall(function()
            boss_pos = target_to_cast_at:get_position()
        end)
        
        if success and boss_pos then
            local direction = nil
            local dir_success = pcall(function()
                direction = boss_pos:subtract(player_position)
            end)
            
            if dir_success and direction and direction:length_3d() > 0 then
                local normalized_dir = nil
                local norm_success = pcall(function()
                    normalized_dir = direction:normalize()
                end)
                
                if norm_success and normalized_dir then
                    local offset_pos = nil
                    local offset_success = pcall(function()
                        local offset_distance = 2.0
                        offset_pos = player_position:add(normalized_dir:multiply(offset_distance))
                    end)
                    
                    if offset_success and offset_pos then
                        cast_position = offset_pos
                        console.print("Penetrating shot: Using offset position for boss fight")
                    else
                        cast_position = boss_pos
                        console.print("Penetrating shot: Offset calculation failed, using direct boss position")
                    end
                else
                    cast_position = boss_pos
                    console.print("Penetrating shot: Direction normalization failed, using direct boss position")
                end
            else
                cast_position = boss_pos
                console.print("Penetrating shot: Direction calculation failed, using direct boss position")
            end
        else
            console.print("Penetrating shot: Boss position is nil, using direct target position")
            cast_position = target_to_cast_at:get_position()
        end
    else
        cast_position = target_to_cast_at:get_position()
    end
    
    -- Skip wall collision check in boss fights since bosses can be positioned in ways that trigger false positives
    local is_wall_collision = false
    if not is_boss_fight then
        is_wall_collision = prediction.is_wall_collision(player_position, cast_position, 0.15)
        if is_wall_collision then
            console.print("Penetrating shot: Wall collision detected")
            return false
        end
    else
        console.print("Penetrating shot: Skipping wall collision check for boss fight")
    end

    -- Simple and fast casting
    local cast_success = false
    pcall(function()
        cast_success = cast_spell.position(spell_id_penetration_shot, cast_position, 0.4)
    end)
    
    if cast_success then
        local current_time = get_time_since_inject()
        next_time_allowed_cast = current_time + 0.02  -- Ultra-fast casting like boss mode
        global_penetration_shot_last_cast_position = cast_position
        _G.last_penetrating_shot_time = current_time
        
        if is_boss_fight then
            console.print("Penetrating shot: Cast successful in boss fight")
        else
            console.print("Rouge Plugin: Casted Penetrating Shot (fast mode)")
        end
        return true
    end
    
    if is_boss_fight then
        console.print("Penetrating shot: Cast failed in boss fight")
    end
    return false;
end


return 
{
    menu = render_menu,
    logics = logics,   
}