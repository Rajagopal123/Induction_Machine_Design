-- === USER-DEFINED MATH FUNCTIONS ===
PI = 3.141592653589793
E = 2.718281828459045

function sqrt(x)
    local guess = x / 2
    for i = 1, 20 do
        guess = (guess + x / guess) / 2
    end
    return guess
end

function pow(x, y)
    if y == 0 then return 1 end
    local result = 1
    local neg = false
    if y < 0 then
        y = -y
        neg = true
    end
    for i = 1, y do
        result = result * x
    end
    if neg then
        result = 1 / result
    end
    return result
end

function sin(x)
    local term = x
    local sum = x
    for i = 1, 10 do
        term = -term * x * x / ((2 * i) * (2 * i + 1))
        sum = sum + term
    end
    return sum
end

function cos(x)
    local term = 1
    local sum = 1
    for i = 1, 10 do
        term = -term * x * x / ((2 * i - 1) * (2 * i))
        sum = sum + term
    end
    return sum
end

function rad(deg)
    return deg * PI / 180
end

function abs(x)
    if x < 0 then
        return -x
    else
        return x
    end
end

function truncate(x)
    local n = 0
    if x >= 0 then
        while n + 1 <= x do
            n = n + 1
        end
        return n
    else
        while n - 1 >= x do
            n = n - 1
        end
        return n
    end
end

function round(x)
    local int_part = truncate(x)
    local frac = x - int_part

    if x >= 0 then
        if frac >= 0.0 then
            return int_part + 1
        else
            return int_part
        end
    else
        if frac <= -0.5 then
            return int_part - 1
        else
            return int_part
        end
    end
end

function optimal_rotor_slot(Ss, P)     -- page no 294, section: 6.11.1
    local Sr = Ss - 1

    while Sr > 0 do
        local diff = abs(Ss - Sr)

        if Sr ~= Ss and
           diff ~= P and
           diff ~= 2*P and
           diff ~= 3*P and
           diff ~= 5*P then
            return Sr
        end

        Sr = Sr - 1
    end

    return -1  -- No valid rotor slot found
end

--=====================================================================================================

-- === INPUTS (User-defined) ===
P_out = 30000                                    --output power (W) or rated power (W)
V_ll = 400                                    --line-to-line voltage (V)
f = 50                                          --frequency (Hz)
P = 4                                          --number of poles
Dos = 0.27                                         --outer diameter of stator (m)
Bt = 1.2                                        --maximum stator tooth flux density (T)
Js_rms = 4e6                                    -- current density (A/m^2) for suitable rated machine
k1 = 0.95                                       -- winding factor
slip = 0.05                                     --slip 
efficiency = 0.95                                --efficiency
PF = 0.8                                        --power factor
Ks1 = 8000                                     -- Surface current density (A/m)
k_fill=0.6                                      --copper fill factor

stator_slots = 36                              --number of stator slots
rotor_slots = optimal_rotor_slot(stator_slots, P)
--To avoid cogging and crawling: Sr ≠ Ss, Ss - Sr ≠ ±3P
--To avoid synchronous hooks and cusps in torque speed characteristics Ss - Sr ≠ ±P,±2P, ±5P
num_phases=3
stator_winding_material="Copper"
stator_core_material="M-19 Steel"
rotor_circuit_material="Aluminum"
rotor_core_material="M-19 Steel"
shaft_material="Air"


-- for : "Trapezoidal_curved_corner"
-- For : "Rectangular curved corner"
-- for "Trapezoidal_slot"
-- for "Rectangular_slot"
-- for your own slot shape, input is "user_defined" and go to the user defined section and enter the dimension of slot as per diagram.
stator_slot_shaper = "Trapezoidal_curved_corners"  --Rectangular_slot
--Trapezoidal_slot
--Trapezoidal_curved_corners

-- open or semi_closed or closed
stator_slot_type="semi_closed"



-- "Rectangular_slot" or "circular_slot" or
-- "Trapezial_slot" or "Key_hole_single_cage_slot" or
-- "key_hole_double_cage_slot"
rotor_shaper = "key_hole_single_cage_slot" 

