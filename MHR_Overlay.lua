--------------------CUSTOMIZATION SECTION--------------------
local monster_UI = {
	enabled = true,

	spacing = 20,
	orientation = "horizontal", -- "vertical" or "horizontal"

	sort_type = "health percentage", -- "normal" or "health" or "health percentage"
	reverse_order = false,

    visibility = {
        health_bar = true,
        monster_name = true,
        current_health = true,
        max_health = true,
        health_percentage = true
    },

	shadows = {
		monster_name = true,
		health_values = true, --current_health and max_health
		health_percentage = true
	},
    
    position = {
        x = 0,
        y = 27,  
        --Possible values: "top-left", "top-right", "top-center", "bottom-left", "bottom-right", "bottom-center"
        anchor = "top-center"
    },

    offsets = {
        health_bar = {
            x = 0,
            y = 0
        },
		
        monster_name = {
            x = 5,
            y = -18
        },

        health_values = {
            x = 5,
            y = 8
        },

        health_percentage = {
            x = 200,
            y = 8
        }
    },
    
    health_bar = {
        width = 250,
        height = 35
    },

    shadow_offsets = {
        monster_name = {
            x = 1,
            y = 1
        },

        health_values = {
            x = 1,
            y = 1
        },

        health_percentage = {
            x = 1,
            y = 1
        }
    },

    colors = {
		health_bar = {
            remaining_health = 0xB952A674,
            missing_health = 0xB9000000
        },
		
        monster_name = {
            text = 0xFFE1F4CC,
            shadow = 0xFF000000
        },

        health_values = {
            text = 0xFFFFFFFF,
            shadow = 0xFF000000
        },

        health_percentage = {
            text = 0xFFFFFFFF,
            shadow = 0xFF000000
        }
    }
};

local time_UI = {
    enabled = true,
	shadow = true,

    position = {
        x = 90,
        y = 250,
        --Possible values: "top-left", "top-right", "bottom-left", "bottom-right"
        anchor = "top-left"
    },

    shadow_offset = {
        x = 1,
        y = 1
    },

    colors = {
        text = 0xFFE1F4CC,
		shadow = 0xFF000000
    }
};

local damage_meter_UI = {
	enabled = true,

	include_player_damage = true,
	include_bomb_damage = true,
	include_kunai_damage = true,
	include_installation_damage = true, -- hunting_installations like ballista, cannon, etc.
	include_otomo_damage = true,
	include_monster_damage = true, -- note that installations during narwa fight are counted as monster damage

	show_module_if_total_damage_is_zero = true,
	show_player_if_player_damage_is_zero = true,

	highlight_damade_bar_of_myself = true,

	spacing = 20,
	orientation = "vertical", -- "vertical" or "horizontal"
	total_damage_offset_is_relative = false,

	damage_bar_relative_to = "top_damage", -- "total_damage" or "top_damage"
	myself_bar_place_in_order = "first", --"normal" or "first" or "last"
	sort_type = "damage", -- "normal" or "damage"
	reverse_order = false,

	visibility = {
		id = false,
		name = true,
		damage_bar = true,
		player_damage = true,
		player_damage_percentage = true,
		total_damage = true
	},

	shadows = {
		name = true,
		player_damage = true,
		player_damage_percentage = true,
		total_damage = true
	},

	position = {
		x = 400,
		y = 325,
		--Possible values: "top-left", "top-right", "bottom-left", "bottom-right"
		anchor = "bottom-right"
	},

	offsets = {
		name = {
			x = 5,
			y = 0
		},

		damage_bar = {
			x = 0,
			y = 17
		},
		
		player_damage = {
			x = 120,
			y = 0
		},

		player_damage_percentage = {
			x = 237,
			y = 0
		},

		total_damage = {
			x = 139,
			y = -18
		}
	},
	
	damage_bar = {
		width = 275,
		height = 20
	},

	shadow_offsets = {
		name = {
			x = 1,
			y = 1
		},

		player_damage = {
			x = 1,
			y = 1
		},

		player_damage_percentage = {
			x = 1,
			y = 1
		},

		total_damage = {
			x = 1,
			y = 1
		}
	},

	colors = {
		name = {
			text = 0xFFE1F4CC,
			shadow = 0xFF000000
		},

		damage_bar = {
			player_damage = 0xA7F4A3CC,
			others_damage = 0xA7000000
		},

		damage_bar_myself = {
			player_damage = 0xA7A3D5F4,
			others_damage = 0xA7000000
		},
		
		player_damage = {
			text = 0xFFE1F4CC,
			shadow = 0xFF000000
		},

		player_damage_percentage = {
			text = 0xFFE1F4CC,
			shadow = 0xFF000000
		},
		
		total_damage = {
			text = 0xFF7373ff,
			shadow = 0xFF000000
		}
	}
};
----------------------CUSTOMIZATION END----------------------




