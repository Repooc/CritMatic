-- Define a table to hold the highest hits data.
CritMaticData = CritMaticData or {}

local MAX_HIT = 10000

local function GetGCD()
  local _, gcdDuration = GetSpellCooldown(78) -- 78 is the spell ID for Warrior's Heroic Strike
  if gcdDuration == 0 then
    return 1.5 -- Default GCD duration if not available (you may adjust this value if needed)
  else
    return gcdDuration
  end
end

local function removeImproved(spellName)
  -- Stripping out "Improved " prefix
  local baseSpellName = spellName
  if spellName and string.sub(spellName, 1, 8) == "Improved" then
    baseSpellName = string.sub(spellName, 10)
  end
  return baseSpellName
end

local function IsSpellInSpellbook(spellName)
  local name = GetSpellInfo(spellName)
  return name ~= nil
end

local function AddHighestHitsToTooltip(self, slot)
  if (not slot) then
    return
  end

  local actionType, id = GetActionInfo(slot)
  if actionType == "spell" then
    local spellName, _, _, castTime = GetSpellInfo(id)

    local baseSpellName = removeImproved(spellName)

    if CritMaticData[baseSpellName] then

      local cooldown = (GetSpellBaseCooldown(id) or 0) / 1000
      --TODO: if the action is less than the GCD, use the GCD instead
      local effectiveCastTime = castTime > 0 and (castTime / 1000) or GetGCD()
      local effectiveTime = max(effectiveCastTime, cooldown)

      local critHPS = CritMaticData[baseSpellName].highestHealCrit / effectiveTime
      local normalHPS = CritMaticData[baseSpellName].highestHeal / effectiveTime
      local critDPS = CritMaticData[baseSpellName].highestCrit / effectiveTime
      local normalDPS = CritMaticData[baseSpellName].highestNormal / effectiveTime

      local CritMaticHealLeft = "Highest Heal Crit: "
      local CritMaticHealRight = tostring(CritMaticData[baseSpellName].highestHealCrit) .. " (" .. format("%.1f", critHPS) .. " HPS)"
      local normalMaticHealLeft = "Highest Heal Normal: "
      local normalMaticHealRight = tostring(CritMaticData[baseSpellName].highestHeal) .. " (" .. format("%.1f", normalHPS) .. " HPS)"

      local CritMaticLeft = "Highest Crit: "
      local CritMaticRight = tostring(CritMaticData[baseSpellName].highestCrit) .. " (" .. format("%.1f", critDPS) .. " DPS)"
      local normalMaticLeft = "Highest Normal: "
      local normalMaticRight = tostring(CritMaticData[baseSpellName].highestNormal) .. " (" .. format("%.1f", normalDPS) .. " DPS)"

      -- Check if lines are already present in the tooltip.
      local critMaticHealExists = false
      local normalMaticHealExists = false
      local critMaticExists = false
      local normalMaticExists = false

      for i = 1, self:NumLines() do
        local gtl = _G["GameTooltipTextLeft" .. i]
        local gtr = _G["GameTooltipTextRight" .. i]

        if gtl and gtr then
          -- Healing related
          if gtl:GetText() == CritMaticHealLeft and gtr:GetText() == CritMaticHealRight then
            critMaticHealExists = true
          elseif gtl:GetText() == normalMaticHealLeft and gtr:GetText() == normalMaticHealRight then
            normalMaticHealExists = true
          end
          -- Damage related
          if gtl:GetText() == CritMaticLeft and gtr:GetText() == CritMaticRight then
            critMaticExists = true
          elseif gtl:GetText() == normalMaticLeft and gtr:GetText() == normalMaticRight then
            normalMaticExists = true
          end
        end
      end

      if CritMaticData[baseSpellName].highestHeal > 0 or CritMaticData[baseSpellName].highestHealCrit > 0 then

        if not critMaticHealExists then
          self:AddDoubleLine(CritMaticHealLeft, CritMaticHealRight)
          _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
          _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (gold)
        end

        if not normalMaticHealExists then
          self:AddDoubleLine(normalMaticHealLeft, normalMaticHealRight)
          _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
          _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (gold)
        end
      end
      -- This is a damaging spell
      if CritMaticData[baseSpellName].highestNormal > 0 or CritMaticData[baseSpellName].highestCrit > 0 then
        if not critMaticExists then
          self:AddDoubleLine(CritMaticLeft, CritMaticRight)
          _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
          _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (gold)
        end
        if not normalMaticExists then
          self:AddDoubleLine(normalMaticLeft, normalMaticRight)
          _G["GameTooltipTextLeft" .. self:NumLines()]:SetTextColor(1, 1, 1) -- left side color (white)
          _G["GameTooltipTextRight" .. self:NumLines()]:SetTextColor(1, 0.82, 0) -- right side color (gold)
        end
      end

      self:Show()
    end
  end
