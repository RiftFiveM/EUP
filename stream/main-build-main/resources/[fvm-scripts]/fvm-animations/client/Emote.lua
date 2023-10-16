
-- You probably shouldnt touch these.
local AnimationDuration = -1
local ChosenAnimation = ""
local ChosenDict = ""
IsInAnimation = false
local MostRecentChosenAnimation = ""
local MostRecentChosenDict = ""
local MovementType = 0
local PlayerGender = "male"
local PlayerHasProp = false
local PlayerProps = {}
local SecondPropEmote = false
CanDoEmote = true
SmokingWeed = false
RelieveCount = 0

RegisterNetEvent('animations:ToggleCanDoAnims')
AddEventHandler('animations:ToggleCanDoAnims', function(bool)
  CanDoEmote = bool
end)

Citizen.CreateThread(function()
  while Config.MenuKeybindEnabled do
    if IsControlPressed(0, Config.MenuKeybind) then
      OpenEmoteMenu()
    end
    Citizen.Wait(1)
  end
  Citizen.Wait(1)
end)

RegisterCommand('cancelemote', function()
  EmoteCancel()
end)
RegisterKeyMapping('cancelemote', 'Cancel Emote/Animation', 'keyboard', 'x')


-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

RegisterNetEvent('animations:client:SmokeWeed')
AddEventHandler('animations:client:SmokeWeed', function()
  SmokingWeed = true
  Citizen.CreateThread(function()
    while SmokingWeed do
      Citizen.Wait(10000)
      TriggerServerEvent('fvm-hud:Server:RelieveStress', math.random(15, 18))
      RelieveCount = RelieveCount + 1
      if RelieveCount == 6 then
        if ChosenDict == "MaleScenario" and IsInAnimation then
          ClearPedTasksImmediately(PlayerPedId())
          IsInAnimation = false
          DebugPrint("Forced scenario exit")
        elseif ChosenDict == "Scenario" and IsInAnimation then
          ClearPedTasksImmediately(PlayerPedId())
          IsInAnimation = false
          DebugPrint("Forced scenario exit")
        end
      
        if IsInAnimation then
          ClearPedTasks(PlayerPedId())
          DestroyAllProps()
          IsInAnimation = false
        end
      
        if SmokingWeed then
          SmokingWeed = false
          RelieveCount = 0
        end
      end
    end
  end)
end)

RegisterNetEvent('animations:client:EmoteCommandStart')
AddEventHandler('animations:client:EmoteCommandStart', function(args)
  local ped = PlayerPedId()

  if Config.BlockAnimationInsideVehicle then
    if IsPedInAnyVehicle(ped) then
      return
    end 
  end

  if CanDoEmote then
    EmoteCommandStart(args)
  else
    FvMain.Functions.Notify("You can\'t do any emotes right now", "error")
  end
end)

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    DestroyAllProps()
    ClearPedTasksImmediately(PlayerPedId())
    ResetPedMovementClipset(PlayerPedId())
  end
end)

function EmoteCancel()
  if ChosenDict == "MaleScenario" and IsInAnimation then
    ClearPedTasksImmediately(PlayerPedId())
    IsInAnimation = false
    DebugPrint("Forced scenario exit")
  elseif ChosenDict == "Scenario" and IsInAnimation then
    ClearPedTasksImmediately(PlayerPedId())
    IsInAnimation = false
    DebugPrint("Forced scenario exit")
  end

  if IsInAnimation then
    ClearPedTasks(PlayerPedId())
    DestroyAllProps()
    IsInAnimation = false
  end

  if SmokingWeed then
    SmokingWeed = false
    RelieveCount = 0
  end
end

function EmoteChatMessage(args)
  if args == display then
    TriggerEvent("chatMessage", "Help", false, string.format(""))
  else
    TriggerEvent("chatMessage", "Help", false, string.format(""..args..""))
  end
end

function DebugPrint(args)
  if Config.DebugDisplay then
    print(args)
  end
end