---------------------------GLOBAL----------------------------
log.info("[MHR_Overlay.lua] loaded");

status = "OK";

screen_width = 0;
screen_height = 0;

local scene_manager = sdk.get_native_singleton("via.SceneManager");
if not scene_manager then 
    log.error("[MHR_Overlay.lua] No scene manager");
    return
end

local scene_view = sdk.call_native_func(scene_manager, sdk.find_type_definition("via.SceneManager"), "get_MainView");
if not scene_view then
    log.error("[MHR_Overlay.lua] No main view");
    return
end


re.on_draw_ui(function() 
    if string.len(status) > 0 then
        imgui.text("[MHR_Overlay.lua] Status: " .. status);
    end
end);

re.on_frame(function()
	status = "OK";
	get_window_size();

	if monster_UI.enabled then
		monster_health();
	end

	if time_UI.enabled then
		quest_time();
	end

	if damage_meter_UI.enabled then
		damage_meter();
	end
end);

function get_window_size()
	local size = scene_view:call("get_Size");
	if not size then
		log.error("[MHR_Overlay.lua] No scene view size");
		return
	end

	screen_width = size:get_field("w");
	if not screen_width then
		log.error("[MHR_Overlay.lua] No screen width");
		return
	end

	screen_height = size:get_field("h");
	if not screen_height then
		log.error("[MHR_Overlay.lua] No screen height");
		return
	end
end

function calculate_screen_coordinates(position, total_monsters)
	if position.anchor == "top-left" then
		return {x = position.x, y = position.y};
	end

	if position.anchor == "top-right" then
		local screen_x = screen_width - position.x;
		return {x = screen_x, y = position.y};
	end

	if position.anchor == "bottom-left" then
		local screen_y = screen_height - position.y;
		return {x = position.x, y = screen_y};
	end

	if position.anchor == "bottom-right" then
		local screen_x = screen_width - position.x;
		local screen_y = screen_height - position.y;
		return {x = screen_x, y = screen_y};
	end

	if position.anchor == "top-center" then
		local screen_center = screen_width/2
		local total_spacing = total_monsters - 1
		local screen_x = (screen_center - ((monster_UI.health_bar.width*(total_monsters*0.5))+(monster_UI.spacing*(total_spacing*0.5))+position.x))
		return {x = screen_x, y = position.y};
	end

	if position.anchor == "bottom-center" then
		local screen_center = screen_width/2
		local total_spacing = total_monsters - 1
		local screen_x = (screen_center - ((monster_UI.health_bar.width*(total_monsters*0.5))+(monster_UI.spacing*(total_spacing*0.5))+position.x))
		return {x = screen_x, y = screen_height - (position.y + monster_UI.health_bar.height)};
	end

	return {x = position.x, y = position.y};
end

---------------------------GLOBAL----------------------------





-------------------------MONSTER UI--------------------------
local monster_table = {};

local missing_monster_health = 0;
local previous_missing_monster_health = 0;
local memorized_missing_monster_health = 0;

local enemy_character_base_type_def = sdk.find_type_definition("snow.enemy.EnemyCharacterBase");
local enemy_character_base_type_def_update_method = enemy_character_base_type_def:get_method("update");

