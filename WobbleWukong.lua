--[[
__          __   _     _     _       __          __    _                     
\ \        / /  | |   | |   | |      \ \        / /   | |                    
 \ \  /\  / /__ | |__ | |__ | | ___   \ \  /\  / /   _| | _____  _ __   __ _ 
  \ \/  \/ / _ \| '_ \| '_ \| |/ _ \   \ \/  \/ / | | | |/ / _ \| '_ \ / _` |
   \  /\  / (_) | |_) | |_) | |  __/    \  /\  /| |_| |   < (_) | | | | (_| |
    \/  \/ \___/|_.__/|_.__/|_|\___|     \/  \/  \__,_|_|\_\___/|_| |_|\__, |
                                                                        __/ |
                                                                       |___/              

by DeadDevil2 :)

Chanelog:
v1.0 inital release
v1.1 Fixed some target bugs 
]]

if myHero.charName ~= "MonkeyKing" then
return
end

require 'SOW'
require 'Vprediction'

local selectedTar = nil
local VP = nil
local version = 1.1
local AUTOUPDATE = true
local SCRIPT_NAME = "WobbleWukong"
local selectedTar = nil
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"


if FileExist(SOURCELIB_PATH) then
    require("SourceLib")
else
    DONLOADING_SOURCELIB = true
    DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

local RequireI = Require("SourceLib")
RequireI:Check()


if AUTOUPDATE then
     SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/dd2repo/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/dd2repo/BoL/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end


--[[
  ____          _                     _ 
 / __ \        | |                   | |
| |  | |_ __   | |     ___   __ _  __| |
| |  | | '_ \  | |    / _ \ / _` |/ _` |
| |__| | | | | | |___| (_) | (_| | (_| |
 \____/|_| |_| |______\___/ \__,_|\__,_|
 ]]

function OnLoad()

ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,315)
m = scriptConfig("Wobble Wukong", "wobblewukong")
VP = VPrediction()
sow = SOW(VP)
sow:RegisterAfterAttackCallback(hydra)
--sow:RegisterOnAttackCallback(CastQ)

Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2) or nil


m:addSubMenu("Combo Settings", "combosettings")
m.combosettings:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
m.combosettings:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)


m:addSubMenu("KS Settings", "ks")
m.ks:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
m.ks:addParam("user", "Use Ultimate", SCRIPT_PARAM_ONOFF, true)
m.ks:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)

