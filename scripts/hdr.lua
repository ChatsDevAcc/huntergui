--[[
This is an open source script by Hunter.
Feel free to steal stuff from here!
]]
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local https = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
if not isfile("HDR_SAVES.json") then
	writefile("HDR_SAVES.json", "{}")
end

local saves = {}

local player = Players.LocalPlayer
local brickfolder = workspace:WaitForChild("Bricks")
local MULTIPLIER = 10
local COL = Color3.new(0,0,0)
local range = 25
local blocks = {}
local auraConnection = nil
local lastPaint = 0
local paintDelay = 0.1
local TOOL = nil
local function getTool()
	local t = game.Players.LocalPlayer.Character:FindFirstChild("Paint")
	if t then
		TOOL = t
		return t.Script.Event
	elseif not t then
		t = game.Players.LocalPlayer.Backpack:FindFirstChild("Paint")
		if t then
			TOOL = t
			return t.Script.Event
		end
	end
end

local function getRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
end

local function sameColor(a: Color3, b: Color3)
	local epsilon = 0.0001

	return math.abs(a.R - b.R) < epsilon
		and math.abs(a.G - b.G) < epsilon
		and math.abs(a.B - b.B) < epsilon
end

local function paintBlock(block)
	if not block then
		return
	end

	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")
	local root = getRoot()

	if not character or not backpack or not root or not TOOL then
		return
	end

	TOOL.Parent = character

	local Event = getTool()

	if not Event then
		TOOL.Parent = backpack
		return
	end

	local success, err = pcall(function()
		Event:FireServer(
			block,
			Enum.NormalId.Left,
			root.Position,
			"both \xF0\x9F\xA4\x9D",
			COL,
			"neon",
			""
		)
	end)

	TOOL.Parent = backpack

	if not success then
		warn("[ERROR]: " .. tostring(err))
	end
end

local success, decoded = pcall(function()
	return https:JSONDecode(readfile("HDR_SAVES.json"))
end)

if success and type(decoded) == "table" then
	saves = decoded
end

local window = Rayfield:CreateWindow({
	name = "Hunter's HDR Blocks",
	subtitle = "Open source",
})
local mouse = game.Players.LocalPlayer:GetMouse()

local function ConvertRGBtoNEW(col)
	return Color3.new(
		col.R * MULTIPLIER,
		col.G * MULTIPLIER,
		col.B * MULTIPLIER
	)
end

local function round3(n)
	return math.round(n * 1000) / 1000
end

local function NOTIFYCOLOUR()
	window:Toast({
		title = "Your new colour:",
		subtitle = string.format(
			"%0.3f, %0.3f, %0.3f",
			round3(COL.R),
			round3(COL.G),
			round3(COL.B)
		),
		avatar = 1,
	})
end

local function toRGB(col)
	return Color3.fromRGB(
		col.R * 255,
		col.G * 255,
		col.B * 255
	)
end

local function getSaveNames()
	local names = {}

	for name in pairs(saves) do
		table.insert(names, name)
	end

	table.sort(names)

	return names
end

local tab = window:CreateTab({ name = "Home", icon = 93364949241311 })

tab:CreateButton({
	name = "Load Infinite Yield",
	callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end,
})

tab:CreateButton({
	name = "Set colour to black",
	callback = function()
		COL = Color3.new(0 / 0, 0 / 0, 0 / 0)
		NOTIFYCOLOUR()
	end,
})

local currentSaveName = ""
local currentSelectedSavefile = ""

tab:CreateKeybind({
	name = "Colour Keybind",
	value = Enum.KeyCode.F,
	callback = function(key)
		if not TOOL then
			getTool()
		end
		TOOL.Parent = game.Players.LocalPlayer.Character
		local Event = getTool()
		if not Event then
			window:Toast({
				title = "Error",
				subtitle = "Couldn't find paint tool",
				avatar = 1,
			})
			return
		end
		Event:FireServer(
			mouse.Target,
			Enum.NormalId.Left,
			game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position,
			"both \xF0\x9F\xA4\x9D",
			COL,
			"neon",
			""
		)

		TOOL.Parent = game.Players.LocalPlayer.Backpack
	end,
})