sdk.hook(enemy_character_base_type_def_update_method, function(args) 
    record_health(sdk.to_managed_object(args[2]));
end, function(retval) return retval; end);

function record_health(enemy)
    if not enemy then
		return;
	end

    local physical_param = enemy:get_field("<PhysicalParam>k__BackingField");
    if not physical_param then 
        status = "No physical param";
        return;
    end

    local vital_param = physical_param:call("getVital", 0, 0);
    if not vital_param then
        status = "No vital param";
        return;
    end

    local health = vital_param:call("get_Current");
    local max_health = vital_param:call("get_Max");
	local missing_health = max_health - health;

	local health_percentage = 1;
	if max_health ~= 0 then
		health_percentage = health / max_health;
	end

    local monster = monster_table[enemy];

    if not hp_entry then 
        monster = {};
        monster_table[enemy] = monster;

        -- Grab enemy name.
        local message_manager = sdk.get_managed_singleton("snow.gui.MessageManager");
        if not message_manager then
            status = "No message manager";
            return;
        end

        local enemy_type = enemy:get_field("<EnemyType>k__BackingField");
        if not enemy_type then
            status = "No enemy type";
            return;
        end

        local enemy_name = message_manager:call("getEnemyNameMessage", enemy_type);
        monster.name = enemy_name;
    end

    monster.health = health;
    monster.max_health = max_health;
	monster.health_percentage = health_percentage;
	monster.missing_health = missing_health;
end

function monster_health()
    local enemy_manager = sdk.get_managed_singleton("snow.enemy.EnemyManager");
	local total_spacing = monster_UI.health_bar.width + monster_UI.spacing
    if not enemy_manager then
        status = "No enemy manager";
        return;
	end

	local monsters = {};

	local enemy_count = enemy_manager:call("getBossEnemyCount");
	if enemy_count == nil then
		status = "No enemy count";
		return;
	end

    for i = 0, enemy_count - 1 do
        local enemy = enemy_manager:call("getBossEnemy", i);
        if enemy == nil then
			status = "No enemy";
            break;
        end
		
        local monster = monster_table[enemy];
        if monster == nil then 
            status = "No monster hp entry";
            break;
        end

		table.insert(monsters, monster);
    end

	--sort_type = "normal", -- "normal" or "health" or "health_percentage"
	--sort here
	if monster_UI.sort_type == "normal" and monster_UI.reverse_order then
		local reversed_monsters = {};

		for i = #monsters, 1, -1 do
			table.insert(reversed_monsters, monsters[i]);
		end
		monsters = reversed_monsters;

	elseif monster_UI.sort_type == "health" then
		table.sort(monsters, function(left, right)
			local result = left.health > right.health;

			if monster_UI.reverse_order then
				result = not result;
			end

			return result;
		end);
	elseif monster_UI.sort_type == "health percentage" then
		table.sort(monsters, function(left, right)
			local result = left.health_percentage < right.health_percentage;
			
			if monster_UI.reverse_order then
				result = not result;
			end

			return result;
		end);
	end

	local i = 0;
	for _, monster in ipairs(monsters) do
		local screen_position = calculate_screen_coordinates(monster_UI.position, enemy_count);

		if monster_UI.orientation == "horizontal" then
			screen_position.x = screen_position.x + total_spacing * i;
		else
			screen_position.y = screen_position.y + total_spacing * i;
		end

		if monster_UI.visibility.health_bar then
			local health_bar_remaining_health_width = monster_UI.health_bar.width * monster.health_percentage;
			local health_bar_missing_health_width = monster_UI.health_bar.width - health_bar_remaining_health_width;

			--remaining health
			draw.filled_rect(screen_position.x + monster_UI.offsets.health_bar.x, screen_position.y + monster_UI.offsets.health_bar.y, health_bar_remaining_health_width, monster_UI.health_bar.height, monster_UI.colors.health_bar.remaining_health);
			--missing health
			draw.filled_rect(screen_position.x + monster_UI.offsets.health_bar.x + health_bar_remaining_health_width, screen_position.y + monster_UI.offsets.health_bar.y, health_bar_missing_health_width, monster_UI.health_bar.height, monster_UI.colors.health_bar.missing_health);
		end

		if monster_UI.visibility.monster_name then
			if monster_UI.shadows.monster_name then
				--monster name shadow
				draw.text(monster.name, screen_position.x + monster_UI.offsets.monster_name.x + monster_UI.shadow_offsets.monster_name.x, screen_position.y + monster_UI.offsets.monster_name.y + monster_UI.shadow_offsets.monster_name.y, monster_UI.colors.monster_name.shadow);
			end

			--monster name
			draw.text(monster.name, screen_position.x  + monster_UI.offsets.monster_name.x, screen_position.y + monster_UI.offsets.monster_name.y, monster_UI.colors.monster_name.text);
		end

		if monster_UI.visibility.current_health or monster_UI.visibility.max_health then
			local health_values = "";
			if monster_UI.visibility.current_health then
				health_values = string.format("%d", monster.health);
			end
	
			if monster_UI.visibility.max_health then
				if monster_UI.visibility.current_health then
					health_values = health_values .. "/";
				end

				health_values = health_values .. string.format("%d", monster.max_health);
			end

			if monster_UI.shadows.health_values then
				--health values shadow
				draw.text(health_values, screen_position.x + monster_UI.offsets.health_values.x + monster_UI.shadow_offsets.health_values.x, screen_position.y + monster_UI.offsets.health_values.y + monster_UI.shadow_offsets.health_values.y, monster_UI.colors.health_values.shadow);
			end
			--health values
			draw.text(health_values, screen_position.x + monster_UI.offsets.health_values.x, screen_position.y  + monster_UI.offsets.health_values.y, monster_UI.colors.health_values.text);
		end

		if monster_UI.visibility.health_percentage then
			local health_percentage_text = string.format("%5.1f%%", 100 * monster.health_percentage);

			if monster_UI.shadows.health_percentage then
				--health percentage shadow
				draw.text(health_percentage_text, screen_position.x + monster_UI.offsets.health_percentage.x + monster_UI.shadow_offsets.health_percentage.x, screen_position.y + monster_UI.offsets.health_percentage.y + monster_UI.shadow_offsets.health_percentage.y, monster_UI.colors.health_percentage.shadow);
			end
			--health percentage
			draw.text(health_percentage_text, screen_position.x + monster_UI.offsets.health_percentage.x, screen_position.y + monster_UI.offsets.health_percentage.y, monster_UI.colors.health_percentage.text);
		end

		i = i + 1;
    end