-- open or semi_closed or closed
rotor_type_slot="semi_closed"


-- cage_type or wounded_type
rotor_type="cage_type"

tooth_top_height=0.001  --1mm

  --"Performance and Design of AC Machines" – M.G. Say
  --“The height of the slot is generally two to four times its width, though for larger machines the ratio may go higher depending on flux and thermal considerations.”
  --Chapter 7: Induction Motor Design, Slot Proportions
  
  --Small motors (fractional hp): 2:1 to 3:1
  --Medium motors (1–100 kW): 3:1 to 4:1
  --Large motors (>100 kW): 4:1 to 5:1 (to save space, improve cooling, reduce leakage)
  dim_fatcor=3  -- give any as per above info
  dim_factor1=1.5
--“Electrical Machine Design” – A.K. Sawhney
--“For trapezoidal slots, the slot opening is 1.2–1.5 times the slot base. The height-to-average width ratio is usually taken 2–4.”
--========================================================================================================




-- === DERIVED VALUES ===
Ns = 120 * f / P
omega_e = 2 * PI * f
omega_m = omega_e / (P / 2)
tau_p = PI * Dos / P
Vs = V_ll / sqrt(3)
mu0 = 4 * PI * 1e-7
-- STEP 1: Electromagnetic torque
T_e = P_out / omega_m
-- Torque from output power and mechanical angular speed.
-- P_out = T_e * omega_m  ⇒ Equation 1.6 (Chapter 1)


-- STEP 2 & 3: Air gap flux density
Bg1 = 0.5 * Bt
-- Empirical assumption, Bg1 = 0.5 * Bts, as used in several examples.
-- See Pg. 271 and Eq. (6.42): Bg1 = P * φp / (2 * Dis * le)


-- STEP 4: Linear current density
Ks = Ks1      --Table 6.6, 6.7 (choosing directly from the table) 
-- Linear current density input (A/m). This is used in most sizing formulas.
-- Appears in Eq. (6.7), Pg. 259 and many later equations (like 6.62)


-- STEP 5: Use equation (6.77) to find optimal Dis/Dos
a = 0.6                --a is typically set to 0.4–0.6    a and b are empirical fitting constants
b = 0.9                  --b is typically set to 0.2–0.9
kcu = 0.6           --Fill factor
Js = Js_rms             --Current density
term1 = (b / a) + (2 * Ks) / (a * kcu * Js * Dos)
under_root = (term1 * term1) - (1 / a)
print("underroot ",under_root)
if under_root < 0 then
    error("Invalid parameters: negative value under square root in Dis/Dos calculation.")
end

Dis_Dos = term1 - sqrt(under_root)   -- From Equation (6.77), Pg. 276:
Dis = Dis_Dos * Dos               -- Used to optimize the stator inner diameter for efficiency and fill factor






-- STEP 6: Check feasibility of Dis/Dos
n = (3 * a * Dis_Dos * Dis_Dos) - (4 * b * Dis_Dos) + 1
d = ((kcu * Js_rms) / 4) * ((Dis_Dos * Dis_Dos) - a)
epci = n / d                        -- This uses Equation (6.78), Pg. 276
if epci < 0 then
    print("Dis/Dos too small! Increase Js_rms or adjust design.")
else
    print("Dis/Dos is feasible.")   -- It checks if the selected Dis/Dos leads to a physically feasible design
end
print()



-- STEP 7: Solve for effective length le using equation (6.62)
ratio = Dis_Dos
omega_mech = 2 * PI * Ns / 60        --angular speed in rad per sec
k1 = 0.9                              --winding utilization factor
kcu = k_fill                          --fill factor
eta_gap = 0.95                        --Gap efficiency(0.94–0.97)
theta_gap = rad(0)                    --power factor angle at the airgap(assuming unity PF (cosθ = 1) at the airgap)
a = 0.4                               --empirical design constants
b = 0.2                               --  a = 0.4 to 0.6 and b = 0.2 to 0.3
bracket_term = a * pow(ratio, 3) - 2 * b * pow(ratio, 2) + ratio
numerator = 480 * (P_out / omega_mech)
denominator = (sqrt(2) * PI * PI * k1 * kcu * eta_gap * cos(theta_gap) *
               pow(Dos, 3) * Bg1 * Js_rms * bracket_term)