local lastSliderChange = 0

local m = tab:CreateSlider({
	name = "Multiplier",
	range = { 1, 10000 },
	increment = 1,
	value = 10,
	suffix = "",
	callback = function(value)
		local normalColour = Color3.new(
			COL.R / MULTIPLIER,
			COL.G / MULTIPLIER,
			COL.B / MULTIPLIER
		)

		MULTIPLIER = value
		COL = ConvertRGBtoNEW(normalColour)

		lastSliderChange = tick()

		task.delay(0.5, function()
			if tick() - lastSliderChange >= 0.5 then
				NOTIFYCOLOUR()
			end
		end)
	end,
})

local lastChanged = 0

local c = tab:CreateColorPicker({
	name = "Colour",
	color = Color3.fromRGB(96, 205, 255),
	callback = function(color, alpha)
		COL = ConvertRGBtoNEW(color)

		lastChanged = tick()

		task.delay(0.75, function()
			if tick() - lastChanged >= 0.75 then
				NOTIFYCOLOUR()
			end
		end)
	end,
})

tab:CreateInput({
	name = "Colour Input",
	numeric = false,
	value = "10 50 100",
	placeholder = "SEPERATE EACH VALUE WITH A SPACE",
	callback = function(text)
		local vals = string.split(text, " ")
		local R, G, B = nil, nil, nil
		for i, v in ipairs(vals) do
			if i == 1 then
				R = tonumber(v) or math.nan
			elseif i == 2 then
				G = tonumber(v) or math.nan
			elseif i == 3 then
				B = tonumber(v) or math.nan
			end
		end

		if R and G and B then
			COL = ConvertRGBtoNEW(Color3.new(R, G, B))
			c:Set(Color3.new(
				COL.R / MULTIPLIER, COL.G / MULTIPLIER, COL.B/ MULTIPLIER), true)
			NOTIFYCOLOUR()
		end
	end,
})

tab:CreateButton({
	name = "What values are supported?",
	callback = function()
		window:Popup({
			title = "Colour Input Information",
			subtitle = "",
			boxes = {
				{ title = "Supported Values", description = "Any number. For infinite, write 'inf'. For nan, write something that IS NOT a number like a letter.", icon = 93364949241311 },
				{ title = "You may encounter issues", description = "Colour input may be unstable, report any bugs or fix it yourself." },
			},
			options = { { text = "Got it", style = "primary" } },
		})
	end,
})

tab:CreateButton({
	name = "Copy colour values",
	callback = function()
		local values = string.format("%f %f %f", COL.R, COL.G, COL.B)
		setclipboard(values)
	end,
})

tab:CreateSection({ name = "Aura", icon = 93364949241311 })

local function addBlock(block)
	if block:IsA("BasePart") then
		blocks[block] = true
	end
end

local function removeBlock(block)
	blocks[block] = nil
end

local function FetchallBlocks()
	table.clear(blocks)
	for _, block in ipairs(brickfolder:GetDescendants()) do
		addBlock(block)
	end
end

local function getDist(pos: Vector3)
	local root = getRoot()
	if not root then
		return false
	end
	return (root.Position - pos).Magnitude <= range
end