end
-------------------------MONSTER UI--------------------------





---------------------------TIME UI---------------------------
function quest_time()
    local quest_manager = sdk.get_managed_singleton("snow.QuestManager");
    if not quest_manager then
        status = "No quest manager";
        return;
    end

    local quest_time_elapsed_minutes = quest_manager:call("getQuestElapsedTimeMin");
    if not quest_time_elapsed_minutes then
        status = "No quest time elapsed minutes";
        return;
    end

    local quest_time_total_elapsed_seconds = quest_manager:call("getQuestElapsedTimeSec");
    if not quest_time_total_elapsed_seconds then
        status = "No quest time total elapsed seconds";
        return;
    end

    if quest_time_total_elapsed_seconds == 0 then
        return;
    end

    local quest_time_elapsed_seconds = quest_time_total_elapsed_seconds - quest_time_elapsed_minutes * 60;

    local elapsed_time_text = string.format("%02d:%06.3f", quest_time_elapsed_minutes, quest_time_elapsed_seconds);

	local screen_position = calculate_screen_coordinates(time_UI.position);

	if time_UI.shadow then
		--shadow
		draw.text(elapsed_time_text, screen_position.x + time_UI.shadow_offset.x, screen_position.y + time_UI.shadow_offset.y, time_UI.colors.shadow);
	end
    --text
	draw.text(elapsed_time_text, screen_position.x, screen_position.y, time_UI.colors.text);
end
---------------------------TIME UI---------------------------