end

-- Register an event that fires when the player hits an enemy.
local f = CreateFrame("FRAME")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnEvent", function(self, event, ...)

  if event == "COMBAT_LOG_EVENT_UNFILTERED" then
    local eventInfo = { CombatLogGetCurrentEventInfo() }

    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = unpack(eventInfo, 1, 11)
    local spellID, spellName, spellSchool, amount, overhealing, absorbed, critical
    if eventType == "SWING_DAMAGE" then
      spellName = "Auto Attack"
      spellID = 6603 -- or specify the path to a melee icon, if you have one
      amount, _, _, _, _, _, critical = unpack(eventInfo, 12, 18)
    elseif eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
      spellID, spellName, spellSchool = unpack(eventInfo, 12, 14)
      amount, overhealing, absorbed, critical = unpack(eventInfo, 15, 18)
    elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
      spellID, spellName, spellSchool = unpack(eventInfo, 12, 14)
      amount, overhealing, _, _, _, absorbed, critical = unpack(eventInfo, 15, 21)
    end

    local baseSpellName = removeImproved(spellName)

    if sourceGUID == UnitGUID("player") and destGUID ~= UnitGUID("player") and (eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" or eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" or eventType == "SPELL_PERIODIC_DAMAGE") and amount > 0 then
      if baseSpellName then
        CritMaticData[baseSpellName] = CritMaticData[baseSpellName] or {
          highestCrit = 0,
          highestNormal = 0,
          highestHeal = 0,
          highestHealCrit = 0,
          spellIcon = GetSpellTexture(spellID)
        }
        if IsSpellInSpellbook(baseSpellName) then
          --print(CombatLogGetCurrentEventInfo())

          if eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
            if critical then
              if baseSpellName == "Auto Attack" then
                return
              end
              -- When the event is a heal and it's a critical heal.
              if amount > CritMaticData[baseSpellName].highestHealCrit and amount <= MAX_HIT then
                CritMaticData[baseSpellName].highestHealCrit = amount
                PlaySound(888, "SFX")
                CritMatic.ShowNewHealCritMessage(baseSpellName, amount)
                print("New highest crit heal for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestHealCrit)
              end
            elseif not critical then
              if baseSpellName == "Auto Attack" then
                return
              end
              if amount > CritMaticData[baseSpellName].highestHeal and amount <= MAX_HIT then
                CritMaticData[baseSpellName].highestHeal = amount
                PlaySound(10049, "SFX")
                CritMatic.ShowNewHealMessage(baseSpellName, amount)
                print("New highest normal heal for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestHeal)
              end
            end
          elseif eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
            if critical then
              -- When the event is damage and it's a critical hit.
              if baseSpellName == "Auto Attack" then
                return
              end
              if amount > CritMaticData[baseSpellName].highestCrit and amount <= MAX_HIT then
                CritMaticData[baseSpellName].highestCrit = amount
                PlaySound(888, "SFX")
                CritMatic.ShowNewCritMessage(baseSpellName, amount)
                print("New highest crit hit for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestCrit)
              end
            elseif not critical then
              -- When the event is damage but it's not a critical hit.
              if baseSpellName == "Auto Attack" then
                return
              end
              if amount > CritMaticData[baseSpellName].highestNormal and amount <= MAX_HIT then
                CritMaticData[baseSpellName].highestNormal = amount
                PlaySound(10049, "SFX")
                CritMatic.ShowNewNormalMessage(baseSpellName, amount)
                print("New highest normal hit for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestNormal)
              end
            end
          end
        end
      end
    end
  end
end)

-- Register an event that fires when the addon is loaded.
local function OnLoad(self, event, addonName)
  if addonName == "CritMatic" then
    print("CritMatic Loaded!")

    CritMaticData = _G["CritMaticData"]

    -- Add the highest hits data to the spell button tooltip.
    hooksecurefunc(GameTooltip, "SetAction", AddHighestHitsToTooltip)
  end
end
local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnLoad)

-- Register an event that fires when the player logs out or exits the game.
local function OnSave(self, event)
  -- Save the highest hits data to the saved variables for the addon.
  _G["CritMaticData"] = CritMaticData
end
local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", OnSave)

local function ResetData()
  CritMaticData = {}
  print("CritMatic data reset.")
end

SLASH_CRITMATICRESET1 = '/cmreset'
function SlashCmdList.CRITMATICRESET(msg, editBox)
  ResetData()
end
