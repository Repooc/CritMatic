-- Define a table to hold the highest hits data.
CritMaticData = CritMaticData or {}
local function GetGCD()
  local _, gcdDuration = GetSpellCooldown(78) -- 78 is the spell ID for Warrior's Heroic Strike
  if gcdDuration == 0 then
    return 1.5 -- Default GCD duration if not available (you may adjust this value if needed)
  else
    return gcdDuration
  end
end

local KILLING_SPREE_DURATION = 2.0  -- duration in seconds

local addedKillingSpreeInfo = false

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
  -- Check if the current frame under the mouse is the GameTooltip
  local currentFrame = GetMouseFocus()
  if currentFrame == GameTooltip then
    return
  end
  local name, spellID = self:GetSpell()
  if spellID == 51690 and not addedKillingSpreeInfo then
    C_Timer.After(0.01, function()
      local critDPS = CritMaticData["Killing Spree"].highestCrit / KILLING_SPREE_DURATION
      local normalDPS = CritMaticData["Killing Spree"].highestNormal / KILLING_SPREE_DURATION

      local critMaticLeft = "Highest Crit: "
      local critMaticRight = tostring(CritMaticData["Killing Spree"].highestCrit) .. " (" .. format("%.1f", critDPS) .. " DPS)"

      local normalMaticLeft = "Highest Normal: "
      local normalMaticRight = tostring(CritMaticData["Killing Spree"].highestNormal) .. " (" .. format("%.1f", normalDPS) .. " DPS)"

      self:AddDoubleLine(critMaticLeft, critMaticRight, 1, 1, 1, 1, 0.82, 0)  -- Left text in white, Right text in gold
      self:AddDoubleLine(normalMaticLeft, normalMaticRight, 1, 1, 1, 1, 0.82, 0)  -- Left text in white, Right text in gold
      self:Show()  -- Redraw the tooltip to reflect our changes

      addedKillingSpreeInfo = true
    end)
  end
end)

-- Reset the flag when the tooltip is hidden, so the next time it's shown, we can add our info again
GameTooltip:HookScript("OnHide", function(self)
  addedKillingSpreeInfo = false
end)

local function AddHighestHitsToTooltip(self, slot)
  if (not slot) then
    return
  end

  local actionType, id = GetActionInfo(slot)
  if actionType == "spell" then
    local spellName, _, _, castTime = GetSpellInfo(id)

    if CritMaticData[spellName] then

      local cooldown = (GetSpellBaseCooldown(id) or 0) / 1000
      local effectiveCastTime = castTime > 0 and (castTime / 1000) or GetGCD()
      local effectiveTime = max(effectiveCastTime, cooldown)

      local critHPS = CritMaticData[spellName].highestHealCrit / effectiveTime
      local normalHPS = CritMaticData[spellName].highestHeal / effectiveTime
      local critDPS = CritMaticData[spellName].highestCrit / effectiveTime
      local normalDPS = CritMaticData[spellName].highestNormal / effectiveTime

      -- tooltip for healing spells and damage
      local CritMaticHealLeft = "Highest Heal Crit: "
      local CritMaticHealRight = tostring(CritMaticData[spellName].highestHealCrit) .. " (" .. format("%.1f", critHPS) .. " HPS)"
      local normalMaticHealLeft = "Highest Heal Normal: "
      local normalMaticHealRight = tostring(CritMaticData[spellName].highestHeal) .. " (" .. format("%.1f", normalHPS) .. " HPS)"
      local CritMaticLeft = "Highest Crit: "
      local CritMaticRight = tostring(CritMaticData[spellName].highestCrit) .. " (" .. format("%.1f", critDPS) .. " DPS)"
      local normalMaticLeft = "Highest Normal: "
      local normalMaticRight = tostring(CritMaticData[spellName].highestNormal) .. " (" .. format("%.1f", normalDPS) .. " DPS)"

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
      -- If lines don't exist, add them.
      -- This is a healing spell
      if CritMaticData[spellName].highestHeal > 0 or CritMaticData[spellName].highestHealCrit > 0 then

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

      if CritMaticData[spellName].highestNormal > 0 or CritMaticData[spellName].highestCrit > 0 then
        -- This is a damaging spell
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
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

local isKillingSpreeActive = false
local killingSpreeProcessing = false
local killingSpreeDamage = 0
local killingSpreeCritDamage = 0
local killingSpreeCount = 0  -- Get information about the combat event.
local killingSpreeCritCount = 0

