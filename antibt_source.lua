--credit dc lc_teleport OR tg ilyanezuh
local sv_ui = ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks2")
local fl = ui.reference("AA", "Fake lag", "Limit")
local hotkey = ui.new_hotkey("LUA", "B", "Exploit")
local dt_ref, dt_key = ui.reference("RAGE", "Aimbot", "Double tap")
local aa_enabled_ref = ui.reference("AA", "Anti-aimbot angles", "Enabled")
local air_duck = ui.reference("MISC", "Movement", "Air duck")
local function lerp(a, b, t)
    return a + (b - a) * t
end


local client_draw_rectangle, client_draw_circle_outline, client_set_event_callback, client_screen_size, client_draw_indicator, client_eye_position = client.draw_rectangle, client.draw_circle_outline, client.set_event_callback, client.screen_size, client.draw_indicator, client.eye_position
local client_draw_hitboxes, client_get_cvar, client_draw_line, client_camera_angles, client_world_to_screen = client.draw_hitboxes, client.get_cvar, client.draw_line, client.camera_angles, client.world_to_screen
local entity_get_local_player, entity_get_prop, entity_get_players, entity_get_all = entity.get_local_player, entity.get_prop, entity.get_players, entity.get_all
local globals_tickcount = globals.tickcount
local ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_set_visible, ui_set_callback, ui_get = ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.set_visible, ui.set_callback, ui.get
local math_sqrt, math_max, math_min, math_rad, math_cos, math_sin, math_floor = math.sqrt, math.max, math.min, math.rad, math.cos, math.sin, math.floor
local renderer_text, renderer_measure_text = renderer.text, renderer.measure_text
local position_enabled_reference = ui_new_combobox("LUA", "B", "Show position", "Off", "Hitboxes", "Point")
local position_color_reference = ui_new_color_picker("LUA", "B", "Show position", 64, 73, 83, 255)
local movement_improved_checkbox = ui.new_checkbox("LUA", "B", "Movement Improved")
local amount_combobox = ui.reference("AA", "Fake lag", "Amount")
local limit_slider = ui.reference("AA", "Fake lag", "Limit")
local variance_slider = ui.reference("AA", "Fake lag", "Variance")

local fakelag_maximum = 14
local choked_ticks = 0
local choked_ticks_max = 0
local choked_ticks_prev = 0
local cross_size = 4
local hitbox_duration = 0.5
local in_third_person = false
local pos_x, pos_y, pos_z

local script_enabled_checkbox = ui.new_checkbox("LUA", "A", "ENABLEEEE ◣__◢")

local function is_thirdperson(ctx)
    local x, y, z = client_eye_position()
    local pitch, yaw = client_camera_angles()
    yaw = yaw - 180
    pitch, yaw = math_rad(pitch), math_rad(yaw)
    x = x + math_cos(yaw)*4
    y = y + math_sin(yaw)*4
    z = z + math_sin(pitch)*4
    local wx, wy = client_world_to_screen(ctx, x, y, z)
    return wx ~= nil
end

local function draw_indicator_circle(ctx, x, y, r, g, b, a, percentage, outline)
    local outline = outline == nil and true or outline
    local radius = 9
    local start_degrees = 0
    if outline then
        client_draw_circle_outline(ctx, x, y, 0, 0, 0, 200, radius, start_degrees, 1.0, 5)
    end
    client_draw_circle_outline(ctx, x, y, r, g, b, a, radius-1, start_degrees, percentage, 3)
end

local function lc_indicator_drawn()
    local local_player = entity_get_local_player()
    local vel_x, vel_y = entity_get_prop(local_player, "m_vecVelocity")
    if vel_x then
        local vel = math_sqrt(vel_x*vel_x + vel_y*vel_y)
        if vel > 280 then
            return true
        end
    end
    return false
end

local function on_run_command(e)
    choked_ticks = e.chokedcommands
    if choked_ticks_prev >= choked_ticks or choked_ticks == 0 then
        if choked_ticks_prev > 1 then
            if ui_get(hotkey) then
                local position_enabled = ui_get(position_enabled_reference)
                if position_enabled ~= "Off" then
                    local r, g, b, a = ui_get(position_color_reference)
                    local local_player = entity_get_local_player()
                    pos_x, pos_y, pos_z = entity_get_prop(local_player, "m_vecOrigin")
                    if position_enabled == "Hitboxes" then
                        if in_third_person then
                            client_draw_hitboxes(local_player, hitbox_duration, 19, r, g, b)
                        end
                    end
                end
            end
        end
        choked_ticks_max = choked_ticks_prev
    end
    choked_ticks_prev = choked_ticks
end
client_set_event_callback("run_command", on_run_command)