local function fetchNearestBlock()
	local root = getRoot()

	if not root then
		return nil
	end

	local validBlocks = {}

	for block in pairs(blocks) do
		if not block.Parent then
			blocks[block] = nil
			continue
		end
		if block.Material == Enum.Material.Neon and sameColor(block.Color, COL) then
			continue
		end
		if (block.Position - root.Position).Magnitude <= range then
			table.insert(validBlocks, block)
		end
	end
	if #validBlocks == 0 then
		return nil
	end
	return validBlocks[math.random(1, #validBlocks)]
end

local function startAura()
	if auraConnection then
		return
	end
	auraConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now - lastPaint < paintDelay then
			return
		end
		local block = fetchNearestBlock()
		if not block then
			return
		end
		lastPaint = now
		paintBlock(block)
	end)
end

local function stopAura()
	if auraConnection then
		auraConnection:Disconnect()
		auraConnection = nil
	end
end

FetchallBlocks()

brickfolder.DescendantAdded:Connect(addBlock)
brickfolder.DescendantRemoving:Connect(removeBlock)

tab:CreateSlider({
	name = "Range",
	range = {1, 500},
	increment = 1,
	value = 25,
	suffix = "",
	callback = function(value)
		range = value
	end,
})

local sprint = tab:CreateToggle({
	name = "Light Aura",
	flag = "HDRBlocksAura",
	value = false,
	callback = function(value)
		if value then
			startAura()
		else
			stopAura()
		end
	end,
})


local tab = window:CreateTab({ name = "Saves", icon = 93364949241311 })

tab:CreateInput({
	name = "Save name",
	numeric = false,
	value = "colour",
	placeholder = "Enter a name",
	callback = function(text)
		currentSaveName = text
	end,
})

local saveDropdown

tab:CreateButton({
	name = "Save Colour + Multiplier",
	callback = function()
		if currentSaveName == "" then
			return
		end

		saves[currentSaveName] = {
			R = COL.R,
			G = COL.G,
			B = COL.B,
			Multiplier = MULTIPLIER,
		}

		writefile("HDR_SAVES.json", https:JSONEncode(saves))
		window:Notify({
			title = "Save System",
			content = "Saved successfully",
			duration = 5,
		})
		currentSelectedSavefile = currentSaveName

		if saveDropdown then
			saveDropdown:Refresh(getSaveNames())
		end
	end,
})

saveDropdown = tab:CreateDropdown({
	name = "Save list",
	multiSelect = false,
	options = getSaveNames(),
	value = getSaveNames()[1],
	callback = function(selected)
		if type(selected) == "table" then
			currentSelectedSavefile = selected[1]
		else
			currentSelectedSavefile = selected
		end
	end,
})

tab:CreateButton({
	name = "Load save",
	callback = function()
		local save = saves[currentSelectedSavefile]

		if not save then
			warn("NOT SAVE")
			window:Notify({
				title = "Save System",
				content = "Failed to load a save: Does not exist",
				duration = 5,
			})
			return
		end
		MULTIPLIER = save.Multiplier
		COL = Color3.new(
			save.R,
			save.G,
			save.B
		)
		NOTIFYCOLOUR()
		c:Set(Color3.new(
			COL.R / MULTIPLIER, COL.G / MULTIPLIER, COL.B/ MULTIPLIER), true)
		m:Set(MULTIPLIER)
		window:Notify({
			title = "Save System",
			content = "Loaded save successfully",
			duration = 5,
		})
	end,
})

tab:CreateButton({
	name = "Delete Save",
	callback = function()
		window:Popup({
			title = "Delete save?",
			content = "You cannot undo this action!",
			options = {
				{ text = "No" },
				{ text = "Yes", style = "danger", callback = function()
					local save = saves[currentSelectedSavefile]
					if save then
						
						saves[currentSelectedSavefile] = nil
						writefile("HDR_SAVES.json", https:JSONEncode(saves))
						saveDropdown:Refresh(getSaveNames())
						window:Toast({
							title = "Save System",
							subtitle = "Deleted save successfully",
							avatar = 1,
						})
					end
				end },
			},
		})
	end,
})

local tab = window:CreateTab({ name = "Config", icon = 93364949241311 })

tab:CreateButton({
	name = "Destroy script",
	callback = function()
		stopAura()
		window:Unload()
	end,
})
