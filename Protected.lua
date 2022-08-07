local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

_G.AimbotEnabled = true
_G.TeamCheck = true If set to true then the script would only lock your aim at enemy team members.
_G.AimPart = "Head" -- Where the aimbot script would lock at.
_G.Sensitivity = 0 -- How many seconds it takes for the aimbot script to officially lock onto the target's aimpart.

_G.CircleSides = 64 -- How many sides the FOV circle would have.
_G.CircleColor = Color3.fromRGB(255, 255, 255) -- (RGB) Color that the FOV circle would appear as.
_G.CircleTransparency = 0.7 -- Transparency of the circle.
_G.CircleRadius = 80 -- The radius of the circle / FOV.
_G.CircleFilled = false -- Determines whether or not the circle is filled.
_G.CircleVisible = true -- Determines whether or not the circle is visible.
_G.CircleThickness = 0 -- The thickness of the circle.

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Filled = _G.CircleFilled
FOVCircle.Color = _G.CircleColor
FOVCircle.Visible = _G.CircleVisible
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Transparency = _G.CircleTransparency
FOVCircle.NumSides = _G.CircleSides
FOVCircle.Thickness = _G.CircleThickness
local function GetClosestPlayer()
	local MaximumDistance = _G.CircleRadius
	local Target = nil
	for _, v in next, Players:GetPlayers() do
		if v.Name ~= LocalPlayer.Name then
			if _G.TeamCheck == true then
				if v.Team ~= LocalPlayer.Team then
					if v.Character ~= nil then
						if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
							if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
								local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
								local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
								
								if VectorDistance < MaximumDistance then
									Target = v
								end
							end
						end
					end
				end
			else
				if v.Character ~= nil then
					if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
						if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
							local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
							local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
							
							if VectorDistance < MaximumDistance then
								Target = v
							end
						end
					end
				end
			end
		end
	end

	return Target
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Filled = _G.CircleFilled
    FOVCircle.Color = _G.CircleColor
    FOVCircle.Visible = _G.CircleVisible
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Transparency = _G.CircleTransparency
    FOVCircle.NumSides = _G.CircleSides
    FOVCircle.Thickness = _G.CircleThickness

    if Holding == true and _G.AimbotEnabled == true then
        TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, GetClosestPlayer().Character[_G.AimPart].Position)}):Play()
    end
end)

local localPlayer=game.Players.LocalPlayer
 
function highlightModel(objObject)
	for i,v in pairs(objObject:children())do
		if v:IsA'BasePart'and v.Name~='HumanoidRootPart'then
			local bHA=Instance.new('BoxHandleAdornment',v)
			bHA.Adornee=v
			bHA.Size= v.Name=='Head' and Vector3.new(1.25,1.25,1.25) or v.Size
			bHA.Color3=v.Name=='Head'and Color3.new(1,0,0)or v.Name=='Torso'and Color3.new(0,1,0)or Color3.new(0,0,1)
			bHA.Transparency=.5
			bHA.ZIndex=1
			bHA.AlwaysOnTop=true
		end
		if #v:children()>0 then
			highlightModel(v)
		end
	end
end
 
function unHighlightModel(objObject)
	for i,v in pairs(objObject:children())do
		if v:IsA'BasePart' and v:findFirstChild'BoxHandleAdornment' then
			v.BoxHandleAdornment:Destroy()
		end
		if #v:children()>0 then
			unHighlightModel(v)
		end
	end
end
 
function sortTeamHighlights(objPlayer)
	repeat wait() until objPlayer.Character
	if objPlayer.TeamColor~=localPlayer.TeamColor then
		highlightModel(objPlayer.Character)
	else
		unHighlightModel(objPlayer.Character)
	end
	if objPlayer~=localPlayer then
		objPlayer.Changed:connect(function(strProp)
			if strProp=='TeamColor'then
				if objPlayer.TeamColor~=localPlayer.TeamColor then
					unHighlightModel(objPlayer.Character)
					highlightModel(objPlayer.Character)
				else
					unHighlightModel(objPlayer.Character)
				end
			end
		end)
	else
		objPlayer.Changed:connect(function(strProp)
			if strProp=='TeamColor'then
				wait(.5)
				for i,v in pairs(game.Players:GetPlayers())do
					unHighlightModel(v)
					if v.TeamColor~=localPlayer.TeamColor then
						highlightModel(v.Character)
					end
				end
			end
		end)
	end
end
 
for i,v in pairs(game.Players:GetPlayers())do
	v.CharacterAdded:connect(function()
		sortTeamHighlights(v)
	end)
	sortTeamHighlights(v)
end
game.Players.PlayerAdded:connect(function(objPlayer)
	objPlayer.CharacterAdded:connect(function(objChar)
		sortTeamHighlights(objPlayer)
	end)
end)
