if myHero.charName ~= "Sona" or not VIP_USER then return end

--A basic BoL template for the Eclipse Lua Development Kit module's execution environment written by Nader Sl.
player = GetMyHero()

-- called once when the script is loaded
function OnLoad()

require "SxOrbwalk" 
require "VPrediction"
print("<b><font color=\"#FF001E\"> Baguette </font></b><font color=\"#FF980F\"> Sona </font><font color=\"#FF001E\"></font><b><font color=\"#FF001E\"> loaded </font></b><font color=\"#FF980F\"> loaded </font><font color=\"#FF001E\"></font><b><font color=\"#FF001E\"> GL&HF </font></b><font color=\"#FF980F\">")
TargetSelector = TargetSelector(TARGET_MOST_AD, 1400, DAMAGE_MAGICAL, false, true)
Variables()
Menu()
end

-- handles script logic, a pure high speed loop
function OnTick()

Checks()
TargetSelector:update()
Target = GetCustomTarget()
SxOrb:ForceTarget(Target)
CastAutoR()


  if Target ~= nil then
  if Settings.combo.comboKey then
      Combo(Target)
    end
  end
  if Target ~= nil then
  if Settings.harass.harass then
    Harass(Target)
    end
    end
end

--handles overlay drawing (processing is not recommended here,use onTick() for that)
function OnDraw()
  if not myHero.dead then 
    if ValidTarget(Target) then 
      DrawText3D("Current Target",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFF00)
      DrawCircle(Target.x, Target.y, Target.z, 150, ARGB(200,100 ,100,0 ))
    end
    
    if SkillQ.ready and Settings.Draw.DrawQ then 
      DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, ARGB(200,50 ,100,0 ))
    end
    if SkillE.ready and Settings.Draw.DrawE then 
      DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, ARGB(200,50 ,100,0 ))
    end
    if SkillR.ready and Settings.Draw.DrawR then 
      DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, ARGB(200,50 ,100,0 ))
    end
  end
end

--handles input
function OnWndMsg(msg,key)

end

-- listens to chat input
function OnSendChat(txt)

end

-- listens to spell
function OnProcessSpell(owner,spell)

end

-- Check
function Checks()
  SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
  SkillW.ready = (myHero:CanUseSpell(_W) == READY)
  SkillE.ready = (myHero:CanUseSpell(_E) == READY)
  SkillR.ready = (myHero:CanUseSpell(_R) == READY)
  _G.DrawCircle = _G.oldDrawCircle
end

-- custom target
function GetCustomTarget()
  if SelectedTarget ~= nil and ValidTarget(SelectedTarget, 1500) and (Ignore == nil or (Ignore.networkID ~= SelectedTarget.networkID)) then
    return SelectedTarget
  end
  TargetSelector:update() 
  if TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
    return TargetSelector.target
  else
    return nil
  end
end

-- Menu
function Menu()
Settings = scriptConfig("Baguette SONA", "sona")    
 
