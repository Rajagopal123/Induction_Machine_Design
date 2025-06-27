

-- ==== Custom math functions ====
function degToRad(d)
    return d * 3.1415926535898 / 180
end
function taylor_sin(x)
    return x - x^3/6 + x^5/120 - x^7/5040
end
function sin(d)
    while d < 0 do d = d + 360 end
    while d >= 360 do d = d - 360 end
    if d <= 90 then
        return taylor_sin(degToRad(d))
    elseif d <= 180 then
        return taylor_sin(degToRad(180 - d))
    elseif d <= 270 then
        return -taylor_sin(degToRad(d - 180))
    else
        return -taylor_sin(degToRad(360 - d))
    end
end
function cos(d)
    return sin(90 - d)
end
function rotate(x, y, d)
    local xr = x * cos(d) - y * sin(d)
    local yr = x * sin(d) + y * cos(d)
    return xr, yr
end
function upward_offset(angle,tha)
    local dx, dy = rotate(0, tha, angle)
    return dx, dy
end
-- Manual division and modulo
function my_div(a, b)
  local count = 0
  while a >= b do
    a = a - b
    count = count + 1
  end
  return count
end
function my_mod(a, b)
  return a - b * my_div(a, b)
end


newdocument(0)
mi_probdef(50, "centimeters", "planar", 1e-8, 0, 30)


-- ================================== Define materials =======================================================

stator_winding_material="Copper"
stator_core_material="M-19 Steel"
rotor_circuit_material="Aluminum"
rotor_core_material="M-19 Steel"
shaft_material="Air"

mi_addmaterial(stator_core_material, 5000, 5000, 0, 0, 0, 0)
mi_addmaterial(stator_winding_material, 58, 58, 0, 0, 0, 0)
mi_addmaterial(rotor_circuit_material, 37, 37, 0, 0, 0, 0)
mi_addmaterial(shaft_material, 1, 1, 1, 0, 0, 0, 0)
mi_addmaterial(rotor_core_material, 5000, 5000, 0, 0, 0, 0)
mi_addmaterial("Air", 1, 1, 0, 0, 0, 0)




--==========================================  ROTOR PARAMETERS ==================================================================


-- "Rectangular_slot" or "Semi_closed_slot" or
-- "Trapezial_slot" or "Key_hole_single_cage_slot" or
-- "key_hole_double_cage_slot"
rotor_shaper = "Trapezial_slot" 

-- open or semi_closed or closed
rotor_type_slot="open"

    

rotor_outer_radius=59         -- starting(slot) height from center
rotor_num_slots=23
rotor_slot_height=12                   --Total slot height ( for circular_slot the slot height and slot_width_r1 must be same)
th=1           -- the thickness of rotor tooth top
rotor_inner_slot_radius= rotor_outer_radius-rotor_slot_height-th-- outer radius of rotor tooth bottoms
--zero for rectangular and trapezoidal slots
r_arc_bottom=0.5--The radius of the semicircular arc at the bottom of the slot (keyhole curve) and 

slot_width_r1=6
slot_width_r2=4  --( zero for rectangular and circular slots), (input value for trapezoidal slots), (slot_width_r1*0.3 for key hole slot)






-- ==================================================================================================================================





