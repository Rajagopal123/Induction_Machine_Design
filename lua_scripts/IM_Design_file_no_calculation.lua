


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
mi_probdef(50, "centimeters", "planar", 1e-8, axial_length, 30)


-- ================================== Define materials =======================================================



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


stator_inner_radius=60-- starting(slot) height from center
stator_core_thick=10
stator_num_slots=24
stator_slot_height=13                   --Total slot height ( for circular_slot the slot height and slot_width_r1 must be same)
stator_tooth_thick=1           -- the thickness of statot tooth top

--zero for rectangular and trapezoidal slots

s_slot_width_r1=7  --w (slot closing width(larger width))
s_slot_width_r2=4  --w2 (slot opening width(smaller width))
--ratio of w and w2 not less than 0.25 for trapezoidal slot. if not(change the ration in the trapezoidal code (w1=w_body*0.25))



num_poles=2
num_phases=3
stator_inner_radius=60
stator_core_thick=10
stator_num_slots=24
stator_slot_height=13                   --Total slot height ( for circular_slot the slot height and slot_width_r1 must be same)
stator_tooth_thick=0.5          -- the thickness of statot tooth top
stator_outer_radius= stator_inner_radius+stator_slot_height+stator_tooth_thick+stator_core_thick-- outer radius of rotor tooth bottoms
--zero for rectangular and trapezoidal slots

s_slot_width_r1=7  --w (slot closing width(larger width))
s_slot_width_r2=4  --w2 (slot opening width(smaller width))
--ratio of w and w2 not less than 0.25 for trapezoidal slot. if not(change the ration in the trapezoidal code (w1=w_body*0.25))


--===============================================================================================================================




--==========================================  ROTOR PARAMETERS ==================================================================

-- "Rectangular_slot" or "Semi_closed_slot" or
-- "Trapezial_slot" or "Key_hole_single_cage_slot" or
-- "key_hole_double_cage_slot"
rotor_shaper = "Trapezial_slot" 

-- open or semi_closed or closed
rotor_type_slot="open"


rotor_outer_radius=59        -- starting(slot) height from center
rotor_num_slots=23
--rotor_slot_height=rotor_slot_height                   --Total slot height ( for circular_slot the slot height and slot_width_r1 must be same)
th=0.5           -- the thickness of rotor tooth top
rotor_inner_slot_radius= rotor_outer_radius-rotor_slot_height-th-- outer radius of rotor tooth bottoms
--zero for rectangular and trapezoidal slots
r_arc_bottom=0.2*rotor_slot_height--The radius of the semicircular arc at the bottom of the slot (keyhole curve) and 
r_arc_top=0.3*rotor_slot_height--The radius of the semicircular arc at the top of the slot (keyhole curve) and 

slot_width_r1=6   

if rotor_type_slot=="Trapezoidal_slot" then
    local a=0.5
elseif rotor_type_slot=="key_hole_single_cage_slot" then
    local a=0.4
elseif rotor_type_slot=="key_hole_double_cage_slot" then
    local a=0.4
else 
    local a=0
end
slot_width_r2=rotor_slot_width*a  --( zero for rectangular and circular slots), (input value for trapezoidal slots), (slot_width_r1*0.3 for key hole slot)






-- ==================================================================================================================================