Settings:addSubMenu("["..myHero.charName.."] - Combo", "combo")
Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("32"))
Settings.combo:addParam("UseR", "Use (R)", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("N"))
Settings.combo:addParam("UseQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
Settings.combo:addParam("UseE", "Use (E)", SCRIPT_PARAM_ONOFF, true)

Settings:addSubMenu("["..myHero.charName.."] - Harass", "harass")
Settings.harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
Settings.harass:addParam("UseR", "Use (R)", SCRIPT_PARAM_ONOFF, false)
Settings.harass:addParam("UseQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
Settings.harass:addParam("UseE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
Settings.harass:addParam("manah", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 60, 0, 1000, 0)

Settings:addSubMenu("["..myHero.charName.."] - Auto Ult ", "AutoUlt")
Settings.AutoUlt:addParam("UseAutoR", "Auto R if X enemie", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("C"))
Settings.AutoUlt:addParam("ARX", "X = ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)

Settings:addSubMenu("["..myHero.charName.."] - Draw", "Draw")
Settings.Draw:addParam("DrawQ", "Draw (Q)", SCRIPT_PARAM_ONOFF, true)
Settings.Draw:addParam("DrawE", "Draw (E)", SCRIPT_PARAM_ONOFF, true)
Settings.Draw:addParam("DrawR", "Draw (R)", SCRIPT_PARAM_ONOFF, true)

Settings.combo:permaShow("comboKey")
Settings.harass:permaShow("harass")
Settings.combo:permaShow("UseR")
Settings.AutoUlt:permaShow("UseAutoR")
Settings.AutoUlt:permaShow("ARX")
      
Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
    SxOrb:LoadToMenu(Settings.Orbwalking) 
    TargetSelector.name = "Sona"
  Settings:addTS(TargetSelector)    
end

-- Spell function
function CastQ(unit)
if Settings.combo.UseQ then
  if unit.team ~= myHero.team and unit.visible and unit.dead == false and myHero:GetDistance(unit) < 845 then
  CastSpell(_Q)
  end
end
end

function CastE(unit)
if Settings.combo.UseE then
  if unit.team ~= myHero.team and unit.visible and unit.dead == false and myHero:GetDistance(unit) < 650 then
  CastSpell(_E)
  end
end
end

function CastR(unit)
if Settings.combo.UseR then
  if unit ~= nil and GetDistance(unit) <= 900 and SkillR.ready then
    CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, SkillR.delay, SkillR.width, SkillR.range, SkillR.speed, myHero, false) 
    if HitChance >= 2 then
      Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
    end
  end
end
end

-- Spell function harass
function HarassQ(unit)
if Settings.harass.UseQ and myHero.mana >= Settings.harass.manah then
  if unit.team ~= myHero.team and unit.visible and unit.dead == false and myHero:GetDistance(unit) < 845 then
  CastSpell(_Q)
  end
end
end

function HarassE(unit)
if Settings.harass.UseE and myHero.mana >= Settings.harass.manah then
  if unit.team ~= myHero.team and unit.visible and unit.dead == false and myHero:GetDistance(unit) < 650 then
  CastSpell(_E)
  end
end
end

function HarassR(unit)
if Settings.harass.UseR and myHero.mana >= Settings.harass.manah then
  if unit ~= nil and GetDistance(unit) <= 900 and SkillR.ready then
    CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, SkillR.delay, SkillR.width, SkillR.range, SkillR.speed, myHero, false) 
    if HitChance >= 2 then
      Packet("S_CAST", {spellId = _R, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
    end
  end
end
end

-- combo
function Combo(unit)
    CastQ(unit)
    myHero:Attack(unit)
    CastR(unit)
    CastE(unit)
end
-- harass
function Harass(unit)
    HarassQ(unit)
    HarassR(unit)
    HarassE(unit)
end


--variables
function Variables()
SkillQ = { range = 845, width = 700, speed = 1500, delay = .5, spellType = "selfCast", riskLevel = "kill", cc = false, hitLineCheck = false, ready = false }
SkillW = { range = 1000, width = 1000, speed = 1500, delay = .5, spellType = "selfCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _W, ready = false }
SkillE = { range = 650, width = 1000, speed = 1500, delay = .5, spellType = "selfCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, ready = false }
SkillR = { range = 900, width = 125, speed = 2400, delay = .5, spellType = "skillShot", riskLevel = "extreme", cc = true, hitLineCheck = true, timer = 0, ready = false }
  
VP = VPrediction()
_G.oldDrawCircle = rawget(_G, 'DrawCircle')
_G.DrawCircle = DrawCircle2
  
end

-- selector
function OnWndMsg(Msg, Key) 
  
  if Msg == WM_LBUTTONDOWN then
    local minD = 0
    local Target = nil
    for i, unit in ipairs(GetEnemyHeroes()) do
      if ValidTarget(unit) then
        if GetDistance(unit, mousePos) <= minD or Target == nil then
          minD = GetDistance(unit, mousePos)
          Target = unit
        end
      end
    end

    if Target and minD < 115 then
      if SelectedTarget and Target.charName == SelectedTarget.charName then
        SelectedTarget = nil
      else
        SelectedTarget = Target
      end
    end
  end
end

-- Cercle selector
function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
end

--auto R
function CastAutoR()
if SkillR.ready then
if Settings.AutoUlt.UseAutoR then
  for _, unit in pairs(GetEnemyHeroes()) do
      local rPos, HitChance, maxHit, Positions = VP:GetCircularAOECastPosition(unit, SkillR.delay, SkillR.width, SkillR.range, SkillR.speed, myHero)
      if ValidTarget(unit, SkillR.range) and rPos ~= nil and maxHit >= Settings.AutoUlt.ARX then
          Packet("S_CAST", {spellId = _R, fromX = rPos.x, fromY = rPos.z, toX = rPos.x, toY = rPos.z}):send()
      end
    end
  end
end
end