local function on_paint(ctx)
    local local_player = entity_get_local_player()
    if local_player == nil or entity_get_prop(local_player, "m_lifeState") ~= 0 then
        return
    end
    local game_rules_proxy = entity_get_all("CCSGameRulesProxy")[1]
    if game_rules_proxy == nil then
        return
    end
    if entity_get_prop(game_rules_proxy, "m_bFreezePeriod") == 1 then
        return
    end
    local round_over = entity_get_prop(game_rules_proxy, "m_iRoundWinStatus") ~= 0
    if round_over and (#entity_get_players(true) == 0) then
        return
    end
end
client_set_event_callback("paint", on_paint)

local function update_fake_lag_section_visibility()
    local enabled = ui.get(script_enabled_checkbox)
    ui.set_visible(position_enabled_reference, enabled)
    ui.set_visible(position_color_reference, enabled)
    ui.set_visible(movement_improved_checkbox, enabled)
    ui.set_visible(hotkey, enabled)
    if enabled then
        ui.set(amount_combobox, "Maximum")
        ui.set(variance_slider, 0)
    end
    ui.set_visible(amount_combobox, not enabled)
    ui.set_visible(limit_slider, not enabled)
    ui.set_visible(variance_slider, not enabled)
    if not enabled then
        ui.set_visible(variance_slider, true)
    end
end
ui.set_callback(script_enabled_checkbox, update_fake_lag_section_visibility)
update_fake_lag_section_visibility()

client.set_event_callback("paint", function()
    if not ui.get(script_enabled_checkbox) then return end
    local dt_on = ui.get(dt_ref) and ui.get(dt_key)
    if dt_on then
        cvar.sv_maxusrcmdprocessticks:set_int(16, true)
        ui.set(fl, 15)
        return
    end

    local is_on = ui.get(hotkey)
    local spam_enabled = ui.get(movement_improved_checkbox)
    if is_on then
        ui.set(sv_ui, 19)
        cvar.sv_maxusrcmdprocessticks:set_int(19, true)
        ui.set(fl, 18)
        ui.set(aa_enabled_ref, false)
        client.exec("+use")
        if spam_enabled then
            ui.set(air_duck, "Spam")
        end
        local screen_w, screen_h = client_screen_size()
        local lp = entity.get_local_player()
        if lp then
            local vx, vy = entity.get_prop(lp, "m_vecVelocity")
            local speed = 0
            if vx and vy then
                speed = math.sqrt(vx * vx + vy * vy)
            end
            local function iridescent_letter_color(i, len, time)
                local phase = (math.sin(time * 2 + i * 0.35) + 1) / 2
                local r = math.floor(220 + (255-220) * phase)
                local g = math.floor(160 + (255-160) * phase)
                local b = math.floor(255 - (255-255) * phase + (255-255) * (1-phase))
                return r, g, b
            end
            local time = globals.realtime and globals.realtime() or 0
            local function draw_fancy_text(text, y)
                local total_w = 0
                local chars = {text:byte(1, #text)}
                local x_start = 0
                for i = 1, #text do
                    local c = text:sub(i, i)
                    local w = renderer_measure_text(nil, c)
                    total_w = total_w + w
                end
                x_start = math.floor(screen_w / 2 - total_w / 2)
                local x = x_start
                for i = 1, #text do
                    local c = text:sub(i, i)
                    local w, h = renderer_measure_text(nil, c)
                    local r, g, b = iridescent_letter_color(i, #text, time)
                    renderer_text(x, y, r, g, b, 255, nil, 0, c)
                    x = x + w
                end
            end
            local text = "LC Break"
            local text_w, text_h = renderer_measure_text(nil, text)
            local y = screen_h - text_h - 30
            draw_fancy_text(text, y)
            if speed > 270 then
                local text2 = "Ideal Break"
                local text2_w, text2_h = renderer_measure_text(nil, text2)
                local y2 = y - text2_h - 8
                draw_fancy_text(text2, y2)
            end
        end
        local position_enabled = ui_get(position_enabled_reference)
        if position_enabled ~= "Off" then
            in_third_person = is_thirdperson(ctx)
            if in_third_person and position_enabled == "Point" then
                if pos_x == nil then
                    return
                end
                local r, g, b, a = ui_get(position_color_reference)
                local wx1, wy1 = client_world_to_screen(ctx, pos_x-cross_size, pos_y, pos_z)
                local wx2, wy2 = client_world_to_screen(ctx, pos_x+cross_size, pos_y, pos_z)
                if wx1 ~= nil and wx2 ~= nil then
                    client_draw_line(ctx, wx1, wy1, wx2, wy2, r, g, b, a)
                end
                wx1, wy1 = client_world_to_screen(ctx, pos_x, pos_y-cross_size, pos_z)
                wx2, wy2 = client_world_to_screen(ctx, pos_x, pos_y+cross_size, pos_z)
                if wx1 ~= nil and wx2 ~= nil then
                    client_draw_line(ctx, wx1, wy1, wx2, wy2, r, g, b, a)
                end
                local wx, wy = client_world_to_screen(ctx, pos_x, pos_y, pos_z)
                if wx ~= nil then
                    client.draw_circle(ctx, wx, wy, 16, 16, 16, 255, 2, 0, 1)
                end
            end
        end
    else
        ui.set(sv_ui, 16)
        cvar.sv_maxusrcmdprocessticks:set_int(16, true)
        ui.set(fl, 14)
        ui.set(aa_enabled_ref, true)
        client.exec("-use")
        if spam_enabled then
            ui.set(air_duck, "Off")
        end
        return
    end
    
    if false then
        local cmd = client.cmd_number()
        local view_matrix = renderer.world_to_screen(1, 1, 1)
    end
    
    if not is_on then
        return
    end

    local lp = entity.get_local_player()
    if not lp then return end
    local vx, vy = entity.get_prop(lp, "m_vecVelocity")
    if not vx or not vy then return end

    local speed = math.sqrt(vx * vx + vy * vy)
    local t = math.min(speed / 310, 1)
    local r = math.floor(lerp(255, 138, t))
    local g = math.floor(lerp(0, 194, t))
    local b = math.floor(lerp(0, 35, t))
end)