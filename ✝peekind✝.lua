print("###Power by Claude & Chatgpt")
print("Recode and paste from mlc aipeek.lua;)")
print("enjoy this dogshit xd")
local bit_band, bit_lshift, client_color_log, client_set_event_callback, client_key_state = bit.band, bit.lshift, client.color_log, client.set_event_callback, client.key_state
local entity_get_local_player, entity_is_alive, entity_get_origin = entity.get_local_player, entity.is_alive, entity.get_origin
local entity_get_prop, renderer_world_to_screen = entity.get_prop, renderer.world_to_screen
local renderer_circle_outline, renderer_line = renderer.circle_outline, renderer.line
local math_rad, math_cos, math_sin, math_sqrt = math.rad, math.cos, math.sin, math.sqrt
local ui_get, ui_new_checkbox, ui_new_color_picker = ui.get, ui.new_checkbox, ui.new_color_picker
local ui_new_slider, ui_reference = ui.new_slider, ui.reference
local globals_realtime, globals_frametime = globals.realtime, globals.frametime
local vector = require 'vector'
local config = {
    enable = ui_new_checkbox("RAGE", "Other", "Enable QuickPeek circle"),
    color = ui_new_color_picker("RAGE", "Other", "QuickPeek color", 255, 255, 255, 200),
    radius = ui_new_slider("RAGR", "Other", "QuickPeek radius", 24, 120, 48),
    fov = ui_new_slider("RAGE", "Other", "QuickPeek FOV", 30, 180, 90),
    glow = ui_new_slider("RAGE", "Other", "QuickPeek glow", 0, 8, 4),
}
local quick_peek = {ui_reference("RAGE", "Other", "Quick peek assist")}
local peek_state = {
    origin = nil,
    active = false,
    previously_pressed = false,
}
local animation = {
    alpha = 0,
    radius_mult = 1.0,
}
local function lerp(start, vend, time)
    return start + (vend - start) * time
end
local function draw_circle_3d(x, y, z, radius, r, g, b, a, accuracy, width, outline, start_degrees, percentage)
    local accuracy = accuracy or 3
    local width = width or 1
    local outline = outline or false
    local start_degrees = start_degrees or 0
    local percentage = percentage or 1
    local screen_x_line_old, screen_y_line_old
    for rot = start_degrees, percentage * 360, accuracy do
        local rot_temp = math_rad(rot)
        local lineX = radius * math_cos(rot_temp) + x
        local lineY = radius * math_sin(rot_temp) + y
        local lineZ = z
        local screen_x_line, screen_y_line = renderer_world_to_screen(lineX, lineY, lineZ)
        if screen_x_line and screen_x_line_old then
            for i = 1, width do
                local offset = i - 1
                renderer_line(screen_x_line, screen_y_line - offset, screen_x_line_old, screen_y_line_old - offset, r, g, b, a)
                renderer_line(screen_x_line - 1, screen_y_line, screen_x_line_old - offset, screen_y_line_old, r, g, b, a)
            end        
            if outline then
                local outline_a = a / 255 * 160
                renderer_line(screen_x_line, screen_y_line - width, screen_x_line_old, screen_y_line_old - width, 16, 16, 16, outline_a)
                renderer_line(screen_x_line, screen_y_line + 1, screen_x_line_old, screen_y_line_old + 1, 16, 16, 16, outline_a)
            end
        end
        
        screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
    end
