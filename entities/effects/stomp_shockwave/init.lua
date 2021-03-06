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

local matRefraction	= Material( "refract_ring" )
matRefraction:SetInt("$nocull",1)

function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()

	self.Refract = 0
	self.DeltaRefract = 3
	self.Size = 0
	self.MaxSize = 600
	self.TimeLeft = CurTime() + 0.2
	
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
		self.Refract = 0.3
		self.DeltaRefract = 0.03
		self.MaxSize = 400
	end

end

function EFFECT:Think( )
	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()
		
		self.Refract = self.Refract + self.DeltaRefract*ftime
		self.Size = self.Size + 3000*ftime

		return true
	else
		return false	
	end
end

function EFFECT:Render()
	local startpos = self.Position
	
	--shockwave
	if self.Size < self.MaxSize then
		
		matRefraction:SetMaterialFloat( "$refractamount", math.sin(self.Refract*math.pi) * 0.1 )
		render.SetMaterial( matRefraction )
		render.UpdateRefractTexture()
		
		render.DrawQuadEasy( startpos,
		Vector(0,0,1),
		self.Size, self.Size)
		
	end

end