function EmotesOnCommand(source, args, raw)
  local EmotesCommand = ""
  for a in pairsByKeys(AnimationList.Emotes) do
    EmotesCommand = EmotesCommand .. ""..a..", "
  end
  --EmoteChatMessage(EmotesCommand)
 -- EmoteChatMessage("Do /emotemenu for a menu")
end

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function EmoteMenuStart(args, hard)
    local name = args
    local etype = hard

    if etype == "dances" then
        if AnimationList.Dances[name] ~= nil then
          if OnEmotePlay(AnimationList.Dances[name]) then end
        else
          --EmoteChatMessage("'"..name.."' is not a valid dance")
        end
    elseif etype == "props" then
        if AnimationList.PropEmotes[name] ~= nil then
          if OnEmotePlay(AnimationList.PropEmotes[name]) then end
        else
          --EmoteChatMessage("'"..name.."' is not a valid emote")
        end
    elseif etype == "emotes" then
        if AnimationList.Emotes[name] ~= nil then
          if OnEmotePlay(AnimationList.Emotes[name]) then end
        else
          if name ~= "🕺 Dance Emotes" then
              --EmoteChatMessage("'"..name.."' is not a valid emote")
          end
        end
    elseif etype == "expression" then
        if AnimationList.Expressions[name] ~= nil then
          if OnEmotePlay(AnimationList.Expressions[name]) then end
        end
    end
end

function EmoteCommandStart(args)
    if #args > 0 then
      local name = string.lower(args[1])
      if name == "c" then
          if IsInAnimation then
              EmoteCancel()
          else
              --EmoteChatMessage("Geen emote om te stoppen :)")
          end
        return
      elseif name == "help" then
        EmotesOnCommand()
      return end

      if AnimationList.Emotes[name] ~= nil then
        if OnEmotePlay(AnimationList.Emotes[name]) then end return
      elseif AnimationList.Dances[name] ~= nil then
        if OnEmotePlay(AnimationList.Dances[name]) then end return
      elseif AnimationList.PropEmotes[name] ~= nil then
        if OnEmotePlay(AnimationList.PropEmotes[name]) then end return
      else
        --EmoteChatMessage("'"..name.."' is geen bestaande emote")
      end
    end
end

