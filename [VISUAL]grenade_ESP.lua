require("library")
local images = require("gamesense/images")
local csgo_weapons = require("gamesense/csgo_weapons")
local nades = { "weapon_hegrenade", "weapon_smokegrenade", "weapon_flashbang", "weapon_incgrenade" }
local ammo_ref = ui.reference("VISUALS", "Player ESP", "Ammo")
local weapon_list = {}
local table_insert = table.insert
local YPOS = nil

client.set_event_callback("player_connect_full", function(e)
	weapon_list = {}
end)

local menu = {
	enabled = ui.new_checkbox("VISUALS", "Player ESP", "Show utility customisation"),
	label1 = ui.new_label("VISUALS", "Player ESP", "Has utility color: "),
	yes = ui.new_color_picker("VISUALS", "Player ESP", "\nHas utility color: ", 255, 255, 255, 180),
	label2 = ui.new_label("VISUALS", "Player ESP", "Has no utility color: "),
	no = ui.new_color_picker("VISUALS", "Player ESP", "\nHas no utility color: ", 255, 255, 255, 45),
}

local reset = ui.new_button("VISUALS", "Player ESP", "Reset", function()
	ui.set(menu.yes, 255, 255, 255, 180)
	ui.set(menu.no, 255, 255, 255, 45)
end)

local icons = {
	frag = images.get_weapon_icon(nades[1]),
	smoke = images.get_weapon_icon(nades[2]),
	flash = images.get_weapon_icon(nades[3]),
	incen = images.get_weapon_icon(nades[4]),
}

local sizes = {
	frag = { icons.frag:measure() },
	smoke = { icons.smoke:measure() },
	flash = { icons.flash:measure() },
	incen = { icons.incen:measure() },
}

local function includes(table, key)
	for i=1, #table do
		if table[i] == key then
			return true
		end
	end
	return false
end

local function on_paint()
	local enemies = entity.get_players(true)
	for i=1, #enemies do
		while #weapon_list < enemies[i] do
			table_insert(weapon_list, "")
		end
		local entindex = enemies[i]
		local entobj = Player(entindex)
		local entweapons = entobj:get_all_weapons()
		local player_weapon_list = {}
		for i = 1, #entweapons do
			local weapon = entweapons[i]
			local weapon_name = weapon:get_name()
			table_insert(player_weapon_list, weapon_name)
		end
		weapon_list[enemies[i]] = player_weapon_list
	
	local has_color = { ui.get(menu.yes) }
	local has_not_color = { ui.get(menu.no) }
	
	local box = { entity.get_bounding_box(entindex) }
		if box[1] == nil then return end

		if weapon_list[enemies[i]] == nil then return false end
		
		if ui.get(ammo_ref) then
			YPOS = box[4] + 5
		else
			YPOS = box[4]
		end
	
		if includes(weapon_list[enemies[i]], "HE Grenade") then
			icons.frag:draw(box[3] + 10, YPOS, sizes.frag[1] / 1.25, sizes.frag[2] / 1.25, has_color[1], has_color[2], has_color[3], has_color[4], true)
		elseif weapon_list[ent] == nil then
			icons.frag:draw(box[3] + 10, YPOS, sizes.frag[1] / 1.25, sizes.frag[2] / 1.25, has_not_color[1], has_not_color[2], has_not_color[3], has_not_color[4], true)
		end
		if includes(weapon_list[enemies[i]], "Smoke") then
			icons.smoke:draw(box[3] + 30, YPOS, sizes.smoke[1] / 1.25, sizes.smoke[2] / 1.25, has_color[1], has_color[2], has_color[3], has_color[4], true)
		elseif weapon_list[ent] == nil then
			icons.smoke:draw(box[3] + 30, YPOS, sizes.smoke[1] / 1.25, sizes.smoke[2] / 1.25, has_not_color[1], has_not_color[2], has_not_color[3], has_not_color[4], true)
		end
		if includes(weapon_list[enemies[i]], "Flashbang") then
			icons.flash:draw(box[3] + 39, YPOS, sizes.flash[1] / 1.25, sizes.flash[2] / 1.25, has_color[1], has_color[2], has_color[3], has_color[4], true)
		elseif weapon_list[ent] == nil then
			icons.flash:draw(box[3] + 39, YPOS, sizes.flash[1] / 1.25, sizes.flash[2] / 1.25, has_not_color[1], has_not_color[2], has_not_color[3], has_not_color[4], true)
		end
		if includes(weapon_list[enemies[i]], "Incendiary") or includes(weapon_list[enemies[i]], "Molotov") then
			icons.incen:draw(box[3] + 60, YPOS, sizes.incen[1] / 1.25, sizes.incen[2] / 1.25, has_color[1], has_color[2], has_color[3], has_color[4], true)
		elseif weapon_list[ent] == nil then
			icons.incen:draw(box[3] + 60, YPOS, sizes.incen[1] / 1.25, sizes.incen[2] / 1.25, has_not_color[1], has_not_color[2], has_not_color[3], has_not_color[4], true)
		end
	end
end
client.set_event_callback("paint", on_paint)

local function visibility()
	local enabled = ui.get(menu.enabled)
	ui.set_visible(menu.label1, enabled)
	ui.set_visible(menu.no, enabled)
	ui.set_visible(menu.label2, enabled)
	ui.set_visible(menu.yes, enabled)
	ui.set_visible(reset, enabled)
end
client.set_event_callback("pre_render", visibility)

client.set_event_callback("shutdown", function()
	database.write("has", ui.get(menu.yes))
	database.write("hasnot", ui.get(menu.no))
end)

if database.read("has") == nil then
	ui.set(menu.yes, 255, 255, 255, 180)
else
	ui.set(menu.yes, database.read("has"))
end

if database.read("hasnot") == nil then
	ui.set(menu.no, 255, 255, 255, 45)
else
	ui.set(menu.no, database.read("hasnot"))
end