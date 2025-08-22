--credits dc gemasense
local k = ui.reference("AA", "Anti-aimbot angles", "Enabled")local a, a1 = ui.reference("AA", "Anti-aimbot angles", "Pitch")local b, b1 = ui.reference("AA", "Anti-aimbot angles", "Yaw")local c = ui.reference("AA", "Anti-aimbot angles", "Yaw base")local d = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")local e, e1 = ui.reference("AA", "Anti-aimbot angles", "Body yaw")local f = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw")local f1 = ui.reference("AA", "Anti-aimbot angles", "Edge yaw")local f2, f2_ref = ui.reference("AA", "Anti-aimbot angles", "Freestanding")local f3 = ui.reference("AA", "Anti-aimbot angles", "Roll")ui.set_visible(k, false)ui.set_visible(a, false)ui.set_visible(b, false)ui.set_visible(b1, false)ui.set_visible(c, false)ui.set_visible(d, false)ui.set_visible(e, false)ui.set_visible(e1, false)ui.set_visible(f, false)ui.set_visible(f1, false)ui.set_visible(f2, true)ui.set_visible(f3, false)ui.set_visible(a1, false)
local ref_label = ui.new_label("AA", "Anti-aimbot angles", "\aAFC0DBFFFLICKER")
local fl = ui.reference("AA", "Fake lag", "Limit")
local flype = ui.reference("AA", "Fake lag", "Amount")
local airlag_checkbox = ui.new_hotkey("AA", "Anti-aimbot angles", "\aFFC96BFFFlick exploit")
local flip = ui.new_hotkey("AA", "Anti-aimbot angles", "\aFFC96BFFFlip sides")
local slider2 = ui.new_slider("AA", "Anti-aimbot angles", "\aFFC96BFFFlick pitch", -89, 89, 89)
local edgeyaw = ui.new_hotkey("AA", "Anti-aimbot angles", "\aFFC96BFFEdge yaw")
local flick_arrow_enable = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFC96BFFFlick arrow")
local flick_arrow_color = ui.new_color_picker("AA", "Anti-aimbot angles", "Flick arrow color", 255, 255, 255, 255)
local rage, ragehtk = ui.reference("RAGE", "Aimbot", "Enabled")
local fd_ref = ui.reference("RAGE", "Other", "Duck peek assist")
local body_yaw, body_yaw_value = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
local yaw, yaw_value = ui.reference("AA", "Anti-aimbot angles", "Yaw")
local pitch, pitch_value = ui.reference("AA", "Anti-aimbot angles", "Pitch")
local dt_ref, dt_htk = ui.reference("RAGE", "Aimbot", "Double tap")
local aa_ref = ui.reference("AA", "Anti-aimbot angles", "Enabled")
local pitchup = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFC96BFFPitch up in air")
local auto_dir = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFC96BFFAuto direction")
local spam = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFC96BFFSpam airduck")
local spamduck = ui.reference("MISC", "Movement", "Air duck")
local sv_ui = ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks2")
local dtfllimit = ui.reference("RAGE", "Aimbot", "Double tap fake lag limit")
local bypass = [[
    local game_rule = ffi_cast("intptr_t**", ffi_cast("intptr_t", client_find_signature("client.dll", "\\x83\\x3D\\xCC\\xCC\\xCC\\xCC\\xCC\\x74\\x2A\\xA1")) + 2)[0]
]]
local function is_moving_left()
    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then return false end
    local vx, vy, _ = entity.get_prop(lp, "m_vecVelocity")
    if not vx or not vy then return false end
    local speed_sq = vx * vx + vy * vy
    if speed_sq < 20 then return false end
    local speed = math.sqrt(speed_sq)
    local norm_vx = vx / speed
    local norm_vy = vy / speed
    local _, yaw = client.camera_angles()
    local yaw_rad = math.rad(yaw)
    local left_x = -math.cos(yaw_rad - math.pi / 2)
    local left_y = -math.sin(yaw_rad - math.pi / 2)
    local dot = norm_vx * left_x + norm_vy * left_y
    return dot > 0.25
