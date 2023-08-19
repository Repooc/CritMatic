local fontPath = "Interface\\AddOns\\CritMatic\\fonts\\8bit.ttf"
local MESSAGE_SPACING = 30  -- Spacing between messages
local activeMessages = {}

-- Utility function to adjust message positions
local function AdjustMessagePositions()
  for i, frame in ipairs(activeMessages) do
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 250 - (i - 1) * MESSAGE_SPACING)
  end
end

-- Utility function to remove the oldest message and adjust the rest
local function RemoveOldestMessage()
  local oldestMessage = table.remove(activeMessages, 1)  -- Remove the oldest message (first in the table)
  AdjustMessagePositions()
end

CritMatic.MessageFrame = {}

function CritMatic.MessageFrame:CreateMessage(text, r, g, b)
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetSize(750, 30)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 320)
  f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
  f.text:SetAllPoints()
  f.text:SetText(text)
  f.text:SetTextColor(r, g, b)
  f.text:SetFont(fontPath, 20, "THICKOUTLINE")
  f.text:SetShadowOffset(3, -3)

  -- Fade out and hide animation
  f.fadeOut = f:CreateAnimationGroup()
  local fade = f.fadeOut:CreateAnimation("Alpha")
  fade:SetFromAlpha(1)
  fade:SetToAlpha(0)
  fade:SetDuration(0.5)
  fade:SetStartDelay(7.5)
  f.fadeOut:SetScript("OnFinished", function()
    f:Hide()
  end)
  f.fadeOut:Play()

  table.insert(activeMessages, f)  -- Add the new message to the end of the list
  AdjustMessagePositions()

  C_Timer.After(8, function()
    RemoveOldestMessage()
  end)

  return f
end

function CritMatic.ShowNewHealCritMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end
  if not CritMaticMessageFrame then
    CritMaticMessageFrame = CritMatic.CreateMessageFrame()
  end

  local message = string.upper(string.format("New %s crit heal: %d!", spellName, amount))
  CritMatic.MessageFrame:CreateMessage(message, 1, 0.84, 0)  -- Gold color

end

function CritMatic.ShowNewHealMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end

  local message = string.upper(string.format("New %s normal heal record: %d!", spellName, amount))
  CritMatic.MessageFrame:CreateMessage(message, 1, 1, 1)  -- White color

end

function CritMatic.ShowNewCritMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end

  local message = string.upper(string.format("New %s crit: %d!", spellName, amount))
  CritMatic.MessageFrame:CreateMessage(message, 1, 0.84, 0)  -- Gold color
end

function CritMatic.ShowNewNormalMessage(spellName, amount)
  if spellName == "Auto Attack" then
    return
  end

  local message = string.upper(string.format("New %s normal hit record: %d!", spellName, amount))
  CritMatic.MessageFrame:CreateMessage(message, 1, 1, 1)  -- White color

end