le = numerator / denominator              -- Equation (6.62), Pg. 273:
print(le)
-- Check aspect ratio
aspect_ratio = (P * le) / (PI * Dis)   --pgae:297

-- STEP 8: Estimate MMF per pole Fp1
g = 0.003 * sqrt(P / 2) * tau_p   --Mechanical air gap (equation6.111 page: 293)   
if g<0.001 then                   -- making the minimum airgap to 1mm( to avoid the intersection of stator and rotor)
    g=0.001
end
ge = 2.5 * g     -- Kc=2.5 typical value
Fp1 = Bg1 * ge / mu0 
-- Equation (3.77), Pg. 119:
-- Fp1 = Bg1 * ge / μ0 ⇒ MMF required to produce Bg1 across effective gap

print(Fp1)
-- STEP 9: Magnetizing component of stator surface current density
Ksm = (P / Dis) * Fp1       -- Equation (3.63) and (6.7), Pg. 107 & 273

-- STEP 10: Torque-producing component of Ks
Kst = sqrt((Ks * Ks) - (Ksm * Ksm))       -- (page: 297)Assumes orthogonal magnetic field and torque components ⇒ Pythagorean

-- STEP 11: Permeance ratio
Pls_Pms_ratio = 0.3    -- Typical value discussed on Pg. 298, Step 11
-- leakage inductance is typically a fraction of the magnetizing inductance — usually around 25% to 40% depending on the machine type, slot design, and construction.
-- we cant find pls(equ 4.265) and pms(equ 3.76) formula, because it need Ns(no of turns) 


-- STEP 12: Vm
Kst_Ksm_ratio = Kst / Ksm

Vs_Vm_ratio = Pls_Pms_ratio + (Pls_Pms_ratio * Kst_Ksm_ratio) + 1

Vm = Vs / Vs_Vm_ratio       -- Step 12, Pg. 298:

-- STEP 13: Flux linkage
lambda_m = Vm / (2 * PI * f)        --Pg. 298, Step 13

-- STEP 14: Turns per phase Ns
Ns = (lambda_m * P) / (2 * k1 * Bg1 * le * Dis)    -- See Eq. (3.87) and Pg. 298 Step 14





print()
-- Get current per phase (line)
P_in=P_out/efficiency
I_ph = P_in / (3* Vs * PF)

B_ts = Bt                        --maximum allowed flux density in the stator tooth
li = le  



-- Slots per phase
slots_per_phase = stator_slots / 3
conductor_per_phase=2*Ns
total_conductors=num_phases*conductor_per_phase
A_cu_total=total_conductors*(I_ph/Js_rms)
-- single layr winding 
--each slot has 1 conductor per phase (because turns are distributed)
-- but still we have total_conductors more than no of slots_per_phase

conductor_per_slot=round(total_conductors/stator_slots)
A_cu_per_slot=conductor_per_slot*(I_ph/Js_rms)

A_slot=A_cu_per_slot/k_fill




if stator_slot_shaper=="Trapezoidal_slot"then
  s_width_avg=sqrt(A_slot/dim_fatcor)
  s_height= dim_fatcor*s_width_avg
  s_width2=(2/(1+dim_factor1))*sqrt(A_slot/dim_fatcor)
  s_width1=dim_factor1*s_width2
elseif stator_slot_shaper=="Rectangular_slot" then
  s_width1=sqrt(A_slot/dim_fatcor)
  s_height= dim_fatcor*s_width1
  s_width2=s_width1
elseif stator_slot_shaper=="Trapezoidal_curved_corners" then
    s_width_avg=sqrt(A_slot/dim_fatcor)
    s_height= dim_fatcor*s_width_avg
    s_width2=(2/(1+dim_factor1))*sqrt(A_slot/dim_fatcor)
    s_width1=dim_factor1*s_width2