f:SetScript("OnEvent", function(self, event, ...)
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    local unitTarget, castGUID, spellID = ...
    local spellName = GetSpellInfo(spellID)
    if unitTarget == "player" and spellName == "Killing Spree" then
      isKillingSpreeActive = true
      killingSpreeDamage = 0
      killingSpreeCritDamage = 0
      killingSpreeCount = 0
      killingSpreeCritCount = 0
    end
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
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

    -- Stripping out "Improved " prefix
    local baseSpellName = spellName
    if spellName and string.sub(spellName, 1, 8) == "Improved" then
      baseSpellName = string.sub(spellName, 10)
    end

    if sourceGUID == UnitGUID("player") and destGUID ~= UnitGUID("player") and (eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" or eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" or eventType == "SPELL_PERIODIC_DAMAGE") and amount > 0 then
      if spellName then
        CritMaticData[baseSpellName] = CritMaticData[baseSpellName] or {
          highestCrit = 0,
          highestNormal = 0,
          highestHeal = 0,
          highestHealCrit = 0,
          spellIcon = GetSpellTexture(spellID)
        }
        --print(CombatLogGetCurrentEventInfo())

        if isKillingSpreeActive and baseSpellName == "Killing Spree" then
          if critical then
            killingSpreeCritDamage = killingSpreeCritDamage + amount
            killingSpreeCritCount = killingSpreeCritCount + 1
          else
            killingSpreeDamage = killingSpreeDamage + amount
          end
          killingSpreeCount = killingSpreeCount + 1

          if killingSpreeCount >= 5 and not killingSpreeProcessing then
            isKillingSpreeActive = false
            killingSpreeProcessing = true  -- Set the flag to true to prevent re-scheduling
            -- Delay of 1.7 seconds to ensure all attacks are processed
            C_Timer.After(1.7, function()
              if killingSpreeCritCount > 0 then
                if killingSpreeCritDamage + killingSpreeDamage > CritMaticData[baseSpellName].highestCrit then
                  CritMaticData["Killing Spree"].highestCrit = killingSpreeCritDamage + killingSpreeDamage
                  PlaySound(888, "SFX")
                  CritMatic.ShowNewCritMessage(baseSpellName, killingSpreeCritDamage + killingSpreeDamage)
                  print("New highest crit hit for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestCrit)
                end
              else
                if killingSpreeDamage > CritMaticData[baseSpellName].highestNormal then
                  CritMaticData["Killing Spree"].highestNormal = killingSpreeDamage
                  PlaySound(10049, "SFX")
                  CritMatic.ShowNewNormalMessage(baseSpellName, killingSpreeDamage)
                  print("New highest normal hit for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestNormal)
                end
              end
              -- Reset counters and flags
              killingSpreeProcessing = false
              killingSpreeCount = 0
              killingSpreeDamage = 0
              killingSpreeCritDamage = 0
              killingSpreeCritCount = 0
            end)
          end

        elseif eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" then
          if critical then
            if baseSpellName == "Auto Attack" then
              return
            end
            -- When the event is a heal and it's a critical heal.
            if amount > CritMaticData[baseSpellName].highestHealCrit then
              CritMaticData[baseSpellName].highestHealCrit = amount
              PlaySound(888, "SFX")
              CritMatic.ShowNewHealCritMessage(baseSpellName, amount)
              print("New highest crit heal for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestHealCrit)
            end
          elseif not critical then
            if baseSpellName == "Auto Attack" then
              return
            end
            if amount > CritMaticData[baseSpellName].highestHeal then
              CritMaticData[baseSpellName].highestHeal = amount
              PlaySound(10049, "SFX")
              CritMatic.ShowNewHealMessage(baseSpellName, amount)
              print("New highest normal heal for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestHeal)
            end
          end
        elseif eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
          if critical then
            -- When the event is damage and it's a critical hit.
            if baseSpellName == "Auto Attack" or baseSpellName == "Killing Spree" then
              return
            end
            if amount > CritMaticData[baseSpellName].highestCrit then
              CritMaticData[baseSpellName].highestCrit = amount
              PlaySound(888, "SFX")
              CritMatic.ShowNewCritMessage(baseSpellName, amount)
              print("New highest crit hit for " .. baseSpellName .. ": " .. CritMaticData[baseSpellName].highestCrit)
            end
          elseif not critical then
            -- When the event is damage but it's not a critical hit.
            if baseSpellName == "Auto Attack" or baseSpellName == "Killing Spree" then
              return
            end
            if amount > CritMaticData[baseSpellName].highestNormal then
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