if rotor_shaper == "key_hole_single_cage_slot" then 

    -- ==== Slot point definitions (from your original slot) ====
    function draw_slot(angle, h, w_open, w_body, r_arc)
        local y_base = rotor_inner_slot_radius  -- starting height from center

        r1=w_body
        r2=w_open
        h2=r_arc+1
        h1=r_arc
        r3=(w_body*0.25)

        if rotor_type_slot=="open" then
            r3=r1
        end
        -- Neck opening
        x1, y1 = rotate(0, y_base, angle)
        x2, y2 = rotate(r2/2, y_base + h1, angle)
        x3, y3 = rotate(-r2/ 2, y_base + h1, angle)

        -- Body width near arc start
        x4, y4 = rotate(r1 / 2, y_base + (h-h2), angle)
        x5, y5 = rotate(-r1 / 2, y_base + (h-h2), angle)

        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(r3/2, y_base + h, angle)
        x8, y8 = rotate(-r3/2, y_base + h, angle)

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x4, y4)
        mi_addnode(x5, y5)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)

        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addsegment(x4, y4, x2, y2)
        mi_addsegment(x5, y5, x3, y3)
        mi_addarc(x8, y8, x5, y5, 80, 1)
        mi_addarc(x4, y4, x7, y7, 80, 1)
        mi_addarc(x3, y3, x1, y1, 90, 1)
        mi_addarc(x1, y1, x2, y2, 90, 1)

        if rotor_type_slot=="semi_closed" then
        -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end
        if rotor_type_slot=="open" then
        -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end

        -- Add block label in center of slot
        xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        mi_addblocklabel(xlbl, ylbl)
        mi_selectlabel(xlbl, ylbl)
        mi_setblockprop(rotor_circuit_material, 1, 0, "", 0, 0, 1)
        mi_clearselected()
    end

    rotor_angle_step = 360 / rotor_num_slots
    for i = 0, rotor_num_slots - 1 do
        draw_slot(rotor_angle_step*i,rotor_slot_height,slot_width_r2,slot_width_r1,r_arc_bottom)
    end
    function connect_slot_bottoms(slot_count, h, w_body)
        if rotor_type_slot=="semi_closed" then

            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_body*0.25/2, r, angle2)
                local xB8, yB8 = rotate(-w_body*0.25/2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
        if rotor_type_slot=="open" then

            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_body /2, r, angle2)
                local xB8, yB8 = rotate(-w_body /2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
    end
    connect_slot_bottoms(rotor_num_slots,rotor_slot_height,slot_width_r1)  -- adjust values to match your draw_slot

    if rotor_type_slot=="closed" then
        mi_addnode(rotor_outer_radius,0)
        mi_addnode(-rotor_outer_radius,0)
        mi_addarc(rotor_outer_radius, 0, -rotor_outer_radius, 0, 180, 1)
        mi_addarc(-rotor_outer_radius, 0, rotor_outer_radius, 0, 180, 1)
    end

    -- Draw shaft core as a circular arc using four quarter arcs
    shaft_radius=rotor_inner_slot_radius/3
    mi_drawarc(shaft_radius, 0,-shaft_radius,0, 180, 1)
    mi_drawarc(-shaft_radius, 0, shaft_radius, 0, 180, 1)

    -- Add block label in center of slot
    xr, yr = shaft_radius+1,0
    mi_addblocklabel(xr, yr)
    mi_selectlabel(xr, yr)
    mi_setblockprop(rotor_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()

    -- Add block label in center of slot
    xsh, ysh = 0,0
    mi_addblocklabel(xsh, ysh)
    mi_selectlabel(xsh, ysh)
    mi_setblockprop(shaft_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()
end


if rotor_shaper == "Rectangular_slot" then 

    -- ==== Slot point definitions (from your original slot) ====
    function draw_slot(angle, h, w_open, w_body,r_arc)
        local y_base = rotor_inner_slot_radius  -- starting height from center
        r3=w_body*0.25
        if rotor_type_slot=="open" then
            r3=w_body
        end

        -- Neck opening
        x1, y1 = rotate(0, y_base, angle)
        x2, y2 = rotate(w_body / 2, y_base, angle)
        x3, y3 = rotate(-w_body / 2, y_base, angle)
    

        -- Body width near arc start
        x4, y4 = rotate(w_body / 2, y_base + h, angle)
        x5, y5 = rotate(-w_body / 2, y_base + h, angle)

        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(r3/2, y_base + h, angle)
        x8, y8 = rotate(-r3/2, y_base + h, angle)

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x4, y4)
        mi_addnode(x5, y5)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)

        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addsegment(x4, y4, x2, y2)
        mi_addsegment(x5, y5, x3, y3)
        mi_addsegment(x8, y8, x5, y5)
        mi_addsegment(x4, y4, x7, y7)
        mi_addsegment(x3, y3, x1, y1)
        mi_addsegment(x1, y1, x2, y2)

        if rotor_type_slot=="semi_closed" then
            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end

        if rotor_type_slot=="open" then
            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end


        -- Add block label in center of slot
        xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        mi_addblocklabel(xlbl, ylbl)
        mi_selectlabel(xlbl, ylbl)
        mi_setblockprop(rotor_circuit_material, 1, 0, "", 0, 0, 1)
        mi_clearselected()
    end

        rotor_angle_step = 360 / rotor_num_slots
    for i = 0, rotor_num_slots - 1 do
        draw_slot(rotor_angle_step*i,rotor_slot_height,slot_width_r2,slot_width_r1,r_arc_bottom)
    end
    function connect_slot_bottoms(slot_count, h, w_body)
        if rotor_type_slot=="semi_closed" then
            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_body*0.25/2, r, angle2)
                local xB8, yB8 = rotate(-w_body*0.25/2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
        if rotor_type_slot=="open" then
            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_body / 2, r, angle2)
                local xB8, yB8 = rotate(-w_body / 2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
    end
    connect_slot_bottoms(rotor_num_slots,rotor_slot_height,slot_width_r1)  -- adjust values to match your draw_slot

    if rotor_type_slot=="closed" then
        mi_addnode(rotor_outer_radius,0)
        mi_addnode(-rotor_outer_radius,0)
        mi_addarc(rotor_outer_radius, 0, -rotor_outer_radius, 0, 180, 1)
        mi_addarc(-rotor_outer_radius, 0, rotor_outer_radius, 0, 180, 1)
    end

    -- Draw shaft core as a circular arc using four quarter arcs
    shaft_radius=rotor_inner_slot_radius/3
    mi_drawarc(shaft_radius, 0,-shaft_radius,0, 180, 1)
    mi_drawarc(-shaft_radius, 0, shaft_radius, 0, 180, 1)

    -- Add block label in center of slot
    xr, yr = shaft_radius+1,0
    mi_addblocklabel(xr, yr)
    mi_selectlabel(xr, yr)
    mi_setblockprop(rotor_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()

    -- Add block label in center of slot
    xsh, ysh = 0,0
    mi_addblocklabel(xsh, ysh)
    mi_selectlabel(xsh, ysh)
    mi_setblockprop(shaft_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()
end


if rotor_shaper == "Trapezial_slot" then 
    slot_width_top=slot_width_r1
    slot_width_bottom=slot_width_r2
    -- ==== Slot point definitions (from your original slot) ====
    function draw_slot(angle, h, w_top, w_bottom,r_arc)
        local y_base = rotor_inner_slot_radius  -- starting height from center

        wtopt=(w_top*0.25)
        if rotor_type_slot=="open" then
            wtopt=w_top
        end
        -- Neck opening
        x1, y1 = rotate(0, y_base, angle)
        x2, y2 = rotate(w_bottom / 2, y_base, angle)
        x3, y3 = rotate(-w_bottom / 2, y_base, angle)
    

        -- Body width near arc start
        x4, y4 = rotate(w_top / 2, y_base + h, angle)
        x5, y5 = rotate(-w_top / 2, y_base + h, angle)

        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(wtopt/2, y_base + h, angle)
        x8, y8 = rotate(-wtopt/2, y_base + h, angle)

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x4, y4)
        mi_addnode(x5, y5)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)

        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addsegment(x4, y4, x2, y2)
        mi_addsegment(x5, y5, x3, y3)
        mi_addsegment(x8, y8, x5, y5)
        mi_addsegment(x4, y4, x7, y7)
        mi_addsegment(x3, y3, x1, y1)
        mi_addsegment(x1, y1, x2, y2)

        if rotor_type_slot=="semi_closed" then
            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end
        if rotor_type_slot=="open" then
            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end


        -- Add block label in center of slot
        xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        mi_addblocklabel(xlbl, ylbl)
        mi_selectlabel(xlbl, ylbl)
        mi_setblockprop(rotor_circuit_material, 1, 0, "", 0, 0, 1)
        mi_clearselected()
    end

    rotor_angle_step = 360 / rotor_num_slots
    for i = 0, rotor_num_slots - 1 do
        draw_slot(rotor_angle_step*i,rotor_slot_height,slot_width_top,slot_width_bottom,r_arc_bottom)
    end


    function connect_slot_bottoms(slot_count, h, w_top)
        if rotor_type_slot=="semi_closed" then

            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_top*0.25/2, r, angle2)
                local xB8, yB8 = rotate(-w_top*0.25/2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle2)
                local dxB, dyB = rotate(0, th, angle1)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
        if rotor_type_slot=="open" then

            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h   -- arc center height
            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_top/2, r, angle2)
                local xB8, yB8 = rotate(-w_top/2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle2)
                local dxB, dyB = rotate(0, th, angle1)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
    end
    connect_slot_bottoms(rotor_num_slots,rotor_slot_height,slot_width_top)  -- adjust values to match your draw_slot


    if rotor_type_slot=="closed" then
        mi_addnode(rotor_outer_radius,0)
        mi_addnode(-rotor_outer_radius,0)
        mi_addarc(rotor_outer_radius, 0, -rotor_outer_radius, 0, 180, 1)
        mi_addarc(-rotor_outer_radius, 0, rotor_outer_radius, 0, 180, 1)
    end

    -- Draw shaft core as a circular arc using four quarter arcs
    shaft_radius=rotor_inner_slot_radius/3
    mi_drawarc(shaft_radius, 0,-shaft_radius,0, 180, 1)
    mi_drawarc(-shaft_radius, 0, shaft_radius, 0, 180, 1)

    -- Add block label in center of slot
    xr, yr = shaft_radius+1,0
    mi_addblocklabel(xr, yr)
    mi_selectlabel(xr, yr)
    mi_setblockprop(rotor_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()

    -- Add block label in center of slot
    xsh, ysh = 0,0
    mi_addblocklabel(xsh, ysh)
    mi_selectlabel(xsh, ysh)
    mi_setblockprop(shaft_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()
end


if rotor_shaper == "circular_slot" then 
    slot_width_diameter=slot_width_r1

    -- ==== Slot point definitions (from your original slot) ====
    function draw_slot(angle, h,w_body)
        local y_base = rotor_inner_slot_radius  -- starting height from center
        ratio=w_body/h
        w2=w_body*0.25
        if rotor_type_slot=="open" then
            w2=w_body
            ratio=0.1
        end
        -- Neck opening
        x1, y1 = rotate(0, y_base, angle)
        x2, y2 = rotate(w_body / 2, y_base+(h/2), angle)
        x3, y3 = rotate(-w_body / 2, y_base+(h/2), angle)
        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(w2/2, y_base + h, angle)
        x8, y8 = rotate(-w2/2, y_base + h, angle)

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)

        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addarc(x1, y1, x2, y2, 90, 1)
        mi_addarc(x8, y8, x3, y3, 80*ratio, 1)
        mi_addarc(x3, y3, x1, y1, 90, 1)
        mi_addarc(x2, y2, x7, y7, 80*ratio, 1)

        if rotor_type_slot=="semi_closed" then

            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end
        if rotor_type_slot=="open" then

            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x9 = x8 + dx
            y9 = y8 + dy
            x10 = x7 + dx
            y10 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x9, y9)
            mi_addsegment(x7, y7, x10, y10)
        end



        -- Add block label in center of slot
        xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        mi_addblocklabel(xlbl, ylbl)
        mi_selectlabel(xlbl, ylbl)
        mi_setblockprop(rotor_circuit_material, 1, 0, "", 0, 0, 1)
        mi_clearselected()
    end
    rotor_angle_step = 360 / rotor_num_slots
    for i = 0, rotor_num_slots - 1 do
        draw_slot(rotor_angle_step*i,rotor_slot_height,slot_width_diameter)
    end
    function connect_slot_bottoms(slot_count, h, w_body)
        if rotor_type_slot=="semi_closed" then

            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_body*0.25/2, r, angle2)
                local xB8, yB8 = rotate(-w_body*0.25/2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
        if rotor_type_slot=="open" then

            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w_body /2, r, angle2)
                local xB8, yB8 = rotate(-w_body /2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
    end
    connect_slot_bottoms(rotor_num_slots,rotor_slot_height,slot_width_diameter)  -- adjust values to match your draw_slot


    if rotor_type_slot=="closed" then
        mi_addnode(rotor_outer_radius,0)
        mi_addnode(-rotor_outer_radius,0)
        mi_addarc(rotor_outer_radius, 0, -rotor_outer_radius, 0, 180, 1)
        mi_addarc(-rotor_outer_radius, 0, rotor_outer_radius, 0, 180, 1)
    end

    -- Draw shaft core as a circular arc using four quarter arcs
    shaft_radius=rotor_inner_slot_radius/3
    mi_drawarc(shaft_radius, 0,-shaft_radius,0, 180, 1)
    mi_drawarc(-shaft_radius, 0, shaft_radius, 0, 180, 1)

    -- Add block label in center of slot
    xr, yr = shaft_radius+1,0
    mi_addblocklabel(xr, yr)
    mi_selectlabel(xr, yr)
    mi_setblockprop(rotor_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()

    -- Add block label in center of slot
    xsh, ysh = 0,0
    mi_addblocklabel(xsh, ysh)
    mi_selectlabel(xsh, ysh)
    mi_setblockprop(shaft_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()
end


if rotor_shaper == "key_hole_double_cage_slot" then 
                   
    down_slot_height=2*(slot_height/3)           -- (h1) height of the slot below the circle hole and two lines
    slot_bwt_height=(slot_height/3)/4            --(h22) height of the the lines between the circle hole and bottom key hole shape slots


    -- ==== Slot point definitions (from your original slot) ====
    function draw_slot(angle, h,h1,h22,w_open, w_body, r_arc)
        local y_base = rotor_inner_slot_radius  -- starting height from center

        w1=w_body
        w2=w_open
        w3=w1*0.25

        if rotor_type_slot=="open" then
            w3=w1
        end
        -- Neck opening
        x1, y1 = rotate(0, y_base, angle)
        x2, y2 = rotate(w2 / 2, y_base + 0.5, angle)
        x3, y3 = rotate(-w2 / 2, y_base + 0.5, angle)

        -- Body width near arc start
        x4, y4 = rotate(w1 / 2, y_base + h1 - r_arc - 1, angle)
        x5, y5 = rotate(-w1 / 2, y_base + h1 - r_arc - 1, angle)

        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(w3/2, y_base + h, angle)
        x8, y8 = rotate(-w3/2, y_base + h, angle)

        x11,y11=rotate(-w_body / 4 + 0.5,y_base+h1+h22,angle)
        x12,y12=rotate(w_body / 4 - 0.5,y_base+h1+h22,angle)
        x9,y9=rotate(-w_body / 4 + 0.5,y_base+h1,angle)
        x10,y10=rotate(w_body / 4 - 0.5,y_base+h1,angle)
        

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x4, y4)
        mi_addnode(x5, y5)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)
        mi_addnode(x9,y9)
        mi_addnode(x10,y10)
        mi_addnode(x11,y11)
        mi_addnode(x12,y12)
        

        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addsegment(x12, y12, x10, y10)
        mi_addsegment(x9, y9, x11, y11)
        mi_addsegment(x4, y4, x2, y2)
        mi_addsegment(x5, y5, x3, y3)
        if rotor_type_slot=="open" then
            mi_addarc(x8, y8, x11, y11,100, 1)
            mi_addarc(x12, y12, x7, y7, 100, 1)
        else
            mi_addarc(x8, y8, x11, y11,160, 1)
            mi_addarc(x12, y12, x7, y7, 160, 1)
        end
        mi_addarc(x9, y9, x5, y5,80, 1)
        mi_addarc(x4, y4, x10, y10,80, 1)
        mi_addarc(x3, y3, x1, y1, 90, 1)
        mi_addarc(x1, y1, x2, y2, 90, 1)

        if rotor_type_slot=="semi_closed" then
            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x13 = x8 + dx
            y13 = y8 + dy
            x14 = x7 + dx
            y14 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x13, y13)
            mi_addnode(x14, y14)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x13, y13)
            mi_addsegment(x7, y7, x14, y14)
        end
        if rotor_type_slot=="open" then
            -- Compute extended points
            dx, dy = upward_offset(angle,th)
            x13 = x8 + dx
            y13 = y8 + dy
            x14 = x7 + dx
            y14 = y7 + dy

            -- Add nodes for vertical lines
            mi_addnode(x13, y13)
            mi_addnode(x14, y14)

            -- Add segments (vertical lines)
            mi_addsegment(x8, y8, x13, y13)
            mi_addsegment(x7, y7, x14, y14)
        end

        -- Add block label in center of slot
        xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        mi_addblocklabel(xlbl, ylbl)
        mi_selectlabel(xlbl, ylbl)
        mi_setblockprop(rotor_circuit_material, 1, 0, "", 0, 0, 1)
        mi_clearselected()
    end
    rotor_angle_step = 360 / rotor_num_slots
    for i = 0, rotor_num_slots - 1 do
        draw_slot(rotor_angle_step*i,rotor_slot_height,down_slot_height,slot_bwt_height,slot_width_r2,slot_width_r1,r_arc_bottom)
    end
    function connect_slot_bottoms(slot_count, h, w_body)
        if rotor_type_slot=="semi_closed" then
            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height
            w1=w_body
            w2=w_open
            w3=w_body*0.25

            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w3/2, r, angle2)
                local xB8, yB8 = rotate(-w3/2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
        if rotor_type_slot=="open" then
            local step = 360 / slot_count
            local r = rotor_inner_slot_radius + h  -- arc center height
            w1=w_body
            w2=w_open
            w3=w1
            for i = 0, slot_count - 1 do
                local angle1 = i * step
                local angle2 = (i + 1)
                if angle2 == slot_count then
                    angle2 = 0
                end
                angle2 = angle2 * step

                -- Arc ends of current slot
                local xA7, yA7 = rotate(w3/2, r, angle2)
                local xB8, yB8 = rotate(-w3/2, r, angle1)

                -- Extend up 1 mm in rotated direction
                local dxA, dyA = rotate(0, th, angle1)
                local dxB, dyB = rotate(0, th, angle2)

                local x10, y10 = xA7 + dxA, yA7 + dyA
                local x9, y9 = xB8 + dxB, yB8 + dyB

                mi_addarc(x9, y9, x10, y10,step,1)
            end
        end
    end
    connect_slot_bottoms(rotor_num_slots,rotor_slot_height,slot_width_r1)  -- adjust values to match your draw_slot

    if rotor_type_slot=="closed" then
        mi_addnode(rotor_outer_radius,0)
        mi_addnode(-rotor_outer_radius,0)
        mi_addarc(rotor_outer_radius, 0, -rotor_outer_radius, 0, 180, 1)
        mi_addarc(-rotor_outer_radius, 0, rotor_outer_radius, 0, 180, 1)
    end
    -- Draw shaft core as a circular arc using four quarter arcs
    shaft_radius=rotor_inner_slot_radius/3
    mi_drawarc(shaft_radius, 0,-shaft_radius,0, 180, 1)
    mi_drawarc(-shaft_radius, 0, shaft_radius, 0, 180, 1)

    -- Add block label in center of slot
    xr, yr = shaft_radius+1,0
    mi_addblocklabel(xr, yr)
    mi_selectlabel(xr, yr)
    mi_setblockprop(rotor_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()

    -- Add block label in center of slot
    xsh, ysh = 0,0
    mi_addblocklabel(xsh, ysh)
    mi_selectlabel(xsh, ysh)
    mi_setblockprop(shaft_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()
end



