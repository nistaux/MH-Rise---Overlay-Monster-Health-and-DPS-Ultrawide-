--------------------CUSTOMIZATION SECTION--------------------
local monster_UI = {
	enabled = true,

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
        --Possible values: "top_left", "top_right", "top_center", "bottom_left", "bottom_right", "bottom,center"
        anchor = "top_center"
    },

	spacing = 20,
	orientation = "horizontal", -- "vertical" or "horizontal"

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
        --Possible values: "top_left", "top_right", "bottom_left", "bottom_right"
        anchor = "top_left"
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

	include_otomo_damage = true,
	include_other_type_damage = true, -- hunting_installations, monsters

	show_module_if_total_damage_is_zero = true,
	show_player_if_player_damage_is_zero = true,

	highlight_damade_bar_of_myself = true,

	spacing = 20,
	orientation = "vertical", -- "vertical" or "horizontal"

	myself_always_first = true,
	sorting = "descending", -- "natural" or "ascending" or "descending"

	visibility = {
		name = true,
		damage_bar = true,
		player_damage = true,
		total_damage = true,
		damage_percentage = true
	},

	shadows = {
		name = true,
		damage_values = true,
		damage_percentage = true
	},

	position = {
		x = 400,
		y = 325
		 ,  
		--Possible values: "top_left", "top_right", "bottom_left", "bottom_right"
		anchor = "bottom_right"
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
		
		damage_values = {
			x = 100,
			y = 0
		},

		damage_percentage = {
			x = 205,
			y = 0
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

		damage_values = {
			x = 1,
			y = 1
		},

		damage_percentage = {
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
		
		damage_values = {
			text = 0xFFE1F4CC,
			shadow = 0xFF000000
		},

		damage_percentage = {
			text = 0xFFE1F4CC,
			shadow = 0xFF000000
		},
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
	if position.anchor == "top_left" then
		return {x = position.x, y = position.y};
	end

	if position.anchor == "top_right" then
		local screen_x = screen_width - position.x;
		return {x = screen_x, y = position.y};
	end

	if position.anchor == "bottom_left" then
		local screen_y = screen_height - position.y;
		return {x = position.x, y = screen_y};
	end

	if position.anchor == "bottom_right" then
		local screen_x = screen_width - position.x;
		local screen_y = screen_height - position.y;
		return {x = screen_x, y = screen_y};
	end

	if position.anchor == "top_center" then
		local screen_center = screen_width/2
		local total_spacing = total_monsters - 1
		local screen_x = (screen_center - ((monster_UI.health_bar.width*(total_monsters*0.5))+(monster_UI.spacing*(total_spacing*0.5))+position.x))
		return {x = screen_x, y = position.y};
	end

	if position.anchor == "bottom_center" then
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
	--log.info("test")
	--log.info(#monster_table)
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

	local total_monsters = enemy_manager:call("getBossEnemyCount");
    for i = 0, total_monsters-1 do
        local enemy = enemy_manager:call("getBossEnemy", i);
        if not enemy then
            break;
        end
		
		
        local monster = monster_table[enemy];
        if not monster then 
            status = "No hp entry";
            break;
        end
		local screen_position = calculate_screen_coordinates(monster_UI.position, total_monsters);

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
			local health_percentage_text = string.format("%3.1f%%", 100 * monster.health_percentage);

			if monster_UI.shadows.health_percentage then
				--health percentage shadow
				draw.text(health_percentage_text, screen_position.x + monster_UI.offsets.health_percentage.x + monster_UI.shadow_offsets.health_percentage.x, screen_position.y + monster_UI.offsets.health_percentage.y + monster_UI.shadow_offsets.health_percentage.y, monster_UI.colors.health_percentage.shadow);
			end
			--health percentage
			draw.text(health_percentage_text, screen_position.x + monster_UI.offsets.health_percentage.x, screen_position.y + monster_UI.offsets.health_percentage.y, monster_UI.colors.health_percentage.text);
		end
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
	local is_player = (attacker_type == 0);
	local is_otomo = (attacker_type == 19);
	local is_monster = (attacker_type == 23);

	local total_damage = enemy_calc_damage_info:call("get_TotalDamage");
	local physical_damage = enemy_calc_damage_info:call("get_PhysicalDamage");
	local elemental_damage = enemy_calc_damage_info:call("get_ElementDamage");
	local ailment_damage = enemy_calc_damage_info:call("get_ConditionDamage");
	
	-- -1 - ???
	--  0 - player
	-- 12 - ballista
	-- 13 - cannon
	-- 14 - machine cannon
	-- 16 - defender ballista/cannon
	-- 17 - wyvernfire artillery
	-- 18 - dragonator
	-- 19 - otomo
	-- 23 - monster

	local damage_source_type = "";
	if attacker_type == 0 then
		damage_source_type = "player";
	elseif attacker_type == 12 or attacker_type == 13 or attacker_type == 14 or attacker_type == 18 then
		damage_source_type = "installation";
	elseif attacker_type == 19 then
		damage_source_type = "otomo";
	elseif attacker_type == 23 then
		damage_source_type = "monster";
	end

	update_player(total, damage_source_type, total_damage, physical_damage, elemental_damage, ailment_damage);

	update_player(get_player(attacker_id), damage_source_type, total_damage, physical_damage, elemental_damage, ailment_damage);
		
	
end, function(retval) return retval; end);

function init_player(player_id, player_name)
	player = {};
	player.id = player_id;
	player.name = player_name;

	player.total_damage = 0;
	player.physical_damage = 0;
	player.elemental_damage = 0;
	player.ailment_damage = 0;
	player.total_damage_percentage = 0.0;

	player.otomo = {};
	player.otomo.total_damage = 0;
	player.otomo.physical_damage = 0;
	player.otomo.elemental_damage = 0;
	player.otomo.ailment_damage = 0;
	player.otomo.total_damage_percentage = 0.0;

	player.other = {};
	player.other.total_damage = 0;
	player.other.physical_damage = 0;
	player.other.elemental_damage = 0;
	player.other.ailment_damage = 0;
	player.other.total_damage_percentage = 0.0;


	return player;
end

total = init_player(0);

function get_player(player_id)
	if players[player_id] == nil then
		return nil;
	end

	return players[player_id];
end

function update_player(player, damage_source_type, total_damage, physical_damage, elemental_damage, ailment_damage)
	local player_damage_entity;
	local total_damage_entity;

	if damage_source_type == "player" then
		player_damage_entity = player;
		total_damage_entity = total;
	elseif damage_source_type == "otomo" then
		player_damage_entity = player.otomo;
		total_damage_entity = total.otomo;
	elseif damage_source_type == "installation" or damage_source_type == "monster" then
		player_damage_entity = player.other;
		total_damage_entity = total.other;
	else
		return;
	end

	player_damage_entity.total_damage = player_damage_entity.total_damage + total_damage;
	player_damage_entity.physical_damage =  player_damage_entity.physical_damage + physical_damage;
	player_damage_entity.elemental_damage = player_damage_entity.elemental_damage + elemental_damage;
	player_damage_entity.ailment_damage = player_damage_entity.ailment_damage + ailment_damage;
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

	if quest_status == 0 then
		players = {};
		total = init_player(0);
		return;
	end

	--total damage
	local total_damage = total.total_damage;

	if damage_meter_UI.include_otomo_damage then
		total_damage = total_damage + total.otomo.total_damage;
	end

	if damage_meter_UI.include_other_type_damage then
		total_damage = total_damage + total.other.total_damage;
	end

	if total_damage == 0 and not damage_meter_UI.show_module_if_total_damage_is_zero then
		return;
	end

	-- players in lobby
	local lobby_manager = sdk.get_managed_singleton("snow.LobbyManager");
    if lobby_manager == nil then
        status = "No lobby manager";
        return;
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

	local myself_player_id = lobby_manager:get_field("_myselfQuestIndex");
	if myself_player_id == nil then
		status = "No myself player id";
		return;
	end

	if players[myself_player_id] == nil then
		players[myself_player_id] = init_player(myself_player_id, myself_player_name);
	end

	local quest_players = {};
	table.insert(quest_players, players[myself_player_id]);

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

		if player_id == myself_player_id then
			table.remove(quest_players, 1);
		end
		
		local player_name = player_info:get_field("_name");
		if player_name == nil then
			goto continue;
		end

		if players[player_id] == nil then
			players[player_id] = init_player(player_id, player_name);
		end

		table.insert(quest_players, players[player_id]);
		::continue::
	end

	--sort here
	if damage_meter_UI.sorting == "ascending" then
		table.sort(quest_players, function(left, right)
			if damage_meter_UI.myself_always_first and left.id == myself_player_id then
				return true;
			end
			
			local left_total_damage = left.total_damage;
			local right_total_damage = right.total_damage;

			if damage_meter_UI.include_otomo_damage then
				left_total_damage = left_total_damage + left.otomo.total_damage;
				right_total_damage = right_total_damage + right.otomo.total_damage;
			end
	
			if damage_meter_UI.include_other_type_damage then
				left_total_damage = left_total_damage + left.other.total_damage;
				right_total_damage = right_total_damage + right.other.total_damage;
			end

			return left_total_damage < right_total_damage;
		end);
	elseif damage_meter_UI.sorting == "descending" then
		table.sort(quest_players, function(left, right)
			if damage_meter_UI.myself_always_first and left.id == myself_player_id then
				return true;
			end

			if damage_meter_UI.myself_always_first and right.id == myself_player_id then
				return false;
			end

			local left_total_damage = left.total_damage;
			local right_total_damage = right.total_damage;

			if damage_meter_UI.include_otomo_damage then
				left_total_damage = left_total_damage + left.otomo.total_damage;
				right_total_damage = right_total_damage + right.otomo.total_damage;
			end
	
			if damage_meter_UI.include_other_type_damage then
				left_total_damage = left_total_damage + left.other.total_damage;
				right_total_damage = right_total_damage + right.other.total_damage;
			end

			return left_total_damage > right_total_damage;
		end);
	end

	--draw
	local i = 0;
	local total_dam_spacing = damage_meter_UI.damage_bar.height + damage_meter_UI.spacing
	for _, player in ipairs(quest_players) do
		--draw
		local player_total_damage = player.total_damage;

		if damage_meter_UI.include_otomo_damage then
			player_total_damage = player_total_damage + player.otomo.total_damage;
		end

		if damage_meter_UI.include_other_type_damage then
			player_total_damage = player_total_damage + player.other.total_damage;
		end

		if player_total_damage == 0 and not damage_meter_UI.show_player_if_player_damage_is_zero then
			goto continue1;
		end

		local player_total_damage_percentage = 0;
		if total_damage ~= 0  then
			player_total_damage_percentage = player_total_damage / total_damage;
		end

		local screen_position = calculate_screen_coordinates(damage_meter_UI.position);

		if damage_meter_UI.orientation == "horizontal" then
			screen_position.x = screen_position.x + total_dam_spacing * i;
		else
			screen_position.y = screen_position.y + total_dam_spacing * i;
		end

		if damage_meter_UI.visibility.damage_bar then
			local damage_bar_player_damage_width = damage_meter_UI.damage_bar.width * player_total_damage_percentage;
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

		if damage_meter_UI.visibility.name then
			local name_text = player.name;
	
			if damage_meter_UI.shadows.name then
				--name shadow
				draw.text(name_text, screen_position.x + damage_meter_UI.offsets.name.x + damage_meter_UI.shadow_offsets.name.x, screen_position.y + damage_meter_UI.offsets.name.y + damage_meter_UI.shadow_offsets.name.y, damage_meter_UI.colors.name.shadow);
			end
			--name
			draw.text(name_text, screen_position.x + damage_meter_UI.offsets.name.x, screen_position.y + damage_meter_UI.offsets.name.y, damage_meter_UI.colors.name.text);
		end

		if damage_meter_UI.visibility.player_damage or damage_meter_UI.visibility.total_damage then
			local damage_values = "";
			if damage_meter_UI.visibility.player_damage then
				damage_values = string.format("%d", player_total_damage);
			end
	
			if damage_meter_UI.visibility.total_damage then
				if damage_meter_UI.visibility.player_damage then
					damage_values = damage_values .. "/";
				end
	
				damage_values = damage_values .. string.format("%d", total_damage);
			end
	
			if damage_meter_UI.shadows.damage_values then
				--damage values shadow
				draw.text(damage_values, screen_position.x + damage_meter_UI.offsets.damage_values.x + damage_meter_UI.shadow_offsets.damage_values.x, screen_position.y + damage_meter_UI.offsets.damage_values.y + damage_meter_UI.shadow_offsets.damage_values.y, damage_meter_UI.colors.damage_values.shadow);
			end
			--damage values
			draw.text(damage_values, screen_position.x  + damage_meter_UI.offsets.damage_values.x, screen_position.y  + damage_meter_UI.offsets.damage_values.y, damage_meter_UI.colors.damage_values.text);
		end

		if damage_meter_UI.visibility.damage_percentage then
			local damage_percentage_text = string.format("%3.1f%%", 100 * player_total_damage_percentage);
	
			if damage_meter_UI.shadows.damage_percentage then
				--health percentage shadow
				draw.text(damage_percentage_text, screen_position.x + damage_meter_UI.offsets.damage_percentage.x + damage_meter_UI.shadow_offsets.damage_percentage.x, screen_position.y + damage_meter_UI.offsets.damage_percentage.y + damage_meter_UI.shadow_offsets.damage_percentage.y, damage_meter_UI.colors.damage_percentage.shadow);
			end
			--health percentage
			draw.text(damage_percentage_text, screen_position.x + damage_meter_UI.offsets.damage_percentage.x, screen_position.y + damage_meter_UI.offsets.damage_percentage.y, damage_meter_UI.colors.damage_percentage.text);
		end
		i = i + 1;
		::continue1::
	end
end
-----------------------DAMAGE METER UI-----------------------