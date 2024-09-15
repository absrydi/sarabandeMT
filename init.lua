-------------------------------------
--           SARABANDE             --
--                                 --
--     Written by A.B. Suryadi     --
--           14/10/24              --
--                                 --
--   Copyright (C) A.B. Suryadi    --
-------------------------------------
--                                 --
-- Re-written Minetest-Lua version --
--        Based on v0.0.1          --
--                                 --
-------------------------------------


-- RESOURCES

-- node texture

images = {
	center = "speaker.png",
	top = "top.png",
	bottom = "bottom.png"
}

-- voices - The name corresponding to the audio file in the "voice" folder

voices = {
	--{audio_file, is_looped, is_ring},
	{"piano", false, false},
	{"smoothy", false, false},
	{"sparkle", false, false},
	{"rhodes", false, false},
	{"harpsichord", false, false},
	{"toypiano", false, false},
	{"montre_org", true, false},
	{"principal_org", true, false},
	{"gedackt_org", true, false},
	{"sine", true, false}, -- 10
	{"nylon_gtr", false, false},
	{"steel_gtr", false, false},
	{"bass_gtr", false, false},
	{"overdrive_gtr", false, false},
	{"trumpet", true, false},
	{"trombone", true, false},
	{"strings", true, false}
}

--[[        FOR CUSTOM VOICES SEE THIS SECTION

	voice table:
	
	{audio_file, is_looped, is_ring}
	
	audio_file
		The audio file name corresponding to the audio
		file in the "voice" folder. The audio file must
		be a mono (non-stereo) OGG audio file.
	
	is_looped
		Set the audio file to be looped. Used for voices
		with continuous sound (eg. a trumpet or flute
		sound)
	
	is_ring
		Set the audio file sustain to be on/off. Used
		for voice without stops (eg. a gong or cymbal
		sound)
--]]

-- 12-ET notes

notes = {
{"C", "C"},
{"C#", "DB"},
{"D", "D"},
{"D#", "EB"},
{"E", "E"},
{"F", "F"},
{"F#", "GB"},
{"G", "G"},
{"G#", "AB"},
{"A", "A"},
{"A#", "BB"},
{"B", "B"}}

-- non 12-ET notes

specnotes = {
"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
"BA", "BI", "BU", "BE", "BO", "CA", "CI", "CU", "CE", "CO",
"DA", "DI", "DU", "DE", "DO", "FA", "FI", "FU", "FE", "FO",
"GA", "GI", "GU", "GE", "GO", "HA", "HI", "HU", "HE", "HO",
"JA", "JI", "JU", "JE", "JO", "KA", "KI", "KU", "KE", "KO",
"LA", "LI", "LU", "LE", "LO", "MA", "MI", "MU", "ME", "MO"
}

-- dynamics

dynamics = {
{"pianissimo", "pp", 25}, 
{"piano", "p", 40}, 
{"mezzopiano", "mp", 50}, 
{"mezzoforte", "mf", 60}, 
{"forte", "f", 75}, 
{"fortissimo", "ff", 100},}

-- MUSIC INFO

-- playback

mbl = {} -- music box list

function newblock(pos)
	local nb_content = {
		box_position = {0, 0, 0},
		
		is_playing = true,
		c_beat = 0,
		c_bar = 0,
		c_line = 0,
		
		note_buffer = {}, --{note, duration, voice}
		audio_buffer = {},
		token = {},
		lines = {},
		nextline_ready = false,
		
		c_delay = 0,
		
		-- primary
		
		tsign = 4,
		tempo = 120,
		tuning = 12,
		
		-- seccondary
		
		dynamic = 100,
		transpose = 0,
		finetune = 0,
		
		-- memory
		
		var_name = {},
		var_value = {}
	}

	if type(pos) == "table" then
		nb_content.box_position = pos
		table.insert(mbl, nb_content)
	else
		old_pos = mbl[pos].box_position
		nb_content.box_position = old_pos
		mbl[pos] = nb_content
	end
end

function get_by_pos(pos)
	for i, v in pairs(mbl) do
		if v.box_position == pos then
			return i
		end
	end
end

-- FUNCTIONS

-- error messages

function error_msg(msg, n) -- wrapper
	minetest.chat_send_all("ERROR at line "..tostring(mbl[n].c_line)..": "..msg)
	is_playing = false
end

function warning_msg(msg, n) -- wrapper
	minetest.chat_send_all("WARNING at line "..tostring(mbl[n].c_line)..": "..msg)
end

-- other