end
client.set_event_callback("setup_command", function()
    if not ui.get(auto_dir) then 
        ui.set(flip, "Toggle") 
    else
    if is_moving_left() then
        ui.set(flip, "Always on")
    else
        ui.set(flip, "Toggle")
    end
end
end)
local tick_counter = 0
local function is_player_in_air()
    local lp = entity.get_local_player()
    if not lp then return false end
    local flags = entity.get_prop(lp, "m_fFlags")
    if flags == nil then return false end
    return bit.band(flags, 1) == 0
end
local function is_ducking()
    local lp = entity.get_local_player()
    if not lp then return false end
    local duck_amt = entity.get_prop(lp, "m_flDuckAmount")
    return duck_amt ~= nil and duck_amt > 0.75
end
client.set_event_callback("setup_command", function()
    local peach = ui.get(slider2)
    local lp = entity.get_local_player()
    if not lp then return false end
    local vx, vy, vz = entity.get_prop(lp, "m_vecVelocity")
    local speed = math.sqrt(vx * vx + vy * vy)
    if not ui.get(airlag_checkbox) then
        ui.set(dtfllimit, 1)
        ui.set(sv_ui, 16)
        ui.set(fl, 15) 
        ui.set(rage, true)
        allow_send_packets = true
        ui.set(yaw_value, 0)
        ui.set(pitch, "Down")
        ui.set(spamduck, "Off")
        ui.set(flype, "Maximum")
        ui.set(f2_ref, "Always on")
        ui.set(dt_htk, "Toggle")
        ui.set(fd_ref, "Toggle")
        if ui.get(edgeyaw) then
        ui.set(f1, true)
        end
        return
    end
    ui.set(aa_ref, true)
    ui.set(rage, true)
    ui.set(body_yaw, "Static")
    tick_counter = tick_counter + 1
    if tick_counter % 3 == 0 then
        ui.set(dtfllimit, 5)
        ui.set(flype, "Fluctuate")
        ui.set(f2_ref, "On hotkey")
        allow_send_packets = false
        ui.set(f1, false)
        if globals.tickcount() % 6 == 0 then
            ui.set(sv_ui, 17)
            ui.set(fl, 10)
            else
            ui.set(sv_ui, 11)
            ui.set(fl, 1)
            end
        ui.set(dt_ref, true)
        ui.set(dt_htk, "Always on")
        ui.set(pitch, "Custom")
        ui.set(rage, true)
        ui.set(fd_ref, "Always on")
        ui.set(spamduck, "Off")
        ui.set(pitch_value, peach)
        if ui.get(flip) then
            ui.set(body_yaw_value, 180)
            if is_ducking() then
                ui.set(yaw_value, 90) -- DUCK
            else
            if is_player_in_air() then
                ui.set(yaw_value, 90) -- AIR
                if ui.get(pitchup) then
                    ui.set(pitch, "Up")
                end
            else
                if speed >= 80 then
                    ui.set(dtfllimit, 1)
                    ui.set(sv_ui, 16)
                    ui.set(fl, 9)
                    ui.set(yaw_value, 90) -- RUN
                elseif speed >= 30 then
                    ui.set(dtfllimit, 1)
                    ui.set(sv_ui, 16)
                    ui.set(fl, 9)
                    ui.set(yaw_value, 143) -- SLOWWALK
                else
                    ui.set(dtfllimit, 1)
                    ui.set(sv_ui, 16)
                    ui.set(fl, 9)
                    ui.set(yaw_value, 68) -- STATIC
                end
            end
        end
        else
            ui.set(body_yaw_value, -180)
            if is_ducking() then
                ui.set(yaw_value, -90)
            else
            if is_player_in_air() then
                ui.set(yaw_value, -90)
                if ui.get(pitchup) then
                    ui.set(pitch, "Up") 
                end
            else
                if speed >= 80 then
                    ui.set(dtfllimit, 1)
                    ui.set(sv_ui, 16)
                    ui.set(fl, 9)
                    ui.set(yaw_value, -90)
                elseif speed >= 30 then
                    ui.set(dtfllimit, 1)
                    ui.set(sv_ui, 16)
                    ui.set(fl, 9)
                    ui.set(yaw_value, -143)
                else
                    ui.set(dtfllimit, 1)
                    ui.set(sv_ui, 16)
                    ui.set(fl, 9)
                    ui.set(yaw_value, -68)
                end
            end     
        end   
    end
    else
        if is_player_in_air() then
            ui.set(sv_ui, 17)
            ui.set(fl, 1)
            else
        end
        if globals.tickcount() % 4 == 0 then
            ui.set(rage, true)
            else
            ui.set(rage, false)
            end
        ui.set(pitch, "Down")
        ui.set(fd_ref, "On hotkey")
        ui.set(yaw_value, 0)
        if ui.get(spam) then
            ui.set(spamduck, "On")
        end
    end
end)
local arrow_size = 16
local arrow_offset = 48
local function draw_arrow(direction, r, g, b, a)
    local cx, cy = client.screen_size()
    cx = math.floor(cx / 2)
    cy = math.floor(cy / 2)
    local x = cx + direction * arrow_offset
    local y = cy
    local size = arrow_size
    if direction == 1 then
        renderer.triangle(x, y, x - size, y - math.floor(size / 2), x - size, y + math.floor(size / 2), r, g, b, a)
    else
        renderer.triangle(x, y, x + size, y - math.floor(size / 2), x + size, y + math.floor(size / 2), r, g, b, a)
    end
