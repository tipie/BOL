if myHero.charName ~= "Tristana" or not VIP_USER then return end
--require 'HPrediction'
require "VPrediction"
local Version = "0.002"
local AutoUpdate = true
function ScriptMsg(msg)
  print("<font color=\"#daa520\"><b>Tristana Baguette:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

---------------------------------------------------------------------------------

local Host = "raw.github.com"

local ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

local ScriptPath = "tipie/BOL/master/Tristana-baguette.lua".."?rand="..math.random(1,10000) 
local UpdateURL = "https://"..Host..ScriptPath

local VersionPath = "tipie/BOL/master/Tristana-baguette.version".."?rand="..math.random(1,10000)
local VersionData = tonumber(GetWebResult(Host, VersionPath))

if AutoUpdate then

  if VersionData then
  
    ServerVersion = type(VersionData) == "number" and VersionData or nil
    
    if ServerVersion then
    
      if tonumber(Version) < ServerVersion then
        ScriptMsg("New version available: v"..VersionData)
        ScriptMsg("Updating, please don't press F9.")
        DelayAction(function() DownloadFile(UpdateURL, ScriptFilePath, function () ScriptMsg("Successfully updated.: v"..Version.." => v"..VersionData..", Press F9 twice to load the updated version.") end) end, 3)
      else
        ScriptMsg("You've got the latest version: v"..Version)
      end
      
    end
    
  else
    ScriptMsg("Error downloading version info.")
  end
  
else
  ScriptMsg("AutoUpdate: false")
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

-- called once when the script is loaded
function OnLoad()
print("<b><font color=\"#FF001E\"> Tristana </font></b><font color=\"#FF980F\"> baguette </font><font color=\"#FF001E\"></font><b><font color=\"#FF001E\"> loaded </font><font color=\"#FF001E\"><font color=\"#FF980F\"> GL </font><font color=\"#FF001E\"></font><b><font color=\"#FF001E\"> & </font><font color=\"#FF001E\"><font color=\"#FF980F\"><font color=\"#FF001E\"><font color=\"#FF980F\"> HF </font><font color=\"#FF001E\"></font>")
TargetSelector = TargetSelector(TARGET_LOW_HP_PRIORITY, 920)
Variables()
Menu()
Checkorbwalk()
--HPred = HPrediction()
--Spell_W.delay['Tristana'] = 0.5
--Spell_W.range['Tristana'] = 900
--Spell_W.speed['Tristana'] = 1150
--Spell_W.type['Tristana'] = "PromptCircle"
--Spell_W.width['Tristana'] = 270
--Spell_W.radius['Tristana'] = 200

end

-- handles script logic, a pure high speed loop
function OnTick()
  Checks()
  TargetSelector:update()
  Target = GetCustomTarget()
if SxOrbLoaded then
  SxOrb:ForceTarget(Target)
end

if Target ~= nil and Settings.Key.comboKey then
   Combo(Target)
end

if Target ~= nil then
   KS(Target)
end
    
if Target ~= nil and Settings.Key.harass then
   Harass(Target)
end 

if Target ~= nil and Settings.Key.AutoR then
   CastR(Target)
end 

TristanaRange = range()

end

--handles overlay drawing (processing is not recommended here,use onTick() for that)
function OnDraw()
    if not myHero.dead then 
      if ValidTarget(Target) then 
        DrawText3D("Current Target",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFF00)
        DrawCircle(Target.x, Target.y, Target.z, 150, ARGB(200,100 ,100,0 ))
        end
      end 
            
      if Settings.Draw.DrawE then 
        DrawCircle(myHero.x, myHero.y, myHero.z, TristanaRange, ARGB(200,50 ,100,0 ))
      end
      if SkillW.ready and Settings.Draw.DrawW then 
        DrawCircle(myHero.x, myHero.y, myHero.z, 900, ARGB(200,50 ,100,0 ))
      end
     -- if Settings.Draw.DrawRange then 
     --    DrawCircle(myHero.x, myHero.y, myHero.z, Settings.Draw.Range, ARGB(200,50 ,100,0 ))
      --end
end

-- Function -----------------------------------------------------------------------

-- Menu
function Menu()
  Settings = scriptConfig("Tristana baguette", "tristana")    
   
  Settings:addSubMenu("["..myHero.charName.."] - Combo", "combo")
  Settings.combo:addParam("UseQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
  Settings.combo:addParam("UseE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
  Settings.combo:addParam("UseW", "Use (W)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("P"))
  Settings.combo:addParam("UseWMYHP", "Use (W) if my hp > or = ", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)
  Settings.combo:addParam("UseWHP", "Use (W) if target hp < or = ", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
  Settings.combo:addSubMenu("Use (E) on : ", "BlackListA")
  Settings.combo:addSubMenu("Use (W) on : ", "BlackListW")
  if #GetEnemyHeroes() > 0 then
  for idx, enemy in ipairs(GetEnemyHeroes()) do
  Settings.combo.BlackListA:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
  Settings.combo.BlackListW:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
  end
  end
  
  Settings:addSubMenu("["..myHero.charName.."] - Harass", "harass")
  Settings.harass:addParam("HarassQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
  Settings.harass:addParam("HarassE", "Use (E)", SCRIPT_PARAM_ONOFF, true) 
  Settings.harass:addParam("manah", "Min Mana To Harass (%)", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
  Settings.harass:addSubMenu("Use (E) on : ", "BlackListB")
  if #GetEnemyHeroes() > 0 then
  for idx, enemy in ipairs(GetEnemyHeroes()) do
  Settings.harass.BlackListB:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
  end
  end 
      
  Settings:addSubMenu("["..myHero.charName.."] - Draw", "Draw")
  Settings.Draw:addParam("DrawE", "Draw (E)/ (R)/ (AA)", SCRIPT_PARAM_ONOFF, true)
  Settings.Draw:addParam("DrawW", "Draw (W)", SCRIPT_PARAM_ONOFF, true)
  Settings.Draw:addParam("DrawRange", "Range", SCRIPT_PARAM_ONOFF, false)
--  Settings.Draw:addParam("Range", "Range", SCRIPT_PARAM_SLICE, 550, 500, 1000, 0)
  
  Settings:addSubMenu("["..myHero.charName.."] - Key ", "Key")
  Settings.Key:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("32"))
  Settings.Key:addParam("comboKey", "Combo Key (toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
  Settings.Key:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
  Settings.Key:addParam("harass", "Harass key (2)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
  Settings.Key:addParam("harass", "Harass (toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("W")) 
  Settings.Key:addParam("AutoR", "Auto aim (R)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("222"))
    
  Settings:addSubMenu("["..myHero.charName.."] - Misc", "Misc")
  Settings.Misc:addParam("KSR", "Auto KS with (R)", SCRIPT_PARAM_ONOFF, true)
  Settings.Misc:addParam("KSE", "Auto KS with (E)", SCRIPT_PARAM_ONOFF, true)
  Settings.Misc:addParam("KSW", "Auto KS with (W)", SCRIPT_PARAM_ONOFF, false)
  Settings.Misc:addParam("Prediction","Choose Prediction : ", SCRIPT_PARAM_LIST, 1, {"Vpred"})
  Settings.Misc:addParam("W", "HPred hitchance (Default = 1.25)", SCRIPT_PARAM_SLICE, 1.25, 1, 3, 2)
  
  if #GetEnemyHeroes() > 0 then
  Settings:addSubMenu("["..myHero.charName.."] - Use KS on : ", "BlackList")
  for idx, enemy in ipairs(GetEnemyHeroes()) do
  Settings.BlackList:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
  end
  end    
  
  Settings.Key:permaShow("comboKey")
  Settings.Key:permaShow("harass")
  Settings.Key:permaShow("AutoR")
      
  TargetSelector.name = "Tristana"
  Settings:addTS(TargetSelector)    
  end

-- Check
function Checks()
    SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
    SkillW.ready = (myHero:CanUseSpell(_W) == READY)
    SkillE.ready = (myHero:CanUseSpell(_E) == READY)
    SkillR.ready = (myHero:CanUseSpell(_R) == READY)
    _G.DrawCircle = _G.oldDrawCircle
end
  
-- Variables
function Variables()
  SkillQ = { range = 0, width = 0, speed = math.huge, delay = .5, spellType = "selfCast", riskLevel = "noDmg", cc = false, hitLineCheck = false }
  SkillW = { range = 900, width = 270, speed = 1150, delay = .5, spellType = "skillShot", riskLevel = "kill", cc = false, hitLineCheck = false }
  SkillE = { range = TristanaRange, width = 0, speed = 1400, delay = .5, spellType = "enemyCast", riskLevel = "kill", cc = false, hitLineCheck = false }
  SkillR = { range = TristanaRange, width = 0, speed = 1600, delay = .5, spellType = "enemyCast", riskLevel = "extreme", cc = true, hitLineCheck = false }
  RebornLoaded, SxOrbLoaded = false, false
  VP = VPrediction()
  _G.oldDrawCircle = rawget(_G, 'DrawCircle')
  _G.DrawCircle = DrawCircle2
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

  -- Spell function
function CastQ(unit)
 if Settings.combo.UseQ and SkillQ.ready then
   if unit.team ~= myHero.team and unit.visible and unit.dead == false and _G.AutoCarry.Orbwalker:IsShooting() then
    CastSpell(_Q)
     end
  end
end

function CastE(unit)
 if Settings.combo.UseE and _G.AutoCarry.Orbwalker:CanMove() and not _G.AutoCarry.Orbwalker:IsShooting() then
   if unit.team ~= myHero.team and unit.visible and unit.dead == false and myHero:GetDistance(unit) <= TristanaRange then
   if Settings.combo.BlackListA[unit.charName] and SkillE.ready then
      CastSpell(_E, unit)
      end
    end
  end
end

function CastW(unit)
local TargetHealthPercent = (Target.health/Target.maxHealth)*100
local MyHealthPercent = (myHero.health/myHero.maxHealth)*100
 if Settings.combo.UseW and SkillW.ready and Settings.combo.UseWHP >= TargetHealthPercent and MyHealthPercent >= Settings.combo.UseWMYHP and Settings.combo.BlackListW[unit.charName] then
   if unit.team ~= myHero.team and unit.visible and unit.dead == false and _G.AutoCarry.Orbwalker:CanMove() and not _G.AutoCarry.Orbwalker:IsShooting() and not EnemyUnderTheirTower then
    if Settings.Misc.Prediction == 1 then
              CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero, false) 
              if HitChance >= 2 then
              Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
              end
              else
              if Settings.Misc.Prediction == 2 then
              local RPos, RHitChance = HPred:GetPredict("W", unit, myHero)
               if WHitChance >= Settings.Misc.W then
               if VIP_USER then
               Packet("S_CAST", {spellId = _W, toX = WPos.x, toY = WPos.z, fromX = WPos.x, fromY = WPos.z}):send()
               else
               CastSpell(_W, WPos.x, WPos.z)
               end
               end
               end
         end
     end
  end
end

function HarassQ(unit)
    if Settings.harass.HarassQ and SkillQ.ready then
    if unit.team ~= myHero.team and unit.visible and unit.dead == false and _G.AutoCarry.Orbwalker:IsShooting() then
    CastSpell(_Q)
    end
  end
end

function HarassE(unit)
  local MyManaPercent = (myHero.mana/myHero.maxMana)*100
  if Settings.harass.HarassE and MyManaPercent >= Settings.harass.manah and SkillE.ready then
    if unit.team ~= myHero.team and unit.visible and unit.dead == false and myHero:GetDistance(unit) <= TristanaRange then
    if _G.AutoCarry.Orbwalker:CanMove() and not _G.AutoCarry.Orbwalker:IsShooting() and Settings.harass.BlackListB[unit.charName] then
    CastSpell(_E, unit)
     end
   end
  end
end

function CastR(unit)
  if SkillE.ready then
    if unit.team ~= myHero.team and unit.visible and unit.dead == false and myHero:GetDistance(unit) <= TristanaRange then
    if _G.AutoCarry.Orbwalker:CanMove() and not _G.AutoCarry.Orbwalker:IsShooting() then
    CastSpell(_R, unit)
     end
   end
  end
end
  
-- combo
function Combo(unit)
   CastQ(unit)
   CastE(unit)
   CastW(unit)
end

-- harass
function Harass(unit)
   HarassQ(unit)
   HarassE(unit)
end
-- KS
function KS(unit)
  KSR(unit)
  KSW(unit)
  KSE(unit)
  KSWR(unit)
end

-- Orbwalk / activator
function Checkorbwalk()
  if _G.Reborn_Loaded then  
     RebornLoaded = true
     print("<font color=\"#0f76ff\"> SAC LOADED </font><font color=\"#0f76ff\">")
     Settings:addSubMenu("["..myHero.charName.."] - SAC DETECTED", "")
     elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
      require 'SxOrbWalk'
      SxOrbMenu = Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")    
      SxOrb:LoadToMenu(Settings.Orbwalking)
      SxOrbLoaded = true       
    else
       print("<font color=\"#0f76ff\"> Please download SxOrbwalk or SAC </font><font color=\"#0f76ff\">")
    end  
  if  not _G.Activator then
      print("<font color=\"#c20e00\"> Please download activator for ITEM, Ignite ... support </font><font color=\"#c20e00\">")
   end
end

-- KS

function KSR(unit)
    local rDmg = getDmg("R", unit, myHero) + (myHero.ap)
    if _G.AutoCarry.Orbwalker:CanMove() and not _G.AutoCarry.Orbwalker:IsShooting() then rDmg = rDmg + (myHero.damage) end
    for _, unit in pairs(GetEnemyHeroes()) do
    if GetDistance(unit) <= TristanaRange and Settings.BlackList[unit.charName] then
      if not unit.dead and Settings.Misc.KSR and SkillR.ready then
            if unit.health <= rDmg then
            CastSpell(_R, unit)
          end   
        end     
      end
   end
end

function KSE(unit)
    local eDmg = getDmg("E", unit, myHero) + (myHero.ap)
    for _, unit in pairs(GetEnemyHeroes()) do
    if GetDistance(unit) <= TristanaRange and Settings.BlackList[unit.charName] then
      if not unit.dead and Settings.Misc.KSE and SkillE.ready then
            if unit.health <= eDmg then
            CastSpell(_E, unit)
          end   
        end     
      end
   end
end

function KSW(unit)
    local wDmg = getDmg("W", unit, myHero) + (myHero.ap/2) + (myHero.totalDamage)
    for _, unit in pairs(GetEnemyHeroes()) do
    if GetDistance(unit) <= 900 and SkillW.ready then
      if not unit.dead and Settings.Misc.KSW and Settings.BlackList[unit.charName] and not EnemyUnderTheirTower then
            if unit.health <= wDmg then
            if Settings.Misc.Prediction == 1 then
              CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero, false) 
              if HitChance >= 1 then
              Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
              end
              else
              if Settings.Misc.Prediction == 2 then
              local RPos, RHitChance = HPred:GetPredict("W", unit, myHero)
               if WHitChance >= Settings.Misc.W then
               if VIP_USER then
               Packet("S_CAST", {spellId = _W, toX = WPos.x, toY = WPos.z, fromX = WPos.x, fromY = WPos.z}):send()
               else
               CastSpell(_W, WPos.x, WPos.z)
               end               
               end
               end
            end
          end   
        end     
      end
   end
end

function KSWR(unit)
    local wDmg = getDmg("W", unit, myHero) + (myHero.ap/2) + (myHero.totalDamage)
    local rDmg = getDmg("R", unit, myHero) + (myHero.ap)
    local wrDmg = wDmg + rDmg
    for _, unit in pairs(GetEnemyHeroes()) do
    if GetDistance(unit) <= 900 and SkillW.ready and SkillR.ready and not EnemyUnderTheirTower then
      if not unit.dead and Settings.Misc.KSW and Settings.Misc.KSR and Settings.BlackList[unit.charName] then
            if unit.health <= wrDmg then
            if Settings.Misc.Prediction == 1 then
              CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero, false) 
              if HitChance >= 1 then
              Packet("S_CAST", {spellId = _W, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
              end
              else
              if Settings.Misc.Prediction == 2 then
              local RPos, RHitChance = HPred:GetPredict("W", unit, myHero)
               if WHitChance >= Settings.Misc.W then
               if VIP_USER then
               Packet("S_CAST", {spellId = _W, toX = WPos.x, toY = WPos.z, fromX = WPos.x, fromY = WPos.z}):send()
               else
               CastSpell(_W, WPos.x, WPos.z)
               CastSpell(_R, unit)
               end
               end
               end
            end
          end   
        end     
      end
   end
end


-- calcul range
function range()
AArange = myHero.range + (9*myHero.level) + 1
return AArange
end

-- ennemy is under tower ?
function EnemyUnderTheirTower(range)

  for i, enemy in ipairs(EnemyHeroes) do
  
    if ValidTarget(enemy, range) then
    
      for j, tower in pairs(Towers) do
      
        if tower.object and tower.object.team == enemy.team and GetDistance(tower.object) <= 920 and GetDistance(enemy, tower.object) <= 920 then
          return true
        end
        
      end
      
    end
    
  end  
  return false
end

-- script status
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("VILKHLKIMNP")