function find_key_index(inp_table, key) -- find key in table, return index
	result = nil
	
	for i, v in pairs(inp_table) do
		if v == key then
			result = i
		end
	end
	
	return result
end

function sbs(text) -- Split by Space
	result = {}
	
	for i in string.gmatch(text, "%S+") do
		table.insert(result, i)
	end
	
	table.insert(result, "")
	
	return result
end

function get_notation_num(n, no)
	result = nil

	local note = string.upper(string.sub(n, 1, -2))
	local octave = tonumber(string.sub(n, #n, #n))

	local notenum = -1
	if octave ~= nil then
		if mbl[no].tuning == 12 then
			for i, v in pairs(notes) do
				if v[1] == note then
					notenum = i
        	                elseif v[2] == note then
					notenum = i
				end
			end
		else
			for i, v in pairs(specnotes) do
				if v == note then
					notenum = i
				end
			end
		end
	end
	
	result = notenum + octave * mbl[no].tuning
	return result
end

function getvar(name, n)
	result = nil
	
	for i, v in pairs(mbl[n].var_name) do
		if v == name then
			result = mbl[n].var_value[i]
			break
		end
	end
	
	return result
end

function isCharInTable(tbl, chr)
	for i, v in pairs(tbl) do
		if v == chr then
			return true
		end
	end
end

-- play audio

function play_note_buffer(n)
	for i, v in pairs(mbl[n].note_buffer) do
		table.insert(mbl[n].audio_buffer, {minetest.sound_play({
			name = voices[v[3]][1]
		}, {
			pos = mbl[n].box_position,
			gain = mbl[n].dynamic / 100,
			pitch = (2^(1 / mbl[n].tuning))^(v[1] + mbl[n].transpose + (mbl[n].finetune / 100)) / 16,
			loop = voices[v[3]][2],
			max_hear_distance = 1024
		}),
			minetest.get_us_time() + ((60 / mbl[n].tempo) * v[2]) * 1000000 -- duration
		})
	end
	
	mbl[n].note_buffer = {}
end

function check_note_end(n)
	for i, v in pairs(mbl[n].audio_buffer) do
		if v[2] <= minetest.get_us_time() then
			minetest.sound_stop(mbl[n].audio_buffer[i][1])
			table.remove(mbl[n].audio_buffer, i)
		end
	end
end

function end_all_note(n)
	for i, v in pairs(mbl[n].audio_buffer) do
		minetest.sound_stop(mbl[n].audio_buffer[i][1])
	end
	mbl[n].audio_buffer = {}
end

function waiter(bts, n)
	--[[
	local target = minetest.get_us_time() + ((60 / tempo) * bts) * 1000000
	while target > minetest.get_us_time() do
		check_note_end()
	end]]
	
	mbl[n].c_delay = minetest.get_us_time() + ((60 / mbl[n].tempo) * bts) * 1000000
end

function micro_wait(t)
	local a = minetest.get_us_time() + t * 1000000
	while a < minetest.get_us_time() do
		-- wait here
	end
end

-- INTERPRETATION

-- pre-interpretation

function microfuncts(n)
	if mbl[n].token[1] ~= "##" then
		-- Preprocessing command
		
		dynamicsExist = false
		(function()
			for i, v in pairs(mbl[n].token) do
				for j, f in pairs(dynamics) do
					if v == f[1] or v == f[2] then
						dynamicsExist = true
						return
					end
				end
			end
		end)()
		
		while dynamicsExist do -- Dynamics Preprocess
			dynamicsExist = false
			for i, v in pairs(mbl[n].token) do
				for j, f in pairs(mbl[n].dynamics) do
					if v == f[1] or v == f[2] then
						mbl[n].token[i] = f[3]
						dynamicsExist = true
					end
				end
			end
		end
		
		while isCharInTable(mbl[n].token, "getvar") or isCharInTable(mbl[n].token, "gv") do -- getvar Command
			for i, v in pairs(mbl[n].token) do
				if (v == "getvar" or v == "gv") then
					if getvar(mbl[n].token[i + 1], n) ~= nil then
						mbl[n].token[i] = getvar(mbl[n].token[i + 1], n)
						table.remove(mbl[n].token, i + 1)
					else
						error_msg("Unknown variable", n)
					end
				end
			end
		end

		-- Aritmathic Operations

		while isCharInTable(mbl[n].token, "*") or isCharInTable(mbl[n].token, "/") do -- Multipication and Division
			for i, v in pairs(mbl[n].token) do
				if v == "*" then
					mbl[n].token[i] = mbl[n].token[i + 1] * mbl[n].token[i - 1]
					table.remove(mbl[n].token, i + 1)
					table.remove(mbl[n].token, i - 1)
				end
				if v == "/" then
					mbl[n].token[i] = mbl[n].token[i - 1] / mbl[n].token[i + 1]
					table.remove(mbl[n].token, i + 1)
					table.remove(mbl[n].token, i - 1)
				end
			end
		end
	
		while isCharInTable(mbl[n].token, "+") or isCharInTable(mbl[n].token, "-") do -- Addition and Subtraction
			for i, v in pairs(mbl[n].token) do
				if v == "+" then
					mbl[n].token[i] = mbl[n].token[i + 1] + mbl[n].token[i - 1]
					table.remove(mbl[n].token, i + 1)
					table.remove(mbl[n].token, i - 1)
				end
				if v == "-" then
					mbl[n].token[i] = mbl[n].token[i - 1] - mbl[n].token[i + 1]
					table.remove(mbl[n].token, i + 1)
					table.remove(mbl[n].token, i - 1)
				end
			end
		end
	end
end

-- interpretation

function interpret(n)
	mbl[n].c_line = mbl[n].c_line + 1
	
	microfuncts(n)
	
	if mbl[n].token[1] == "time" then
		if tonumber(mbl[n].token[2]) ~= nil then
			mbl[n].time = math.abs(tonumber(mbl[n].token[2]))
		else
			error_msg("Unknown time signature", n)
		end
	elseif mbl[n].token[1] == "tempo" then
		if tonumber(mbl[n].token[2]) ~= nil then
			mbl[n].tempo = math.abs(tonumber(mbl[n].token[2]))
		else
			error_msg("Unknown tempo", n)
		end
	elseif mbl[n].token[1] == "tuning" then
		if tonumber(mbl[n].token[2]:sub(1, -4)) ~= nil then
			mbl[n].tuning = math.abs(tonumber(mbl[n].token[2]:sub(1, -4)))
		else
			error_msg("Unknown tuning system "..mbl[n].token[2]:sub(1, -4), n)
		end
	elseif mbl[n].token[1] == "setvar" then
		if mbl[n].token[2] ~= nil and tonumber(mbl[n].token[3]) ~= nil then
			local index = find_key_index(mbl[n].var_name, mbl[n].token[2])
			if index ~= nil then
				mbl[n].var_value[index] = tonumber(mbl[n].token[3])
			else
				table.insert(mbl[n].var_name, mbl[n].token[2])
				table.insert(mbl[n].var_value, tonumber(mbl[n].token[3]))
			end
		else
			error_msg("Incorrect setvar command", n)
		end
	elseif mbl[n].token[1] == "remvar" then
		if mbl[n].token[2] ~= nil then
			local index = find_key_index(mbl[n].var_name, mbl[n].token[2])
			if index ~= nil then
				mbl[n].var_value[index] = nil
				mbl[n].var_name[index] = nil
			else
				error_msg("Unknown variable", n)
			end
		else
			error_msg("Incorrect remvar command", n)
		end
	elseif mbl[n].token[1] == "next" then
		if tonumber(mbl[n].token[2]) ~= nil then
			play_note_buffer(n)
			waiter(tonumber(mbl[n].token[2]), n)
			
			if tonumber(mbl[n].token[2]) + mbl[n].c_beat > mbl[n].time then
				mbl[n].c_beat = (tonumber(mbl[n].token[2]) + mbl[n].c_beat) % mbl[n].time
				mbl[n].c_bar = mbl[n].c_bar + math.floor((tonumber(mbl[n].token[2]) + mbl[n].c_beat) / mbl[n].time)
			else
				mbl[n].c_beat = tonumber(mbl[n].token[2]) + mbl[n].c_beat
			end
		else
			error_msg("Incorrect beat amount", n)
		end
	elseif mbl[n].token[1] == "note" then
		if (mbl[n].token[2] ~= nil and tonumber(mbl[n].token[3]) ~= nil) and tonumber(mbl[n].token[4]) ~= nil then
			local note_node = {1, tonumber(mbl[n].token[3]), 1}
		
			local note_num = get_notation_num(mbl[n].token[2], n)
			if note_num ~= nil then
				note_node[1] = note_num
			else
				error_msg("Unknown note name", n)
			end
			
			if tonumber(mbl[n].token[4]) <= #voices then
				note_node[3] = tonumber(mbl[n].token[4])
			else
				error_msg("Unknown voice index", n)
			end
			
			table.insert(mbl[n].note_buffer, note_node)
		else
			error_msg("Incorrect note command", n)
		end
	elseif mbl[n].token[1] == "dynamics" then
		if tonumber(mbl[n].token[2]) ~= nil then
			dynamic = math.abs(tonumber(mbl[n].token[2]))
		else
			error_msg("Incorrect dynamics command", n)
		end
	elseif mbl[n].token[1] == "transpose" then
		if tonumber(mbl[n].token[2]) ~= nil then
			mbl[n].transpose = math.abs(tonumber(mbl[n].token[2]))
		else
			error_msg("Incorrect transpose command", n)
		end
	elseif mbl[n].token[1] == "finetune" then
		if tonumber(mbl[n].token[2]) ~= nil then
			mbl[n].finetune = math.abs(tonumber(mbl[n].token[2]))
		else
			error_msg("Incorrect finetune command", n)
		end
	elseif mbl[n].token[1] == "end" then
		
	elseif mbl[n].token[1] == "##" or mbl[n].token[1] == "" then
		-- ignore comments
	else
		error_msg("Unknown command", n)
	end
	--]]
	
	minetest.chat_send_all(mbl[n].token[1])
