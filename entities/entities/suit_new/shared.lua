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

--Suit entity, based on magic from Swep Construction Kit

ENT.Type = "anim"  
ENT.Base = "base_anim"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT 

 
if SERVER then
	AddCSLuaFile("shared.lua")
end 
 
function ENT:Initialize()
	
	if SERVER then
		self.Entity:DrawShadow(false)
		self.Entity:SetSolid(SOLID_NONE)
	end
	
	if CLIENT then
		self:CreateModelElements()
	end
end

//Set a key string for our table
if SERVER then
	function ENT:CreateSuit( name )
		self:SetNWString("suitname", name)	
	end	
end

//Check if stuff is valid or not
function ENT:Think()
	if SERVER then
		local pl = self:GetOwner():GetRagdollEntity() or self:GetOwner()
		self:SetColor(pl:GetColor())
		if not IsValid(pl) then self:Remove() end
		if IsValid(self:GetOwner()) and not self:GetOwner():Alive() and !IsValid(self:GetOwner():GetRagdollEntity()) then self:Remove() end
		self.Entity:SetPos(pl:GetPos())
	end
	if CLIENT then
		if IsValid(self:GetOwner()) then
			self:GetOwner().EquipedSuit = self:GetNWString("suitname")
		end
	end
end

//Remove all children 
function ENT:OnRemove()
	if CLIENT then
		self:RemoveModels()
		if IsValid(self:GetOwner()) then
			self:GetOwner().EquipedSuit = nil
		end
	end
end

//Build a table with our models
function ENT:InitializeClientsideModels(tbl)
	
	self.Elements = {}
	if tbl then
		self.Elements = table.Copy(tbl) 
	end
	
end

--Fill the table with info and create all this stuff
function ENT:CreateModelElements()
	
	if suitsData1 and suitsData1[self:GetSuitType()] and suitsData1[self:GetSuitType()].suit then
		self:InitializeClientsideModels(suitsData1[self:GetSuitType()].suit)
		self:CreateModels(self.Elements)
	end
	
end

function ENT:GetSuitType()
	return self:GetNWString("suitname") or nil
end

//Small function to check if suit models dissapeared
function ENT:CheckModelElements()
	if !self.Elements then
		timer.Simple(0,function()
			self:CreateModelElements()
		end)
	end
end

if CLIENT then

	ENT.RenderOrder = nil

	function ENT:Draw()
		
		if IsValid(self:GetOwner()) then
			self.Entity:SetRenderBounds( self:GetOwner():OBBMaxs()*1.5, self:GetOwner():OBBMins()*1.5) 
		end
	
		
		if self:GetOwner() == LocalPlayer() and LocalPlayer():Alive() then return end
		
		if self.CheckModelElements then
			self:CheckModelElements()
		end
		
		if (!self.Elements) then return end
		
		if (!self.RenderOrder) then

			self.RenderOrder = {}

			for k, v in pairs( self.Elements ) do
				if (v.type == "Model") then
					table.insert(self.RenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.RenderOrder, k)
				end
			end

		end
		
		if (IsValid(self:GetOwner())) then
			if IsValid(self:GetOwner():GetRagdollEntity()) then
				bone_ent = self:GetOwner():GetRagdollEntity()
			else
				bone_ent = self:GetOwner()
			end
		else
			bone_ent = self
		end
		
		for k, name in pairs( self.RenderOrder ) do
		
			local v = self.Elements[name]
			if (!v) then self.RenderOrder = nil break end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.Elements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.Elements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				model:SetModelScale(v.size)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end

	end
	
	
	function ENT:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
		end
		
		return pos, ang
	end

	function ENT:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists ("../"..v.model) ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
					v.modelEnt.SuitProp = true
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("../materials/"..v.sprite..".vmt")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end

	function ENT:RemoveModels()
		if (self.Elements) then
			for k, v in pairs( self.Elements ) do
				if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
			end
		end
		self.Elements = nil
	end


end
