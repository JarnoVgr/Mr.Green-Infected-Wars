--[[-----------------------------------------------------------------------------
 * Infected Wars, an open source Garry's Mod game-mode.
 *
 * Infected Wars is the work of multiple authors,
 * a full list can be found in CONTRIBUTORS.md.
 * For more information, visit https://github.com/JarnoVgr/InfectedWars
 *
 * Infected Wars is free software: you can redistribute it and/or modify
 * it under the terms of the MIT License.
 *
 * A full copy of the MIT License can be found in LICENSE.txt.
 -----------------------------------------------------------------------------]]

if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "shotgun"

if CLIENT then
	SWEP.PrintName = "M3 Super 90"
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.IconLetter = "k"
	killicon.AddFont("iw_m3super90", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
	
	SWEP.IgnoreThumbs = true
	
end

function SWEP:InitializeClientsideModels()
	
	self.VElements = {
		["ammo"] = { type = "Quad", bone = "v_weapon.M3_PARENT", rel = "", pos = Vector(-0.545, 3.163, 6.074), angle = Angle(0, 0, 175.888), size = 0.012, draw_func = function(wep) DrawWeaponInfo(wep) end}
	}

	self.WElements = {}
	
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_shot_m3super90.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_m3super90.mdl"

SWEP.Weight				= 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_M3.Single")
SWEP.Primary.Recoil			= 5
SWEP.Primary.Damage			= 11
SWEP.Primary.NumShots		= 10
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay 			= 0.95
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize*5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Cone			= 0.11
SWEP.Primary.ConeMoving		= 0.14
SWEP.Primary.ConeCrouching	= 0.08

SWEP.MuzzleEffect			= "rg_muzzle_hmg"
SWEP.ShellEffect			= "rg_shelleject_shotgun" 

SWEP.Tracer 				= ""

--SWEP.IronSightsPos = Vector(5.73,-2,3.375)
--SWEP.IronSightsAng = Vector(0.001,.05,0.001)

local ShotgunReloading
ShotgunReloading = false

SWEP.EjectDelay	= 0.53
SWEP.Reloadaftershoot = 0 
SWEP.Reloadstopdelay = 0.5

function SWEP:Deploy()
	DrawCrHair = true

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW) 
	if SERVER then
		self.Owner:DrawWorldModel(true)
	end
	self:SetColor(255, 255, 255, 255)
	self.Owner:SetColor(255, 255, 255, 255)
	self:SetFleshMaterial(false)

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	ShotgunReloading = false
	self.Weapon:SetNetworkedBool( "reloading", false)

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	self.Reloadaftershoot = CurTime() + 1
	
	self:SetIronsights(false)
	return true
end

function SWEP:Reload()
	--self:SetIronsights(false)
	if ( self.Reloadaftershoot > CurTime() ) then return end

	if (self.Weapon:GetNWBool("reloading", false)) or ShotgunReloading then return end

	if (self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
			ShotgunReloading = true
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
			self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
		timer.Simple(0.3, function()
			if not IsValid(self.Weapon) then return end
			ShotgunReloading = false
			self.Weapon:SetNetworkedBool("reloading", true)
			self.Weapon:SetVar("reloadtimer", CurTime() + 1)
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		end)
	end

end

function SWEP:Think()

	if self.Weapon:Clip1() > self.Primary.ClipSize then
		self.Weapon:SetClip1(self.Primary.ClipSize)
	end

	if self.Weapon:GetNetworkedBool( "reloading") == true then
	
		if self.Weapon:GetNetworkedInt( "reloadtimer") < CurTime() then

			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
				self.Weapon:SetNetworkedBool( "reloading", false)
				self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
			else
			
			self.Weapon:SetNetworkedInt( "reloadtimer", CurTime() + 0.45 )
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)

				if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0) then
					self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
				else
					self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
				end
			end
		end
	end

	if self.Owner:KeyPressed(IN_ATTACK) and (self.Weapon:GetNWBool("reloading", true)) then
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Reloadstopdelay)
		self.Weapon:SetNetworkedBool( "reloading", false)
		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	end
end