end

-- globalstep

minetest.register_globalstep(function(dtime)
	for i, v in pairs(mbl) do
		for j = 1, 8, 1 do
			if mbl[i].c_delay < minetest.get_us_time() --[[and c_delay ~= 0]] then
				if mbl[i].nextline_ready and mbl[i].is_playing and mbl[i].c_line < #(mbl[i].lines) then
				
					mbl[i].token = sbs(mbl[i].lines[mbl[i].c_line + 1])
					--minetest.chat_send_all("boom")
					interpret(i)
				else
					mbl[i].is_playing = false
					end_all_note(i)
					newblock(i)
					--minetest.chat_send_all("BRO")
				end
			else
				check_note_end(i)
			end
			
			micro_wait(0.0125)
		end
	end
end)

-- NODE REGISTRATION

minetest.register_node("sarabande:music_box", {
	description = "Music Box",
	paramtype = "light",
	drawtype = "nodebox",
	tiles = {images.top, 
		images.bottom, 
		images.center, 
		images.center, 
		images.center, 
		images.center},
	nodebox = {
		type = "fixed",
		fixed = {
		    {-0.45, -0.5, -0.45,  0.45, -0.3,  0.45}
		}
	},
	
	paramtype2 = "facedir",
	groups = {cracky=2},
	
	--[[on_place = function(itemstack, placer, pointed_thing)
		newblock(pointed_thing.above)
		minetest.place_node(pos, itemstack.name)
	end,]]
	
	--[[on_dig = function(pos, node, digger)
		table.remove(mbl, get_by_pos(pos))
		minetest.dig_node(pos)
	end,]]
	
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if itemstack:get_name() == "default:book_written" and minetest.get_meta(pos):get_string("infotext") == "Empty" then
			--local inv = minetest.get_inventory({type="player", name=puncher:get_player_name()}):get_list("main")
			--minetest.chat_send_all(itemstack:get_name().."  "..itemstack:get_meta():get_string("title"))
			minetest.get_meta(pos):set_string("infotext", itemstack:get_meta():get_string("title").." by "..itemstack:get_meta():get_string("owner"))
			
			newblock(pos)
			mbl[get_by_pos(pos)].nextline_ready = true
			for line in itemstack:get_meta():get_string("text"):gmatch("([^\n]*)\n?") do
				table.insert(mbl[get_by_pos(pos)].lines, line)
			end
			--minetest.chat_send_all(tostring(mbl[get_by_pos(pos)].is_playing))
			--minetest.chat_send_all(tostring(mbl[get_by_pos(pos)].lines))
		else
			--minetest.chat_send_all("STOP")
			if get_by_pos(pos) ~= nil then
				end_all_note(get_by_pos(pos))
			end
			minetest.get_meta(pos):set_string("infotext", "Empty")
			--mbl[get_by_pos(pos)].is_playing = false
			table.remove(mbl, get_by_pos(pos))
		end
		
		--[[if mbl[get_by_pos(pos)].is_playing == false then
			minetest.get_meta(pos):set_string("infotext", "Empty")
			table.remove(mbl, get_by_pos(pos))
		end]]
	end,
})

minetest.register_craft({
	output = 'sarabande:music_box',
	recipe = {
		{'default:steel_ingot', 'default:obsidian_glass', 'default:steel_ingot'},
		{'wool:black', 'default:mese_crystal', 'wool:black'},
		{'wool:black', 'default:book', 'wool:black'},
	},
})