m:addSubMenu("Drawings", "draws")
m.draws:addParam("drawq", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("drawe", "Draw E range", SCRIPT_PARAM_ONOFF, false)
m.draws:addParam("drawr", "Draw R range", SCRIPT_PARAM_ONOFF, false)

m:addParam("combokey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
m:addParam("magnet", "Meele Magnet", SCRIPT_PARAM_ONOFF, true)

m:addSubMenu("Orbwalker", "orbwalk")
sow:LoadToMenu(m.orbwalk)
m:addTS(ts)
ts.name = "Wobble"
PrintChat ("<font color='#00BCFF'>Wobble Wukong v1.1 by DeadDevil2 Loaded! </font>")

end


function OnGainBuff(unit, buff)
    if buff.name == 'MonkeyKingSpinToWin' and unit.isMe then
    	usingult = true
    end
end

function OnLoseBuff(unit, buff)
    if buff.name == 'MonkeyKingSpinToWin' and unit.isMe then
        usingult = false
    end
end


--[[
  ____          _______ _      _    
 / __ \        |__   __(_)    | |   
| |  | |_ __      | |   _  ___| | __
| |  | | '_ \     | |  | |/ __| |/ /
| |__| | | | |    | |  | | (__|   < 
 \____/|_| |_|    |_|  |_|\___|_|\_\
]]       



function OnTick()
checks()
targetmagnet()
checks()
Killsteal()
CastQ()
CastE()
CST()
end



--[[
  _____                _           
 / ____|              | |          
| |     ___  _ __ ___ | |__   ___  
| |    / _ \| '_ ` _ \| '_ \ / _ \ 
| |___| (_) | | | | | | |_) | (_) |
 \_____\___/|_| |_| |_|_.__/ \___/ 
 ]] 

function checks()
	ts:update()
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
	target = ts.target

end

function hydra()
	if m.combokey and target and ValidTarget(target, 200) and GetDistance(target) <= 200 then CastItem(3074) CastItem(3077)
	end
end

function CastQ()
	if m.combokey and Qready and m.combosettings.useq and target and ValidTarget(target, 290) and GetDistance(target) <= 290 then
		CastSpell(_Q)
	end
end

function CastE()
	if m.combokey and Eready then
		ts.range = 620
  		ts:update()
  		if ValidTarget(ts.target, 620) then
   			CastSpell(_E, ts.target)
  		end
  		ts.range = 315
  		ts:update()
 	end
end

function Killsteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if Ignite ~= nil and m.ks.ignite and enemy.health < getDmg("IGNITE", enemy, myHero) and ValidTarget(enemy, 600) then CastSpell(Ignite, enemy)
		end
		if ValidTarget(enemy, 315) and m.ks.user and not usingult then
			local RDmg = getDmg('R', enemy, myHero) or 0
			if Rready and enemy.health <= RDmg*4 then
				CastSpell(_R)
			end
		end
		if m.ks.usee and ValidTarget(enemy, 610) then
			local EDmg = getDmg('E', enemy, myHero) or 0
			if Eready and enemy.health <= EDmg then
				CastSpell(_E, enemy)
			end
		end
	end	
end

function targetmagnet()
    if m.combokey and target and ValidTarget(target, 300) and m.magnet then
	local dist = GetDistanceSqr(target)
	if dist < 300^2 and dist > 50^2 then 
		stayclose(target, true)
	elseif dist <= 50^2 then
		stayclose(target, false)
	end
    end
end

function stayclose(unit, mode)
	if mode then
		local myVector = Vector(myHero.x, myHero.y, myHero.z)
		local targetVector = Vector(unit.x, unit.y, unit.z)
		local orbwalkPoint1 = targetVector + (myVector-targetVector):normalized()*100
		local orbwalkPoint2 = targetVector - (myVector-targetVector):normalized()*100
		if GetDistanceSqr(orbwalkPoint1) < GetDistanceSqr(orbwalkPoint2) then
			sow:OrbWalk(unit, orbwalkPoint1)
		else
			sow:OrbWalk(unit, orbwalkPoint2)
		end
	else
		sow:OrbWalk(unit, myHero)
	end
end


function CST()
	local Target = nil
	if selectedTar then Target = selectedTar
	else Target = ts.target
	end
end
--thanks to bilbao
function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN then
		local minD = 10
		local starget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				if GetDistance(enemy, mousePos) <= minD or starget == nil then
					minD = GetDistance(enemy, mousePos)
					starget = enemy
				end
			end
		end		
		if starget and minD < 500 then
			if selectedTar and starget.charName == selectedTar.charName then
				selectedTar = nil
				print("<font color=\"#FFFFFF\">Wukong: Target <b>UNSELECTED</b>: "..starget.charName.."</font>")
			else
				selectedTar = starget				
				print("<font color=\"#FFFFFF\">Wukong: New target <b>selected</b>: "..starget.charName.."</font>")
			end
		end
	end
end


function OnDraw()
if m.draws.drawq then
	DrawCircle(myHero.x, myHero.y, myHero.z, 300, ARGB(255, 255, 255, 255))
end
if m.draws.drawe then
	DrawCircle(myHero.x, myHero.y, myHero.z, 625, ARGB(255, 255, 255, 255))
end
if m.draws.drawr then
	DrawCircle(myHero.x, myHero.y, myHero.z, 315, ARGB(255, 255, 255, 255))
end
end

