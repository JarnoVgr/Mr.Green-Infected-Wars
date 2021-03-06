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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Think()
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if CurTime() < self.Weapon:GetNetworkedFloat("LastShootTime", -100) + self.Primary.Delay then return end

	self.Owner:LagCompensation(true)
	--local hurt = self.Owner:TraceHullAttack(self.Owner:EyePos(), self.Owner:EyePos() + self.Owner:GetAimVector() * 70, 
		--Vector(-16,-16,-16), Vector(36, 36, 36), 1, self.Primary.Damage, 200, true)

	local trace = self.Owner:EyeTraceLine(70) -- TraceHullAttack doesn't do damage for some reason...
		
	if trace.HitNonWorld and trace.Entity:IsValid() then
		trace.Entity:TakeDamage(self.Primary.Damage, self.Owner, self.Weapon)
		if trace.Entity:IsPlayer() and trace.Entity:Team() ~= self.Owner:Team() then
			trace.Entity:SendLua("StalkerFuck(5)") -- >:3
		end
		local phys = trace.Entity:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceOffset(self.Owner:GetForward() * 9000, trace.HitPos)
		end
	end
		
	if trace.Hit then
		local mat = trace.MatType

		local decal = nil
		local soundname = nil
		
		-- Thanks for searching these for me Jet, saves me a lot of trouble

		if mat == MAT_FLESH then
			decal = "Impact.Flesh"
			soundname = "physics/flesh/flesh_impact_bullet"..math.random(1,5)..".wav"
			local effectdata = EffectData()
				effectdata:SetOrigin(trace.HitPos)
				effectdata:SetStart(trace.HitPos + trace.HitNormal * 8)
			util.Effect("BloodImpact", effectdata)
		elseif mat == MAT_ANTLION then
			decal = "Impact.Antlion"
			soundname = "npc/antlion/shell_impact"..math.random(1,4)..".wav"
		elseif mat == MAT_BLOODYFLESH then
			decal = "Impact.BloodyFlesh"
			soundname = "physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav"
			local effectdata = EffectData()
				effectdata:SetOrigin(trace.HitPos)
				effectdata:SetStart(trace.HitPos + trace.HitNormal * 8)
			util.Effect("BloodImpact", effectdata)
		elseif mat == MAT_SLOSH then
			decal = "Impact.BloodyFlesh"
			soundname = "physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav"
		elseif mat == MAT_ALIENFLESH then
			decal = "Impact.AlienFlesh"
			soundname = "physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav"
		elseif mat == MAT_WOOD then
			decal = "Impact.Concrete"
			soundname = "physics/wood/wood_solid_impact_bullet"..math.random(1,5)..".wav"
		elseif mat == MAT_CONCRETE then
			decal = "Impact.Concrete"
			soundname = "physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav"
		elseif mat == MAT_METAL then
			decal = "Impact.Concrete"
			soundname = "physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav"
		elseif mat == MAT_SAND or mat == MAT_DIRT or mat == MAT_FOLIAGE then
			decal = "Impact.Concrete"
			soundname = "physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav"
		elseif mat == MAT_GLASS then
			decal = "Impact.Glass"
			soundname = "physics/glass/glass_impact_bullet"..math.random(1,4)..".wav"
		elseif mat == MAT_VENT or mat == MAT_GRATE then
			decal = "Impact.Metal"
			soundname = "physics/metal/metal_box_impact_bullet"..math.random(1,3)..".wav"
		elseif mat == MAT_PLASTIC then
			decal = "Impact.Metal"
			soundname = "physics/plastic/plastic_box_impact_bullet"..math.random(1,5)..".wav"
		elseif mat == MAT_COMPUTER then
			decal = "Impact.Metal"
			soundname = "physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav"
		elseif mat == MAT_TILE then
			decal = "Impact.Concrete"
			soundname = "physics/surfaces/tile_impact_bullet"..math.random(1,4)..".wav"
		else -- Let's catch off all the remaining types too
			decal = "Impact.Concrete"
			soundname = "physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav"
		end

		if soundname then
			self.Owner:EmitSound(soundname)
		end

		if decal then
			util.Decal(decal, trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end
	else
		self.Owner:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
	end

	if self.Alternate then
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	else
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	end
	self.Alternate = not self.Alternate

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
end