-----------------------DAMAGE METER UI-----------------------
players = {};
is_quest_online = false;
last_displayed_players = {};
myself_player_id = 0;

local enemy_character_base_type_def = sdk.find_type_definition("snow.enemy.EnemyCharacterBase");
local enemy_character_base_after_calc_damage_damage_side = enemy_character_base_type_def:get_method("afterCalcDamage_DamageSide");

sdk.hook(enemy_character_base_after_calc_damage_damage_side, function(args)
	local enemy = sdk.to_managed_object(args[2]);
	if enemy == nil then
		return;
	end

	local enemy_calc_damage_info = sdk.to_managed_object(args[3]); -- snow.hit.EnemyCalcDamageInfo.AfterCalcInfo_DamageSide
	local attacker_id = enemy_calc_damage_info:call("get_AttackerID");
	local attacker_type = enemy_calc_damage_info:call("get_DamageAttackerType");

	if is_quest_online and attacker_id == 4 then
		attacker_id = myself_id;
	end 

	local damage_object = {}
	damage_object.total_damage = enemy_calc_damage_info:call("get_TotalDamage");;
	damage_object.physical_damage = enemy_calc_damage_info:call("get_PhysicalDamage");
	damage_object.elemental_damage = enemy_calc_damage_info:call("get_ElementDamage");
	damage_object.ailment_damage = enemy_calc_damage_info:call("get_ConditionDamage");

	-- -1 - bombs
	--  0 - player
	--  9 - kunai
	-- 11 - wyverblast
	-- 12 - ballista
	-- 13 - cannon
	-- 14 - machine cannon
	-- 16 - defender ballista/cannon
	-- 17 - wyvernfire artillery
	-- 18 - dragonator
	-- 19 - otomo
	-- 23 - monster

	local damage_source_type = tostring(attacker_type);
	if attacker_type == 0 then
		damage_source_type = "player";
	elseif attacker_type == 1 then
		damage_source_type = "bomb";
	elseif attacker_type == 9 then
		damage_source_type = "kunai";
	elseif attacker_type == 11 then
		damage_source_type = "wyvernblast";
	elseif attacker_type == 12 or attacker_type == 13 or attacker_type == 14 or attacker_type == 18 then
		damage_source_type = "installation";
	elseif attacker_type == 19 then
		damage_source_type = "otomo";
	elseif attacker_type == 23 then
		damage_source_type = "monster";
	end

	update_player(total, damage_source_type, damage_object);
	update_player(get_player(attacker_id), damage_source_type, damage_object);
end, function(retval) return retval; end);

function init_player(player_id, player_name)
	player = {};
	player.id = player_id;
	player.name = player_name;

	player.total_damage = 0;
	player.physical_damage = 0;
	player.elemental_damage = 0;
	player.ailment_damage = 0;

	player.bombs = {};
	player.bombs.total_damage = 0;
	player.bombs.physical_damage = 0;
	player.bombs.elemental_damage = 0;
	player.bombs.ailment_damage = 0;

	player.kunai = {};
	player.kunai.total_damage = 0;
	player.kunai.physical_damage = 0;
	player.kunai.elemental_damage = 0;
	player.kunai.ailment_damage = 0;

	player.installations = {};
	player.installations.total_damage = 0;
	player.installations.physical_damage = 0;
	player.installations.elemental_damage = 0;
	player.installations.ailment_damage = 0;

	player.otomo = {};
	player.otomo.total_damage = 0;
	player.otomo.physical_damage = 0;
	player.otomo.elemental_damage = 0;
	player.otomo.ailment_damage = 0;

	player.monster = {};
	player.monster.total_damage = 0;
	player.monster.physical_damage = 0;
	player.monster.elemental_damage = 0;
	player.monster.ailment_damage = 0;

	player.display = {};
	player.display.total_damage = 0;
	player.display.physical_damage = 0;
	player.display.elemental_damage = 0;
	player.display.ailment_damage = 0;

	return player;
end

