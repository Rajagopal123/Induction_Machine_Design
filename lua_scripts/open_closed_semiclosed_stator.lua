
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


--============================== STATOR PARAMETERS ==================================================================================         

-- for : "trapezoidal_curved_corner"
-- For rectangular curved corner input :r1=r2 and "trapezoidal_curved_corner" 
-- for trapezoidal slot : "trapezoidal"
-- for rectangular slot : r1=r1 and "trapezoidal"
-- for your own slot shape, input is "user_defined" and go to the user defined section and enter the dimension of slot as per diagram.
stator_slot_shaper = "trapezoidal" 

-- open or semi_closed or closed
stator_slot_type="open"


num_poles=2
num_phases=3

stator_inner_radius=60-- starting(slot) height from center
stator_core_thick=10
stator_num_slots=24
stator_slot_height=13                   --Total slot height ( for circular_slot the slot height and slot_width_r1 must be same)
stator_tooth_thick=1           -- the thickness of statot tooth top
stator_outer_radius= stator_inner_radius+stator_slot_height+stator_tooth_thick+stator_core_thick-- outer radius of rotor tooth bottoms
--zero for rectangular and trapezoidal slots

s_slot_width_r1=7  --w (slot closing width(larger width))
s_slot_width_r2=4  --w2 (slot opening width(smaller width))
--ratio of w and w2 not less than 0.25 for trapezoidal slot. if not(change the ration in the trapezoidal code (w1=w_body*0.25))


--===============================================================================================================================