if stator_slot_shaper=="Trapezoidal_curved_corners" then
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

    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=stator_turns_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
    local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
    local y_base = stator_inner_radius+stator_tooth_thick 

    local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
    turns=round(turn_per_coil/2)


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
if stator_slot_shaper=="Rectangular_curved_corners" then
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

    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=stator_turns_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
    local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
    local y_base = stator_inner_radius+stator_tooth_thick 

    local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
    turns=round(turn_per_coil/2)


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
if stator_slot_shaper=="Trapezoidal_slot" then
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

    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=stator_turns_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
    local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
    local y_base = stator_inner_radius+stator_tooth_thick 

    local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
    turns=round(turn_per_coil/2)


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
if stator_slot_shaper=="Rectangular_slot" then
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

    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=stator_turns_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
        local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
        local y_base = stator_inner_radius+stator_tooth_thick 

        local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
        turns=round(turn_per_coil/2)


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
  
    -- Define circuit properties
    mi_addcircprop("A", current, 1)
    mi_addcircprop("C", current, 1)
    mi_addcircprop("B", current, 1)
    mi_addcircprop("A1",-current,1)
    mi_addcircprop("C1",-current,1)
    mi_addcircprop("B1",-current,1)

    turn_per_coil=stator_turns_per_phase/(stator_num_slots/num_phases)

    -- Loop over all slots
    for i = 0, stator_num_slots - 1 do
    local angle_deg = i * stator_angle_step +(360/(stator_num_slots*2))
    local y_base = stator_inner_radius+stator_tooth_thick 

    local x, y = rotate(0,y_base+(stator_slot_height/2),angle_deg)
    turns=round(turn_per_coil/2)


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

        if rotor_type=="cage_type" then
            -- Add block label in center of slot
            
            xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 1, 0, "Rotor", 0, 0, 1)
            mi_clearselected()
        end
        
    end
    mi_addcircprop("Rotor",0, 1)
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
    
    if rotor_type=="wounded_type" then
        rr_slot_inner = rotor_inner_slot_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
        r_slot_height = rotor_slot_height-2 --(coil winding space height)
        rr_between_slots = rr_slot_inner + r_slot_height / 2 -- Label radial position
        rotor_angle_step=360/rotor_num_slots


        -- q = slots / (poles * phases)
        q = my_div(rotor_num_slots, num_poles * num_phases)
        current1=0
        -- Define circuit properties
        mi_addcircprop("RA", current1, 1)
        mi_addcircprop("RC", current1, 1)
        mi_addcircprop("RB", current1, 1)
        mi_addcircprop("RA1",-current1,1)
        mi_addcircprop("RC1",-current1,1)
        mi_addcircprop("RB1",-current1,1)

        turn_per_coil=2
        h=rotor_slot_height
        -- Loop over all slots
        for i = 0, rotor_num_slots - 1 do
            local angle_deg = i * rotor_angle_step 
            local y_base = rotor_inner_slot_radius 

            turns=round(turn_per_coil/2)


            -- Determine which phase this slot gets based on integer logic
            local block = my_div(i, q)
            local phase_index = my_mod(block, 6)
            
            -- Assign phase name and turns without tables
            local phase_name = ""
            if phase_index == 5 then
                phase_name = "RA"
                angle=0
            elseif phase_index == 3 then
                phase_name = "RB"
                angle=120
            elseif phase_index == 1 then
                phase_name = "RC"
                angle=-120
                turns=-turns
            elseif phase_index == 2 then
                phase_name = "RA1"
                angle=0
                turns=turns
            elseif phase_index == 0 then
                phase_name = "RB1"
                angle=120
                turns=turns
            elseif phase_index == 4 then
                phase_name = "RC1"
                angle=-120
                turns=-turns
            end
            -- Add block label in center of slot
            local xlbl, ylbl = rotate(0,y_base+(rotor_slot_height/2),angle_deg)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 0, 1, phase_name, angle, 0, turns)
            mi_clearselected()
        end
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
if rotor_shaper == "key_hole_single_cage_slot" then 

    -- ==== Slot point definitions (from your original slot) ====
    function draw_slot(angle, h, w_open, w_body,r_arc1, r_arc)
        local y_base = rotor_inner_slot_radius  -- starting height from center

        r1=w_body
        r2=w_open
        h2=r_arc1
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

        if rotor_type=="cage_type" then
            xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 1, 0, "Rotor", 0, 2, 1)
            mi_clearselected()
        end
    end
    mi_addcircprop("Rotor",0, 1)
    rotor_angle_step = 360 / rotor_num_slots
    for i = 0, rotor_num_slots - 1 do
        draw_slot(rotor_angle_step*i,rotor_slot_height,slot_width_r2,slot_width_r1,r_arc_top,r_arc_bottom)
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
    
    if rotor_type=="wounded_type" then
        rr_slot_inner = rotor_inner_slot_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
        r_slot_height = rotor_slot_height-2 --(coil winding space height)
        rr_between_slots = rr_slot_inner + r_slot_height / 2 -- Label radial position
        rotor_angle_step=360/rotor_num_slots


        -- q = slots / (poles * phases)
        q = my_div(rotor_num_slots, num_poles * num_phases)
        current1=0
        -- Define circuit properties
        mi_addcircprop("RA", current1, 1)
        mi_addcircprop("RC", current1, 1)
        mi_addcircprop("RB", current1, 1)
        mi_addcircprop("RA1",-current1,1)
        mi_addcircprop("RC1",-current1,1)
        mi_addcircprop("RB1",-current1,1)

        turn_per_coil=2
        h=rotor_slot_height
        -- Loop over all slots
        for i = 0, rotor_num_slots - 1 do
            local angle_deg = i * rotor_angle_step 
            local y_base = rotor_inner_slot_radius 

            turns=round(turn_per_coil/2)


            -- Determine which phase this slot gets based on integer logic
            local block = my_div(i, q)
            local phase_index = my_mod(block, 6)
            
            -- Assign phase name and turns without tables
            local phase_name = ""
            if phase_index == 5 then
                phase_name = "RA"
                angle=0
            elseif phase_index == 3 then
                phase_name = "RB"
                angle=120
            elseif phase_index == 1 then
                phase_name = "RC"
                angle=-120
                turns=-turns
            elseif phase_index == 2 then
                phase_name = "RA1"
                angle=0
                turns=turns
            elseif phase_index == 0 then
                phase_name = "RB1"
                angle=120
                turns=turns
            elseif phase_index == 4 then
                phase_name = "RC1"
                angle=-120
                turns=-turns
            end
            -- Add block label in center of slot
            local xlbl, ylbl = rotate(0,y_base+(rotor_slot_height/2),angle_deg)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 0, 1, phase_name, angle, 0, turns)
            mi_clearselected()
        end
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


        if rotor_type=="cage_type" then
            -- Add block label in center of slot
            
            xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 1, 0, "Rotor", 0, 0, 1)
            mi_clearselected()
        end
    end
    mi_addcircprop("Rotor",0, 1)
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
    
    if rotor_type=="wounded_type" then
        rr_slot_inner = rotor_inner_slot_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
        r_slot_height = rotor_slot_height-2 --(coil winding space height)
        rr_between_slots = rr_slot_inner + r_slot_height / 2 -- Label radial position
        rotor_angle_step=360/rotor_num_slots


        -- q = slots / (poles * phases)
        q = my_div(rotor_num_slots, num_poles * num_phases)
        current1=0
        -- Define circuit properties
        mi_addcircprop("RA", current1, 1)
        mi_addcircprop("RC", current1, 1)
        mi_addcircprop("RB", current1, 1)
        mi_addcircprop("RA1",-current1,1)
        mi_addcircprop("RC1",-current1,1)
        mi_addcircprop("RB1",-current1,1)

        turn_per_coil=2
        h=rotor_slot_height
        -- Loop over all slots
        for i = 0, rotor_num_slots - 1 do
            local angle_deg = i * rotor_angle_step 
            local y_base = rotor_inner_slot_radius 

            turns=round(turn_per_coil/2)


            -- Determine which phase this slot gets based on integer logic
            local block = my_div(i, q)
            local phase_index = my_mod(block, 6)
            
            -- Assign phase name and turns without tables
            local phase_name = ""
            if phase_index == 5 then
                phase_name = "RA"
                angle=0
            elseif phase_index == 3 then
                phase_name = "RB"
                angle=120
            elseif phase_index == 1 then
                phase_name = "RC"
                angle=-120
                turns=-turns
            elseif phase_index == 2 then
                phase_name = "RA1"
                angle=0
                turns=turns
            elseif phase_index == 0 then
                phase_name = "RB1"
                angle=120
                turns=turns
            elseif phase_index == 4 then
                phase_name = "RC1"
                angle=-120
                turns=-turns
            end
            -- Add block label in center of slot
            local xlbl, ylbl = rotate(0,y_base+(rotor_slot_height/2),angle_deg)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 0, 1, phase_name, angle, 0, turns)
            mi_clearselected()
        end
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



        if rotor_type=="cage_type" then
            -- Add block label in center of slot
            
            xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 1, 0, "Rotor", 0, 0, 1)
            mi_clearselected()
        end
    end
    mi_addcircprop("Rotor",0, 1)
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
    
    if rotor_type=="wounded_type" then
        rr_slot_inner = rotor_inner_slot_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
        r_slot_height = rotor_slot_height-2 --(coil winding space height)
        rr_between_slots = rr_slot_inner + r_slot_height / 2 -- Label radial position
        rotor_angle_step=360/rotor_num_slots


        -- q = slots / (poles * phases)
        q = my_div(rotor_num_slots, num_poles * num_phases)
        current1=0
        -- Define circuit properties
        mi_addcircprop("RA", current1, 1)
        mi_addcircprop("RC", current1, 1)
        mi_addcircprop("RB", current1, 1)
        mi_addcircprop("RA1",-current1,1)
        mi_addcircprop("RC1",-current1,1)
        mi_addcircprop("RB1",-current1,1)

        turn_per_coil=2
        h=rotor_slot_height
        -- Loop over all slots
        for i = 0, rotor_num_slots - 1 do
            local angle_deg = i * rotor_angle_step 
            local y_base = rotor_inner_slot_radius 

            turns=round(turn_per_coil/2)


            -- Determine which phase this slot gets based on integer logic
            local block = my_div(i, q)
            local phase_index = my_mod(block, 6)
            
            -- Assign phase name and turns without tables
            local phase_name = ""
            if phase_index == 5 then
                phase_name = "RA"
                angle=0
            elseif phase_index == 3 then
                phase_name = "RB"
                angle=120
            elseif phase_index == 1 then
                phase_name = "RC"
                angle=-120
                turns=-turns
            elseif phase_index == 2 then
                phase_name = "RA1"
                angle=0
                turns=turns
            elseif phase_index == 0 then
                phase_name = "RB1"
                angle=120
                turns=turns
            elseif phase_index == 4 then
                phase_name = "RC1"
                angle=-120
                turns=-turns
            end
            -- Add block label in center of slot
            local xlbl, ylbl = rotate(0,y_base+(rotor_slot_height/2),angle_deg)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 0, 1, phase_name, angle, 0, turns)
            mi_clearselected()
        end
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
    function draw_slot(angle, h,h1,h22,h23,h25,w_open, w_body)
        local y_base = rotor_inner_slot_radius  -- starting height from center

        w1=w_body
        w2=w_open
        w3=w1*0.25

        if rotor_type_slot=="open" then
            w3=w1
        end
        -- Neck opening
        x1, y1 = rotate(0, y_base, angle)
        x2, y2 = rotate(w2 / 2, y_base + h25, angle)
        x3, y3 = rotate(-w2 / 2, y_base + h25, angle)

        -- Body width near arc start
        x4, y4 = rotate(w1 / 2, y_base + h1 -h23, angle)
        x5, y5 = rotate(-w1 / 2, y_base + h1 - h23, angle)

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

        if rotor_type=="cage_type" then
            -- Add block label in center of slot
            
            xlbl, ylbl = rotate(0, y_base + h * 0.4, angle)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 1, 0, "Rotor", 0, 0, 1)
            mi_clearselected()
        end
    end
    mi_addcircprop("Rotor",0, 1)
    rotor_angle_step = 360 / rotor_num_slots
    for i = 0, rotor_num_slots - 1 do
        draw_slot(rotor_angle_step*i,rotor_slot_height,down_slot_height,slot_bwt_height,r_arc_top,r_arc_bottom,slot_width_r2,slot_width_r1)
    end
    function connect_slot_bottoms(slot_count, h, w_body,w_open)
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
    connect_slot_bottoms(rotor_num_slots,rotor_slot_height,slot_width_r1,slot_width_r2)  -- adjust values to match your draw_slot

    if rotor_type_slot=="closed" then
        mi_addnode(rotor_outer_radius,0)
        mi_addnode(-rotor_outer_radius,0)
        mi_addarc(rotor_outer_radius, 0, -rotor_outer_radius, 0, 180, 1)
        mi_addarc(-rotor_outer_radius, 0, rotor_outer_radius, 0, 180, 1)
    end

    if rotor_type=="wounded_type" then
        rr_slot_inner = rotor_inner_slot_radius+2 -- Radius to slot inner edge(distance between the new line there created above to center)
        r_slot_height = rotor_slot_height-2 --(coil winding space height)
        rr_between_slots = rr_slot_inner + r_slot_height / 2 -- Label radial position
        rotor_angle_step=360/rotor_num_slots


        -- q = slots / (poles * phases)
        q = my_div(rotor_num_slots, num_poles * num_phases)
        current1=0
        -- Define circuit properties
        mi_addcircprop("RA", current1, 1)
        mi_addcircprop("RC", current1, 1)
        mi_addcircprop("RB", current1, 1)
        mi_addcircprop("RA1",-current1,1)
        mi_addcircprop("RC1",-current1,1)
        mi_addcircprop("RB1",-current1,1)

        turn_per_coil=2
        h=rotor_slot_height
        -- Loop over all slots
        for i = 0, rotor_num_slots - 1 do
            local angle_deg = i * rotor_angle_step 
            local y_base = rotor_inner_slot_radius 

            turns=round(turn_per_coil/2)


            -- Determine which phase this slot gets based on integer logic
            local block = my_div(i, q)
            local phase_index = my_mod(block, 6)
            
            -- Assign phase name and turns without tables
            local phase_name = ""
            if phase_index == 5 then
                phase_name = "RA"
                angle=0
            elseif phase_index == 3 then
                phase_name = "RB"
                angle=120
            elseif phase_index == 1 then
                phase_name = "RC"
                angle=-120
                turns=-turns
            elseif phase_index == 2 then
                phase_name = "RA1"
                angle=0
                turns=turns
            elseif phase_index == 0 then
                phase_name = "RB1"
                angle=120
                turns=turns
            elseif phase_index == 4 then
                phase_name = "RC1"
                angle=-120
                turns=-turns
            end
            -- Add block label in center of slot
            local xlbl, ylbl = rotate(0,y_base+(rotor_slot_height/2),angle_deg)
            mi_addblocklabel(xlbl, ylbl)
            mi_selectlabel(xlbl, ylbl)
            mi_setblockprop(rotor_circuit_material, 0, 1, phase_name, angle, 0, turns)
            mi_clearselected()
        end
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





mi_setsegmentprop("AZero", 0, 1, 0)
mi_clearselected()
mi_addboundprop("A1",0,0,0,0,0,0,0,0,0)
mi_setsegmentprop("A1", 0,1,0,0)


-- Calculate square side length: make it slightly bigger than the circle
square_side = (outer_stator_radius*2)+(outer_stator_radius*0.4)  -- 1 cm margin on each side
-- Half side for positioning
half_side = square_side / 2
-- Draw square (clockwise from top-left)
mi_drawline(-half_side,  half_side,  half_side,  half_side)
mi_drawline( half_side,  half_side,  half_side, -half_side)
mi_drawline( half_side, -half_side, -half_side, -half_side)
mi_drawline(-half_side, -half_side, -half_side,  half_side)
xo, yo = (outer_stator_radius), (outer_stator_radius)
mi_addblocklabel(xo, yo)
mi_selectlabel(xo, yo)
mi_setblockprop("Air", 1, 0, "", 0, 0, 1)
mi_clearselected()