function merge_damage(first, second)
	first.total_damage = first.total_damage + second.total_damage;
	first.physical_damage =  first.physical_damage + second.physical_damage;
	first.elemental_damage = first.elemental_damage + second.elemental_damage;
	first.ailment_damage = first.ailment_damage + second.ailment_damage;
end

total = init_player(0, "Total");

function get_player(player_id)
	if players[player_id] == nil then
		return nil;
	end

	return players[player_id];
end

function update_player(player, damage_source_type, damage_object)
	if player == nil then
		return;
	end

	if damage_source_type == "player" then
		merge_damage(player, damage_object);
	elseif damage_source_type == "bomb" then
		merge_damage(player.bombs, damage_object);
	elseif damage_source_type == "kunai" then
		merge_damage(player.kunai, damage_object);
	elseif damage_source_type == "wyvernblast" then
		merge_damage(player, damage_object);
	elseif damage_source_type == "installation" then
		merge_damage(player.installations, damage_object);
	elseif damage_source_type == "otomo" then
		merge_damage(player.otomo, damage_object);
	elseif damage_source_type == "monster" then
		merge_damage(player.monster, damage_object);
	else
		merge_damage(player, damage_object);
	end

	player.display.total_damage = 0;
	player.display.physical_damage = 0;
	player.display.elemental_damage = 0;
	player.display.ailment_damage = 0;

	if damage_meter_UI.include_player_damage then
		merge_damage(player.display, player);
	end

	if damage_meter_UI.include_bomb_damage then
		merge_damage(player.display, player.bombs);
		
	end

	if damage_meter_UI.include_kunai_damage then
		merge_damage(player.display, player.kunai);
	end

	if damage_meter_UI.include_installation_damage then
		merge_damage(player.display, player.installations);
	end

	if damage_meter_UI.include_otomo_damage then
		merge_damage(player.display, player.otomo);
	end

	if damage_meter_UI.include_monster_damage then
		merge_damage(player.display, player.monster);
	end
end