if stator_slot_shaper=="trapezoidal_curved_corner" then
    function draw_slot(angle, h, w_open, w_body)
        local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
        angle1=angle
        w1=w_body*0.2  -- ratio can be changable bwt 0.2 to 0.3, refernce google
        w2=w_open
        w3=w_body*0.7
        w=w_body
        h3=h*0.08
        h1=h*0.1

        if stator_slot_type=="open" then
            w1=w2
        end
        -- Neck opening
        x1, y1 = rotate(-w1/2, y_base, angle)
        x11,y11=rotate(w1/2, y_base, angle)
        x2, y2 = rotate(w2 / 2, y_base +h1, angle)
        x3, y3 = rotate(-w2 / 2, y_base + h1, angle)

        -- Body width near arc start
        x4, y4 = rotate(w/2 , y_base + h - h3, angle)
        x5, y5 = rotate(-w/2, y_base + h - h3, angle)

        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(w3/2, y_base + h, angle)
        x8, y8 = rotate(-w3/2, y_base + h, angle)

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x4, y4)
        mi_addnode(x5, y5)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)
        mi_addnode(x11,y11)
        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addsegment(x4, y4, x2, y2)
        mi_addsegment(x5, y5, x3, y3)
        mi_addsegment(x11,y11,x1,y1)
        mi_addarc(x8, y8, x5, y5, 80, 1)
        mi_addarc(x4, y4, x7, y7, 80, 1)
        mi_addarc(x3, y3, x1, y1, 70, 1)
        mi_addarc(x11, y11, x2, y2, 70, 1)

        if stator_slot_type=="semi_closed" then
            -- Compute extended points
            dx, dy = upward_offset(angle,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

                -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

                -- Add segments (vertical lines)
            mi_addsegment(x1, y1, x9, y9)
            mi_addsegment(x11, y11, x10, y10)
        end
        if stator_slot_type=="open" then
            -- Compute extended points
            dx, dy = upward_offset(angle,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

                -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

                -- Add segments (vertical lines)
            mi_addsegment(x1, y1, x9, y9)
            mi_addsegment(x11, y11, x10, y10)
        end



        -- Add block label in center of slot
        --xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        --mi_addblocklabel(xlbl, ylbl)
        --mi_selectlabel(xlbl, ylbl)
        --mi_setblockprop(stator_circuit_material, 1, 0, "", 0, 0, 1)
        --mi_clearselected()
    end

    stator_angle_step = 360 / stator_num_slots
    for i = 0, stator_num_slots-1  do
        local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
        draw_slot(angle1,stator_slot_height,s_slot_width_r2,s_slot_width_r1)
    end
    -- drawing stator tooth top
    if stator_slot_type=="semi_closed" then
        for i = 0, stator_num_slots-1  do
            local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
            local angle2 = (i + 1)
            if angle2 == stator_num_slots then
                angle2 = 0
            end
            angle2 = ((i+1) * stator_angle_step)+(360/(stator_num_slots*2))


            local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
            x1, y1 = rotate(-w1/2, y_base, angle1)
            x11,y11=rotate(w1/2, y_base, angle1)
            -- Compute extended points
            dx, dy = upward_offset(angle1,stator_tooth_thick)
            dx_next, dy_next = upward_offset(angle2,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

            x1_next, y1_next = rotate(-w1/2, y_base, angle2)
            x11_next,y11_next=rotate(w1/2, y_base, angle2)

            x9_next = x1_next - dx_next
            y9_next = y1_next - dy_next
            x10_next = x11_next - dx_next
            y10_next = y11_next - dy_next
            

            mi_addarc(x9, y9, x10_next, y10_next,stator_angle_step, 1)
            
        end
    end
    if stator_slot_type=="open" then
        for i = 0, stator_num_slots-1  do
            local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
            local angle2 = (i + 1)
            if angle2 == stator_num_slots then
                angle2 = 0
            end
            angle2 = ((i+1) * stator_angle_step)+(360/(stator_num_slots*2))


            local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
            x1, y1 = rotate(-w1/2, y_base, angle1)
            x11,y11=rotate(w1/2, y_base, angle1)
            -- Compute extended points
            dx, dy = upward_offset(angle1,stator_tooth_thick)
            dx_next, dy_next = upward_offset(angle2,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

            x1_next, y1_next = rotate(-w1/2, y_base, angle2)
            x11_next,y11_next=rotate(w1/2, y_base, angle2)

            x9_next = x1_next - dx_next
            y9_next = y1_next - dy_next
            x10_next = x11_next - dx_next
            y10_next = y11_next - dy_next
            

            mi_addarc(x9, y9, x10_next, y10_next,stator_angle_step, 1)
            
        end
    end

    if stator_slot_type=="closed" then 
        mi_drawarc(stator_inner_radius, 0,-stator_inner_radius,0, 180, 1)
        mi_drawarc(-stator_inner_radius, 0, stator_inner_radius, 0, 180, 1)
    end

    --stator outer core
    mi_drawarc(stator_outer_radius, 0,-stator_outer_radius,0, 180, 1)
    mi_drawarc(-stator_outer_radius, 0, stator_outer_radius, 0, 180, 1)

    xc, yc = stator_outer_radius-0.8,0
    mi_addblocklabel(xc, yc)
    mi_selectlabel(xc, yc)
    mi_setblockprop(stator_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()




    -- Parameters
    r_slot_inner = stator_inner_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
    slot_height = stator_slot_height-2 --(coil winding space height)
    r_between_slots = r_slot_inner + slot_height / 2 -- Label radial position



    -- q = slots / (poles * phases)
    q = my_div(stator_num_slots, num_poles * num_phases)
    current=1
    turn_per_phase=36
    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=turn_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
    local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
    local y_base = stator_inner_radius+stator_tooth_thick 

    local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
    turns=turn_per_coil/2


    -- Determine which phase this slot gets based on integer logic
    local block = my_div(i, q)
    local phase_index = my_mod(block, 6)
    
    -- Assign phase name and turns without tables
    local phase_name = ""
    if phase_index == 5 then
        phase_name = "A"
        angle=0
    elseif phase_index == 3 then
        phase_name = "B"
        angle=120
    elseif phase_index == 1 then
        phase_name = "C"
        angle=-120
        turns=-turns
    elseif phase_index == 2 then
        phase_name = "A1"
        angle=0
        turns=turns
    elseif phase_index == 0 then
        phase_name = "B1"
        angle=120
        turns=turns
    elseif phase_index == 4 then
        phase_name = "C1"
        angle=-120
        turns=-turns
    end

    -- Place the winding label
    mi_addblocklabel(x, y)
    mi_selectlabel(x, y)
    mi_setblockprop(stator_winding_material, 0, 1, phase_name, angle, 0, turns)
    mi_clearselected()
    end
end

if stator_slot_shaper=="trapezoidal" then
    function draw_slot(angle, h, w_open, w_body)
        local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
        angle1=angle
        w1=w_body*0.25      --(20 to 30 percent refernce google)
        w2=w_open
        w3=(w_body*0.75)
        w=w_body
        h3=0
        h1=0
        if stator_slot_type=="open" then
            w1=w2
        end
        -- Neck opening
        x1, y1 = rotate(-w1/2, y_base, angle)
        x11,y11=rotate(w1/2, y_base, angle)
        x2, y2 = rotate(w2 / 2, y_base +h1, angle)
        x3, y3 = rotate(-w2 / 2, y_base + h1, angle)

        -- Body width near arc start
        x4, y4 = rotate(w/2 , y_base + h - h3, angle)
        x5, y5 = rotate(-w/2, y_base + h - h3, angle)

        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(w3/2, y_base + h, angle)
        x8, y8 = rotate(-w3/2, y_base + h, angle)

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x4, y4)
        mi_addnode(x5, y5)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)
        mi_addnode(x11,y11)
        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addsegment(x4, y4, x2, y2)
        mi_addsegment(x5, y5, x3, y3)
        mi_addsegment(x11,y11,x1,y1)
        mi_addsegment(x8, y8, x5, y5)
        mi_addsegment(x4, y4, x7, y7)
        mi_addsegment(x3, y3, x1, y1)
        mi_addsegment(x11, y11, x2, y2)

        if stator_slot_type=="semi_closed" then
            -- Compute extended points
            if stator_slot_type=="open" then
                x1,y1=x3,y3
                x11,y11=x2,y2
            end
            dx, dy = upward_offset(angle,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

                -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

                -- Add segments (vertical lines)
            mi_addsegment(x1, y1, x9, y9)
            mi_addsegment(x11, y11, x10, y10)
        end
        if stator_slot_type=="open" then
            -- Compute extended points
            if stator_slot_type=="open" then
                x1,y1=x3,y3
                x11,y11=x2,y2
            end
            dx, dy = upward_offset(angle,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

                -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

                -- Add segments (vertical lines)
            mi_addsegment(x1, y1, x9, y9)
            mi_addsegment(x11, y11, x10, y10)
        end


        -- Add block label in center of slot
        --xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        --mi_addblocklabel(xlbl, ylbl)
        --mi_selectlabel(xlbl, ylbl)
        --mi_setblockprop(stator_circuit_material, 1, 0, "", 0, 0, 1)
        --mi_clearselected()
    end

    stator_angle_step = 360 / stator_num_slots
    for i = 0, stator_num_slots-1  do
        local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
        draw_slot(angle1,stator_slot_height,s_slot_width_r2,s_slot_width_r1)
    end
    -- drawing stator tooth top
    if stator_slot_type=="semi_closed" then
        for i = 0, stator_num_slots-1  do
            local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
            local angle2 = (i + 1)
            if angle2 == stator_num_slots then
                angle2 = 0
            end
            angle2 = ((i+1) * stator_angle_step)+(360/(stator_num_slots*2))


            local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
            x1, y1 = rotate(-w1/2, y_base, angle1)
            x11,y11=rotate(w1/2, y_base, angle1)
            -- Compute extended points
            dx, dy = upward_offset(angle1,stator_tooth_thick)
            dx_next, dy_next = upward_offset(angle2,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

            x1_next, y1_next = rotate(-w1/2, y_base, angle2)
            x11_next,y11_next=rotate(w1/2, y_base, angle2)

            x9_next = x1_next - dx_next
            y9_next = y1_next - dy_next
            x10_next = x11_next - dx_next
            y10_next = y11_next - dy_next
            

            mi_addarc(x9, y9, x10_next, y10_next,stator_angle_step, 1)
            
        end
    end
    if stator_slot_type=="open" then
        for i = 0, stator_num_slots-1  do
            local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
            local angle2 = (i + 1)
            if angle2 == stator_num_slots then
                angle2 = 0
            end
            angle2 = ((i+1) * stator_angle_step)+(360/(stator_num_slots*2))


            local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
            x1, y1 = rotate(-w1/2, y_base, angle1)
            x11,y11=rotate(w1/2, y_base, angle1)
            -- Compute extended points
            dx, dy = upward_offset(angle1,stator_tooth_thick)
            dx_next, dy_next = upward_offset(angle2,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

            x1_next, y1_next = rotate(-w1/2, y_base, angle2)
            x11_next,y11_next=rotate(w1/2, y_base, angle2)

            x9_next = x1_next - dx_next
            y9_next = y1_next - dy_next
            x10_next = x11_next - dx_next
            y10_next = y11_next - dy_next
            

            mi_addarc(x9, y9, x10_next, y10_next,stator_angle_step, 1)
            
        end
    end

    if stator_slot_type=="closed" then 
        mi_drawarc(stator_inner_radius, 0,-stator_inner_radius,0, 180, 1)
        mi_drawarc(-stator_inner_radius, 0, stator_inner_radius, 0, 180, 1)
    end

    --stator outer core
    mi_drawarc(stator_outer_radius, 0,-stator_outer_radius,0, 180, 1)
    mi_drawarc(-stator_outer_radius, 0, stator_outer_radius, 0, 180, 1)

    xc, yc = stator_outer_radius-0.8,0
    mi_addblocklabel(xc, yc)
    mi_selectlabel(xc, yc)
    mi_setblockprop(stator_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()




    -- Parameters
    r_slot_inner = stator_inner_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
    slot_height = stator_slot_height-2 --(coil winding space height)
    r_between_slots = r_slot_inner + slot_height / 2 -- Label radial position



    -- q = slots / (poles * phases)
    q = my_div(stator_num_slots, num_poles * num_phases)
    current=1
    turn_per_phase=36
    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=turn_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
    local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
    local y_base = stator_inner_radius+stator_tooth_thick 

    local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
    turns=turn_per_coil/2


    -- Determine which phase this slot gets based on integer logic
    local block = my_div(i, q)
    local phase_index = my_mod(block, 6)
    
    -- Assign phase name and turns without tables
    local phase_name = ""
    if phase_index == 5 then
        phase_name = "A"
        angle=0
    elseif phase_index == 3 then
        phase_name = "B"
        angle=120
    elseif phase_index == 1 then
        phase_name = "C"
        angle=-120
        turns=-turns
    elseif phase_index == 2 then
        phase_name = "A1"
        angle=0
        turns=turns
    elseif phase_index == 0 then
        phase_name = "B1"
        angle=120
        turns=turns
    elseif phase_index == 4 then
        phase_name = "C1"
        angle=-120
        turns=-turns
    end

    -- Place the winding label
    mi_addblocklabel(x, y)
    mi_selectlabel(x, y)
    mi_setblockprop(stator_winding_material, 0, 1, phase_name, angle, 0, turns)
    mi_clearselected()
    end
end

if stator_slot_shaper=="user_defined" then
    function draw_slot(angle)


        --  USER CAN CHANGE THESE LENGTHS BASED ON THEIR DESIRED SLOT SHAPE,(FOR REFRENCE SEE THE DIAGRAM)
        w1=1  -- ratio can be changable bwt 0.2 to 0.3, refernce google
        w2=4
        w3=3
        w=5
        h=14
        h3=h*0.08
        h1=h*0.1

        if stator_slot_type=="open" then
            w1=w2
        end
        local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
        angle1=angle
    
        -- Neck opening
        x1, y1 = rotate(-w1/2, y_base, angle)
        x11,y11=rotate(w1/2, y_base, angle)
        x2, y2 = rotate(w2 / 2, y_base +h1, angle)
        x3, y3 = rotate(-w2 / 2, y_base + h1, angle)

        -- Body width near arc start
        x4, y4 = rotate(w/2 , y_base + h - h3, angle)
        x5, y5 = rotate(-w/2, y_base + h - h3, angle)

        -- Arc center points
        x6, y6 = rotate(0, y_base + h, angle)
        x7, y7 = rotate(w3/2, y_base + h, angle)
        x8, y8 = rotate(-w3/2, y_base + h, angle)

        -- Add nodes
        mi_addnode(x1, y1)
        mi_addnode(x2, y2)
        mi_addnode(x3, y3)
        mi_addnode(x4, y4)
        mi_addnode(x5, y5)
        mi_addnode(x6, y6)
        mi_addnode(x7, y7)
        mi_addnode(x8, y8)
        mi_addnode(x11,y11)
        -- Add segments and arcs
        mi_addsegment(x8, y8, x6, y6)
        mi_addsegment(x6, y6, x7, y7)
        mi_addsegment(x4, y4, x2, y2)
        mi_addsegment(x5, y5, x3, y3)
        mi_addsegment(x11,y11,x1,y1)
        mi_addarc(x8, y8, x5, y5, 80*(w3/w), 1)
        mi_addarc(x4, y4, x7, y7, 80*(w3/w), 1)
        mi_addarc(x3, y3, x1, y1, 65*(w1/w2), 1)
        mi_addarc(x11, y11, x2, y2, 65*(w1/w2), 1)

        if stator_slot_type=="semi_closed" then
            -- Compute extended points
            dx, dy = upward_offset(angle,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

                -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

                -- Add segments (vertical lines)
            mi_addsegment(x1, y1, x9, y9)
            mi_addsegment(x11, y11, x10, y10)
        end
        if stator_slot_type=="open" then
            -- Compute extended points
            dx, dy = upward_offset(angle,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

                -- Add nodes for vertical lines
            mi_addnode(x9, y9)
            mi_addnode(x10, y10)

                -- Add segments (vertical lines)
            mi_addsegment(x1, y1, x9, y9)
            mi_addsegment(x11, y11, x10, y10)
        end



        -- Add block label in center of slot
        --xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
        --mi_addblocklabel(xlbl, ylbl)
        --mi_selectlabel(xlbl, ylbl)
        --mi_setblockprop(stator_circuit_material, 1, 0, "", 0, 0, 1)
        --mi_clearselected()
    end

    stator_angle_step = 360 / stator_num_slots
    for i = 0, stator_num_slots-1  do
        local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
        draw_slot(angle1)
    end
    -- drawing stator tooth top
    if stator_slot_type=="semi_closed" then
        for i = 0, stator_num_slots-1  do
            local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
            local angle2 = (i + 1)
            if angle2 == stator_num_slots then
                angle2 = 0
            end
            angle2 = ((i+1) * stator_angle_step)+(360/(stator_num_slots*2))


            local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
            x1, y1 = rotate(-w1/2, y_base, angle1)
            x11,y11=rotate(w1/2, y_base, angle1)
            -- Compute extended points
            dx, dy = upward_offset(angle1,stator_tooth_thick)
            dx_next, dy_next = upward_offset(angle2,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

            x1_next, y1_next = rotate(-w1/2, y_base, angle2)
            x11_next,y11_next=rotate(w1/2, y_base, angle2)

            x9_next = x1_next - dx_next
            y9_next = y1_next - dy_next
            x10_next = x11_next - dx_next
            y10_next = y11_next - dy_next
            

            mi_addarc(x9, y9, x10_next, y10_next,stator_angle_step, 1)
            
        end
    end
    if stator_slot_type=="open" then
        for i = 0, stator_num_slots-1  do
            local angle1 = stator_angle_step*i+(360/(stator_num_slots*2))
            local angle2 = (i + 1)
            if angle2 == stator_num_slots then
                angle2 = 0
            end
            angle2 = ((i+1) * stator_angle_step)+(360/(stator_num_slots*2))


            local y_base = stator_inner_radius+stator_tooth_thick  -- starting height from center
            x1, y1 = rotate(-w1/2, y_base, angle1)
            x11,y11=rotate(w1/2, y_base, angle1)
            -- Compute extended points
            dx, dy = upward_offset(angle1,stator_tooth_thick)
            dx_next, dy_next = upward_offset(angle2,stator_tooth_thick)
            x9 = x1 - dx
            y9 = y1 - dy
            x10 = x11 - dx
            y10 = y11 - dy

            x1_next, y1_next = rotate(-w1/2, y_base, angle2)
            x11_next,y11_next=rotate(w1/2, y_base, angle2)

            x9_next = x1_next - dx_next
            y9_next = y1_next - dy_next
            x10_next = x11_next - dx_next
            y10_next = y11_next - dy_next
            

            mi_addarc(x9, y9, x10_next, y10_next,stator_angle_step, 1)
            
        end
    end

    if stator_slot_type=="closed" then 
        mi_drawarc(stator_inner_radius, 0,-stator_inner_radius,0, 180, 1)
        mi_drawarc(-stator_inner_radius, 0, stator_inner_radius, 0, 180, 1)
    end

    --stator outer core
    mi_drawarc(stator_outer_radius, 0,-stator_outer_radius,0, 180, 1)
    mi_drawarc(-stator_outer_radius, 0, stator_outer_radius, 0, 180, 1)

    xc, yc = stator_outer_radius-0.8,0
    mi_addblocklabel(xc, yc)
    mi_selectlabel(xc, yc)
    mi_setblockprop(stator_core_material, 1, 0, "", 0, 0, 1)
    mi_clearselected()




    -- Parameters
    r_slot_inner = stator_inner_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
    slot_height = stator_slot_height-2 --(coil winding space height)
    r_between_slots = r_slot_inner + slot_height / 2 -- Label radial position



    -- q = slots / (poles * phases)
    q = my_div(stator_num_slots, num_poles * num_phases)
    current=1
    turn_per_phase=36
    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=turn_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
    local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
    local y_base = stator_inner_radius+stator_tooth_thick 

    local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
    turns=turn_per_coil/2


    -- Determine which phase this slot gets based on integer logic
    local block = my_div(i, q)
    local phase_index = my_mod(block, 6)
    
    -- Assign phase name and turns without tables
    local phase_name = ""
    if phase_index == 5 then
        phase_name = "A"
        angle=0
    elseif phase_index == 3 then
        phase_name = "B"
        angle=120
    elseif phase_index == 1 then
        phase_name = "C"
        angle=-120
        turns=-turns
    elseif phase_index == 2 then
        phase_name = "A1"
        angle=0
        turns=turns
    elseif phase_index == 0 then
        phase_name = "B1"
        angle=120
        turns=turns
    elseif phase_index == 4 then
        phase_name = "C1"
        angle=-120
        turns=-turns
    end

    -- Place the winding label
    mi_addblocklabel(x, y)
    mi_selectlabel(x, y)
    mi_setblockprop(stator_winding_material, 0, 1, phase_name, angle, 0, turns)
    mi_clearselected()
    end
end