end
client.set_event_callback("paint", function()
    if not ui.get(airlag_checkbox) then return end
    local lp = entity.get_local_player()
    if not lp then return end
    if entity.get_prop(lp, "m_lifeState") ~= 0 then return end
    local flick_enabled = ui.get(airlag_checkbox)
    local flick_invert = ui.get(flip)
    if ui.get(flick_arrow_enable) and flick_enabled then
        local r, g, b, a = ui.get(flick_arrow_color)
        if flick_invert then
            draw_arrow(1, r, g, b, a)
        else
            draw_arrow(-1, r, g, b, a)
        end
    end
end)
local enable_checkbox = ui.new_checkbox("AA", "Anti-aimbot angles", "\aFFC96BFFIndicator")
local function interpolate_color()
    local t = globals.realtime() * 4
    local factor = (math.sin(t) + 1) / 2
    local r = math.floor((0xAF * (1 - factor)) + (0xFF * factor))
    local g = math.floor((0xC0 * (1 - factor)) + (0xFF * factor))
    local b = math.floor((0xDB * (1 - factor)) + (0xFF * factor))
    return r, g, b
end
local function draw_indicators()
    if not ui.get(enable_checkbox) then return end
    local local_player = entity.get_local_player()
    if not local_player or not entity.is_alive(local_player) then return end
    local screen_width, screen_height = client.screen_size()
    local cx = screen_width / 2 + 20
    local cy = screen_height / 2 - 60
    local r, g, b = interpolate_color()
    renderer.text(cx, cy, r, g, b, 255, nil, 0, "FLICKER")
    cy = cy + 15
    local side = ui.get(flip) and "RIGHT" or "LEFT"
    renderer.text(cx, cy, r, g, b, 255, nil, 0, side)
    cy = cy + 15
    if ui.get(rage) then
        renderer.text(cx, cy, r, g, b, 255, nil, 0, "UNSAFE")
    else
        renderer.text(cx, cy, r, g, b, 255, nil, 0, "SAFE")
    end
    cy = cy + 15
    local flags = entity.get_prop(local_player, "m_fFlags")
    if flags ~= nil and bit.band(flags, 1) == 0 then
        renderer.text(cx, cy, r, g, b, 255, nil, 0, "IN AIR")
    end
end
client.set_event_callback("paint", draw_indicators)