function damage_meter()
	local quest_manager = sdk.get_managed_singleton("snow.QuestManager");
    if quest_manager == nil then
        status = "No quest manager";
        return;
    end

	local quest_status = quest_manager:call("getStatus");
	if quest_status == nil then
		status = "No quest status";
        return;
	end

	if quest_status < 2 then
		players = {};
		total = init_player(0, "Total");
		return;
	end
	
	if total.display.total_damage == 0 and not damage_meter_UI.show_module_if_total_damage_is_zero then
		return;
	end

	
	-- players in lobby
	local lobby_manager = sdk.get_managed_singleton("snow.LobbyManager");
    if lobby_manager == nil then
        status = "No lobby manager";
        return;
    end

	is_quest_online = lobby_manager:call("IsQuestOnline");
	if is_quest_online == nil then
		is_quest_online = false;
	end

	--myself player
	local myself_player_info = lobby_manager:get_field("_myHunterInfo");
	if  myself_player_info == nil then
        status = "No myself player info list";
		return;
    end

	local myself_player_name = myself_player_info:get_field("_name");
	if myself_player_name == nil then
		status = "No myself player name";
		return;
	end

	myself_player_id = 0;
	if is_quest_online then
		myself_player_id = lobby_manager:get_field("_myselfQuestIndex");
		if myself_player_id == nil then
			status = "No myself player id";
			return;
		end
	else
		myself_player_id = lobby_manager:get_field("_myselfIndex");
		if myself_player_id == nil then
			status = "No myself player id";
			return;
		end
	end

	if players[myself_player_id] == nil then
		players[myself_player_id] = init_player(myself_player_id, myself_player_name);
	end

	local quest_players = {};

	--other players
	local player_info_list = lobby_manager:get_field("_questHunterInfo");
	if player_info_list == nil then
        status = "No player info list";
    end
	
	local count = player_info_list:call("get_Count");
	if count == nil then
        status = "No player info list count";
		return;
    end

	for i = 0, count - 1 do
		local player_info = player_info_list:call("get_Item", i);
		if player_info == nil then
			goto continue;
		end
		local player_id = player_info:get_field("_memberIndex");
		if player_id == nil then
			goto continue;
		end

		if player_id == myself_player_id and damage_meter_UI.myself_bar_place_in_order ~= "normal" then
			goto continue;
		end

		local player_name = player_info:get_field("_name");
		if player_name == nil then
			goto continue;
		end

		if players[player_id] == nil then
			players[player_id] = init_player(player_id, player_name);
		elseif players[player_id].name ~= player_name then
			players[player_id] = init_player(player_id, player_name);
		end

		table.insert(quest_players, players[player_id]);

		::continue::
	end

	--sort here
	if damage_meter_UI.sort_type == "normal" and damage_meter_UI.reverse_order then
		local reversed_quest_players = {};

		for i = #quest_players, 1, -1 do
			table.insert(reversed_quest_players, quest_players[i]);
		end
		quest_players = reversed_quest_players;

	elseif damage_meter_UI.sort_type == "damage" then
		table.sort(quest_players, function(left, right)
			local result = left.display.total_damage > right.display.total_damage;
			if damage_meter_UI.reverse_order then
				result = not result;
			end

			return result;
		end);
	end

	if damage_meter_UI.myself_bar_place_in_order == "first" then
		table.insert(quest_players, 1, players[myself_player_id]);
	end

	if damage_meter_UI.myself_bar_place_in_order == "last" then
		table.insert(quest_players, #quest_players + 1, players[myself_player_id]);
	end
	
	local top_damage = 0;
	for _, player in ipairs(quest_players) do
		if player.display.total_damage > top_damage then
			top_damage = player.display.total_damage;
		end
	end

	last_displayed_players = quest_players;

	--draw
	local i = 0;
	for _, player in ipairs(quest_players) do
		if player.display.total_damage == 0 and not damage_meter_UI.show_player_if_player_damage_is_zero then
			goto continue1;
		end

		local screen_position = calculate_screen_coordinates(damage_meter_UI.position);

		if damage_meter_UI.orientation == "horizontal" then
			local total_dam_spacing = damage_meter_UI.damage_bar.width + damage_meter_UI.spacing
			screen_position.x = screen_position.x + total_dam_spacing * i;
		else
			local total_dam_spacing = damage_meter_UI.damage_bar.height + damage_meter_UI.spacing
			screen_position.y = screen_position.y + total_dam_spacing * i;
		end

		local player_total_damage_percentage = 0;
		if total.display.total_damage ~= 0 then
			player_total_damage_percentage = player.display.total_damage / total.display.total_damage;
		end

		if damage_meter_UI.visibility.damage_bar then
			local damage_bar_player_damage_width = 0;
			if damage_meter_UI.damage_bar_relative_to == "total_damage" then
				damage_bar_player_damage_width = damage_meter_UI.damage_bar.width * player_total_damage_percentage;
			elseif top_damage ~= 0 then
				damage_bar_player_damage_width = damage_meter_UI.damage_bar.width * (player.display.total_damage / top_damage); 
			end
			
			local damage_bar_others_damage_width = damage_meter_UI.damage_bar.width - damage_bar_player_damage_width;

			local damage_bar_color =  damage_meter_UI.colors.damage_bar;
			if damage_meter_UI.highlight_damade_bar_of_myself and player.id == myself_player_id then
				damage_bar_color = damage_meter_UI.colors.damage_bar_myself;
			end

			--player damage
			draw.filled_rect(screen_position.x + damage_meter_UI.offsets.damage_bar.x, screen_position.y + damage_meter_UI.offsets.damage_bar.y, damage_bar_player_damage_width, damage_meter_UI.damage_bar.height, damage_bar_color.player_damage);
			
			--other damage
			draw.filled_rect(screen_position.x + damage_meter_UI.offsets.damage_bar.x + damage_bar_player_damage_width, screen_position.y + damage_meter_UI.offsets.damage_bar.y, damage_bar_others_damage_width, damage_meter_UI.damage_bar.height, damage_bar_color.others_damage);
		end

		if damage_meter_UI.visibility.id or damage_meter_UI.visibility.name then
			local id_name_text = "";
			
			if damage_meter_UI.visibility.id then
				id_name_text = player.id;
			end

			if damage_meter_UI.visibility.name then
				if damage_meter_UI.visibility.id then
					id_name_text = id_name_text .. " ";
				end

				id_name_text = id_name_text .. player.name;
			end
	
			if damage_meter_UI.shadows.name then
				--name shadow
				draw.text(id_name_text, screen_position.x + damage_meter_UI.offsets.name.x + damage_meter_UI.shadow_offsets.name.x, screen_position.y + damage_meter_UI.offsets.name.y + damage_meter_UI.shadow_offsets.name.y, damage_meter_UI.colors.name.shadow);
			end
			--name
			draw.text(id_name_text, screen_position.x + damage_meter_UI.offsets.name.x, screen_position.y + damage_meter_UI.offsets.name.y, damage_meter_UI.colors.name.text);
		end

		if damage_meter_UI.visibility.player_damage then
			local player_damage = string.format("%d", player.display.total_damage);
	
			if damage_meter_UI.shadows.player_damage then
				--player_damage shadow
				draw.text(player_damage, screen_position.x + damage_meter_UI.offsets.player_damage.x + damage_meter_UI.shadow_offsets.player_damage.x, screen_position.y + damage_meter_UI.offsets.player_damage.y + damage_meter_UI.shadow_offsets.player_damage.y, damage_meter_UI.colors.player_damage.shadow);
			end

			--player_damage
			draw.text(player_damage, screen_position.x  + damage_meter_UI.offsets.player_damage.x, screen_position.y  + damage_meter_UI.offsets.player_damage.y, damage_meter_UI.colors.player_damage.text);
		end

		if damage_meter_UI.visibility.player_damage_percentage then
			local player_damage_percentage_text = string.format("%5.1f%%", 100 * player_total_damage_percentage);
			
			if damage_meter_UI.shadows.player_damage_percentage then
				--player damage percentage shadow
				draw.text(player_damage_percentage_text, screen_position.x + damage_meter_UI.offsets.player_damage_percentage.x + damage_meter_UI.shadow_offsets.player_damage_percentage.x, screen_position.y + damage_meter_UI.offsets.player_damage_percentage.y + damage_meter_UI.shadow_offsets.player_damage_percentage.y, damage_meter_UI.colors.player_damage_percentage.shadow);
			end

			--player damage percentage
			draw.text(player_damage_percentage_text, screen_position.x + damage_meter_UI.offsets.player_damage_percentage.x, screen_position.y + damage_meter_UI.offsets.player_damage_percentage.y, damage_meter_UI.colors.player_damage_percentage.text);
		end
		i = i + 1;
		::continue1::

	end

	--draw total damage
	if damage_meter_UI.visibility.total_damage then
		local total_damage_text = string.format("Total Damage: " .. "%d", total.display.total_damage);

		local screen_position = calculate_screen_coordinates(damage_meter_UI.position);
		if damage_meter_UI.total_damage_offset_is_relative then
			if damage_meter_UI.orientation == "horizontal" then
				screen_position.x = screen_position.x + damage_meter_UI.spacing * i;
			else
				screen_position.y = screen_position.y + damage_meter_UI.spacing * i;
			end
		end

		if damage_meter_UI.shadows.total_damage then
			--total damage shadow
			draw.text(total_damage_text, screen_position.x + damage_meter_UI.offsets.total_damage.x + damage_meter_UI.shadow_offsets.total_damage.x, screen_position.y + damage_meter_UI.offsets.total_damage.y + damage_meter_UI.shadow_offsets.total_damage.y, damage_meter_UI.colors.total_damage.shadow);
		end

		--total damage
		draw.text(total_damage_text, screen_position.x + damage_meter_UI.offsets.total_damage.x, screen_position.y + damage_meter_UI.offsets.total_damage.y, damage_meter_UI.colors.total_damage.text);
	end
end
-----------------------DAMAGE METER UI-----------------------