elseif stator_slot_shaper=="Rectangular_curved_corners" then
    s_width1=sqrt(A_slot/dim_fatcor)
    s_height= dim_fatcor*s_width1
    s_width2=s_width1
end



dcs=(Dos*0.5)-(Dis*0.5)-s_height-tooth_top_height
tau_s = PI *2* (Dos*0.5-dcs) / stator_slots
t_ts1=tau_s-s_width1
t_ts2=tau_s-s_width2
t_th=s_height+tooth_top_height


D_ir = Dis - 2 * g            --rotor outer diameter
tau_r = PI * D_ir / rotor_slots       --rotor slot pitch based on stator slt pitch formula
t_tr = tau_r* (Bg1 / B_ts) * (le / li)
r_width = tau_r - t_tr
r_height=s_height/1.5 





-- magnetizing inductance equation page: 120 and equation 3.85
Lm=(3*PI/4)*(((4*k1*Ns)/PI)/(P))*(((4*k1*Ns)/PI)/(P))*((mu0*Dis*le)/(ge))   
Im=Vs/(2*PI*f*Lm)        -- normal current formula
current=Im

-- Recomputed air gap flux density for verification
phi_p = (2 * k1 * Dis * le * Bg1) / P    -- flux per pole
B_g1_calc = (P * phi_p) / (2 * Dis * le)   --Page: 271  Equation: (6.42)



-- STATOR PARAMETERS
num_slots_s = stator_slots
num_poles = P
num_phases = 3
axial_length=le*100
outer_stator_radius = Dos*100*0.5
stator_inner_radius = Dis*100*0.5
stator_turns_per_phase=round(Ns)
stator_slot_height=s_height*100
stator_tooth_height=t_th*100
stator_core_thickness = (outer_stator_radius - stator_inner_radius-stator_tooth_height)
stator_slot_pitch=tau_s*100

stator_slot_width1=s_width1*100
stator_slot_width2=s_width2*100
stator_tooth_width1=t_ts1*100
stator_tooth_width2=t_ts2*100


-- ROTOR PARAMETERS
rotor_num_slots = rotor_slots
outer_rotor_diameter= (Dis- 2*g)*100
rotor_slot_pitch=tau_r*100
rotor_slot_width=r_width*100
rotor_slot_height=r_height*100
rotor_tooth_width=t_tr*100
rotor_tooth_height=(r_height*100)+tooth_top_height*100

airgap=g*100




print("Effective length (le) cm",axial_length)
print(" airgap length cm",airgap)

print()
print("             STATOR DESIGN PARAMETERS                     ")
print()
print("outer radius of the stator (cm) D_os:",outer_stator_radius)
print("inner radius of the stator (cm) D_is:",stator_inner_radius)
print("Dis/Dos Ratio:", Dis_Dos)
print("number of turns per phase : ",stator_turns_per_phase)
print("total no of stator slot: ",stator_slots)
print("stator core thickness cm :",stator_core_thickness)
print("stator slot pitch cm: ",tau_s*100)
print()
print("stator slot width1 cm: ",stator_slot_width1)
print("stator slot width2 cm: ",stator_slot_width2)
print("stator slot height cm: ",stator_slot_height)
print("stator tooth width1 cm: ",stator_tooth_width1)
print("stator tooth width2 cm: ",stator_tooth_width2)
print("stator tooth height cm: ",stator_tooth_height)

print("Recomputed_air_gap_flux_density : ",B_g1_calc)



print()
print("    ROTOR DESIGN PARAMETERS    ")
print()

print("Rotor outer radius (D_ir): cm",outer_rotor_diameter*0.5)
print("total no of rotor slots: ",rotor_slots)
print("rotor slot pitch cm : ",rotor_slot_pitch)
print()
print("rotor slot width cm: ",rotor_slot_width)
print("rotor slot height cm: ",rotor_slot_height)
print("rotor tooth width cm: ",rotor_tooth_width)
print("rotor tooth height cm: ",rotor_tooth_height)