LoadAnim = function(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Citizen.Wait(1)
  end
end

LoadPropDict = function(model)
  RequestModel(GetHashKey(model))
  while not HasModelLoaded(GetHashKey(model)) do
    Citizen.Wait(1)
  end
end

DestroyAllProps = function()
  for _,v in pairs(PlayerProps) do
    DeleteEntity(v)
  end
  PlayerHasProp = false
  DebugPrint("Destroyed Props")
end

AddPropToPlayer = function(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
  local Player = PlayerPedId()
  local x,y,z = table.unpack(GetEntityCoords(Player))

  if not HasModelLoaded(prop1) then
    LoadPropDict(prop1)
  end

  prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
  AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
  table.insert(PlayerProps, prop)
  PlayerHasProp = true
end

CheckGender = function()
  local hashSkinMale = GetHashKey("mp_m_freemode_01")
  local hashSkinFemale = GetHashKey("mp_f_freemode_01")

  if GetEntityModel(PlayerPedId()) == hashSkinMale then
    PlayerGender = "Man"
  elseif GetEntityModel(PlayerPedId()) == hashSkinFemale then
    PlayerGender = "Woman"
  end
  DebugPrint("Set gender as = ("..PlayerGender..")")
end

function OnEmotePlay(EmoteName)
  if not DoesEntityExist(PlayerPedId()) then
    return false
  end

  if Config.DisarmPlayer then
    if IsPedArmed(PlayerPedId(), 7) then
      local weapon = GetSelectedPedWeapon(PlayerPedId())
      TriggerEvent('inventory:client:CheckWeapon', FvMain.Shared.Weapons[weapon]["name"])
    end
  end

  ChosenDict,ChosenAnimation,ename = table.unpack(EmoteName)
  AnimationDuration = -1

  if PlayerHasProp then
    DestroyAllProps()
  end

  if ChosenDict == "Expression" then
    SetFacialIdleAnimOverride(PlayerPedId(), ChosenAnimation, 0)
    return
  end

  if ChosenDict == "MaleScenario" or "Scenario" then
    CheckGender()
    if ChosenDict == "MaleScenario" then
      if PlayerGender == "man" then
        ClearPedTasks(PlayerPedId())
        TaskStartScenarioInPlace(PlayerPedId(), ChosenAnimation, 0, true)
        DebugPrint("Playing scenario = ("..ChosenAnimation..")")
        IsInAnimation = true
      else
      end return
    elseif ChosenDict == "ScenarioObject" then
      BehindPlayer = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0 - 0.5, -0.5);
      ClearPedTasks(PlayerPedId())
      TaskStartScenarioAtPosition(PlayerPedId(), ChosenAnimation, BehindPlayer['x'], BehindPlayer['y'], BehindPlayer['z'], GetEntityHeading(PlayerPedId()), 0, 1, false)
      DebugPrint("Playing scenario = ("..ChosenAnimation..")")
      IsInAnimation = true
      return
    elseif ChosenDict == "Scenario" then
      ClearPedTasks(PlayerPedId())
      TaskStartScenarioInPlace(PlayerPedId(), ChosenAnimation, 0, true)
      DebugPrint("Playing scenario = ("..ChosenAnimation..")")
      IsInAnimation = true
    return end 
  end

    LoadAnim(ChosenDict)

    if EmoteName.AnimationOptions then
      if EmoteName.AnimationOptions.EmoteLoop then
        MovementType = 1
      if EmoteName.AnimationOptions.EmoteMoving then
        MovementType = 51
      end
  elseif EmoteName.AnimationOptions.EmoteMoving then
    MovementType = 51
  end
  else
    MovementType = 0
  end

  if EmoteName.AnimationOptions then
    if EmoteName.AnimationOptions.EmoteDuration == nil then 
      EmoteName.AnimationOptions.EmoteDuration = -1
    else
      AnimationDuration = EmoteName.AnimationOptions.EmoteDuration
    end

    if EmoteName.AnimationOptions.Prop then
      PropName = EmoteName.AnimationOptions.Prop
      PropBone = EmoteName.AnimationOptions.PropBone
      PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(EmoteName.AnimationOptions.PropPlacement)
      if EmoteName.AnimationOptions.SecondProp then
        SecondPropName = EmoteName.AnimationOptions.SecondProp
        SecondPropBone = EmoteName.AnimationOptions.SecondPropBone
        SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(EmoteName.AnimationOptions.SecondPropPlacement)
        SecondPropEmote = true
      else
        SecondPropEmote = false
      end

      AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
      if SecondPropEmote then
        AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6)
      end
    end
  else
      DebugPrint("AnimationOptions = False")
  end
  
  DebugPrint ("--- Main Animations")
  DebugPrint ("ChosenDict = " ..ChosenDict.. "")
  DebugPrint ("ChosenAnimation = " ..ChosenAnimation.. "")
  DebugPrint ("MovementType = " ..MovementType.. "")
  DebugPrint ("AnimationDuration = " ..AnimationDuration.. "")

  if EmoteName.AnimationOptions then
    DebugPrint ("--- AnimationOptions")
    DebugPrint ("AnimationOption.EmoteLoop = " ..tostring(EmoteName.AnimationOptions.EmoteLoop).. "")
    DebugPrint ("AnimationOption.EmoteMoving = " ..tostring(EmoteName.AnimationOptions.EmoteMoving).. "")
    DebugPrint ("AnimationOption.EmoteDuration = " ..tostring(EmoteName.AnimationOptions.EmoteDuration).. "")
  end

  TaskPlayAnim(PlayerPedId(), ChosenDict, ChosenAnimation, 2.0, 2.0, AnimationDuration, MovementType, 0, false, false, false)
  IsInAnimation = true
  MostRecentDict = ChosenDict
  MostRecentAnimation = ChosenAnimation
  return true
end