end
local function draw_arc_3d(x, y, z, radius, start_angle, end_angle, r, g, b, a, width)
    local width = width or 2
    local accuracy = 2
    start_angle = start_angle % 360
    end_angle = end_angle % 360
    local arc_range = end_angle - start_angle
    if arc_range <= 0 then
        arc_range = arc_range + 360
    end
    local screen_x_line_old, screen_y_line_old
    for rot = start_angle, start_angle + arc_range, accuracy do
        local rot_temp = math_rad(rot)
        local lineX = radius * math_cos(rot_temp) + x
        local lineY = radius * math_sin(rot_temp) + y
        local lineZ = z     
        local screen_x_line, screen_y_line = renderer_world_to_screen(lineX, lineY, lineZ)     
        if screen_x_line and screen_x_line_old then
            for i = 1, width do
                local offset = i - 1
                renderer_line(screen_x_line, screen_y_line - offset, screen_x_line_old, screen_y_line_old - offset, r, g, b, a)
            end
        end   
        screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
    end
    local start_rad = math_rad(start_angle)
    local end_rad = math_rad(end_angle)
    local start_x, start_y = renderer_world_to_screen(x + math_cos(start_rad) * radius, y + math_sin(start_rad) * radius, z)
    local end_x, end_y = renderer_world_to_screen(x + math_cos(end_rad) * radius, y + math_sin(end_rad) * radius, z)
    local center_x, center_y = renderer_world_to_screen(x, y, z)
    if start_x and center_x then
        renderer_line(center_x, center_y, start_x, start_y, r, g, b, a)
    end
    if end_x and center_x then
        renderer_line(center_x, center_y, end_x, end_y, r, g, b, a)
    end
end
local function update_peek_state()
    local lp = entity_get_local_player()
    if not lp or not entity_is_alive(lp) then
        peek_state.origin = nil
        peek_state.active = false
        peek_state.previously_pressed = false
        return
    end
    local state = ui_get(quick_peek[2])
    if state and not peek_state.previously_pressed then
        local x, y, z = entity_get_origin(lp)
        if x and y and z then
            peek_state.origin = vector and vector(x, y, z) or {x = x, y = y, z = z}
            peek_state.active = true
        end
    elseif not state then
        if peek_state.previously_pressed then
            client.delay_call(0.5, function()
                if not ui_get(quick_peek[2]) then
                    peek_state.origin = nil
                    peek_state.active = false
                end
            end)
        end
    end
    peek_state.previously_pressed = state
end
local function update_animation()
    local state = ui_get(quick_peek[2])
    local animation_speed = 6.5
    if state and peek_state.active then
        animation.alpha = lerp(animation.alpha, 255, globals_frametime() * animation_speed)
        animation.radius_mult = lerp(animation.radius_mult, 1.0, globals_frametime() * animation_speed)
    else
        animation.alpha = lerp(animation.alpha, peek_state.origin and 50 or 0, globals_frametime() * animation_speed)
        animation.radius_mult = lerp(animation.radius_mult, 0.8, globals_frametime() * animation_speed)
    end
end
local function paint_quickpeek()
    if not ui_get(config.enable) then return end
    if not peek_state.origin then return end
    local lp = entity_get_local_player()
    if not lp or not entity_is_alive(lp) then return end
    local current_x, current_y, current_z = entity_get_origin(lp)
    if not current_x then return end
    local radius = ui_get(config.radius) * animation.radius_mult
    local fov = ui_get(config.fov)
    local glow_size = ui_get(config.glow)
    local r, g, b, a = ui_get(config.color)
    a = a * (animation.alpha / 255)
    if a < 5 then return end
    local yaw = entity_get_prop(lp, "m_angEyeAngles[1]") or 0
    yaw = (-yaw + 90) % 360  
    local half_fov = fov / 2
    local start_angle = yaw - half_fov
    local end_angle = yaw + half_fov
    if glow_size > 0 then
        for i = 1, glow_size do
            local glow_radius = radius + i * 3
            local glow_alpha = a * (1 - i / glow_size) * 0.4
            if glow_alpha > 5 then
                draw_circle_3d(current_x, current_y, current_z, glow_radius, r, g, b, glow_alpha, 4, 1, false, 0, 1)
            end
        end
    end
    draw_arc_3d(current_x, current_y, current_z, radius, start_angle, end_angle, r, g, b, a, 2)
    draw_circle_3d(current_x, current_y, current_z, 4, r, g, b, a, 8, 2, false, 0, 1)
end
client_set_event_callback("run_command", function()
    update_peek_state()
end)
client_set_event_callback("paint", function()
    update_animation()
    paint_quickpeek()
end)
client_set_event_callback("shutdown", function()
    peek_state.origin = nil
    peek_state.active = false
    peek_state.previously_pressed = false
end)