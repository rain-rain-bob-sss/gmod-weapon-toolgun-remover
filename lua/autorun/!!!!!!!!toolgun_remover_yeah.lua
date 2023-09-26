local oldemt=oldemt or table.Copy(debug.getregistry())["Entity"]
local oldpmt=oldpmt or table.Copy(debug.getregistry())["Player"]
local timer=timer or timer
local es=ents
local hk=hk or hook
local ISV=ISV or IsValid
function oldemt:TimeStop()
	if type(self) == 'NextBot' then
		oldemt.NextThink(self,CurTime()+1e9)
		oldemt.SetMoveType(self,MOVETYPE_NONE)
	elseif self:IsNPC() then
		oldemt.NextThink(self,CurTime()+1e9)
		oldemt.SetMoveType(self,MOVETYPE_NONE)
		if oldemt.GetClass(self) == 'npc_rollermine' or oldemt.GetClass(self) == 'npc_manhack' or oldemt.GetClass(self) == 'npc_clawscanner' or oldemt.GetClass(self) == 'npc_cscanner' then
			local phy = oldemt.GetPhysicsObject(self)
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
		if oldemt.GetClass(self) == 'npc_turret_floor' then
			if self.turretstate == nil then self.turretstate = oldemt.GetSaveTable(self).m_bEnabled end
			oldemt.SetSaveValue(self,'m_bEnabled', false)
		end
	elseif self:IsRagdoll() then
		local storedVelocities = {}
		local storedTypes = {}
		for c = 0, oldemt.GetPhysicsObjectCount(self) - 1 do
			local phy = oldemt.GetPhysicsObjectNum(self,c)
			if IsValid(phy) then
				storedVelocities[c] = phy:GetVelocity()
				if not storedTypes[c] then storedTypes[c] = phy:IsMotionEnabled() end
				phy:EnableMotion(false)
			end
		end
	elseif oldemt.GetClass(self) == 'func_rotating' and SERVER then
		oldemt.Fire(self,'SetSpeed', '0', 0)
	elseif oldemt.GetClass(self) == 'func_tracktrain' and SERVER then
		oldemt.Fire(self,'Stop')
	elseif self.Owner ~= self.Owner then
		oldemt.NextThink(self,CurTime()+1e9)
		if oldemt.GetClass(self) == 'npc_grenade_frag' then
			if not self.savedtime then self.savedtime = oldemt.GetSaveTable(self).m_flDetonateTime end
			oldemt.SetSaveValue(self,'m_flDetonateTime', self.savedtime)
		end
		if oldemt.GetClass(self) == 'rpg_missile' or oldemt.GetClass(self) == 'crossbow_bolt' then
			oldemt.SetMoveType(self,MOVETYPE_NONE)
		end
		if oldemt.GetClass(self) == 'prop_combine_ball' then
			if timer.Exists('cball_' .. tostring(self:EntIndex()) .. '_explode') then
				timer.Remove('cball_' .. tostring(self:EntIndex()) .. '_explode')
			end
			oldemt.SetMoveType(self,MOVETYPE_NONE)
			local phy = self:GetPhysicsObject()
			if IsValid(phy) then
				phy:EnableMotion(false)
			end
		end
		if oldemt.GetClass(self) == 'hunter_flechette' or oldemt.GetClass(self) == 'grenade_ar2' or oldemt.GetClass(self) == 'grenade_spit' then
			oldemt.SetMoveType(self,MOVETYPE_NONE)
		end
		if self:GetClass() == 'grenade_helicopter' then
			local phy = self:GetPhysicsObject()
			if IsValid(phy) then
				phy:SetVelocity(Vector())
				phy:EnableMotion(false)
			end
		end
		for k, v in pairs({'grenade_hand', 'rpg_rocket', 'crossbow_bolt_hl1', 'grenade_mp5', 'monster_satchel'}) do
			if oldemt.GetClass(self) == v then
				oldemt.SetMoveType(self,MOVETYPE_NONE)
                break
			end
		end
		local phy = oldemt.GetPhysicsObject(self)
		local vel = oldemt.GetVelocity(self)
		if IsValid(phy) then
			phy:SetVelocity(Vector())
			phy:EnableMotion(false)
		end
		self:SetVelocity(Vector())
	end
end
function oldemt:StopThinking()--From lxs codes,BY LX
    local old = GAMEMODE.EntityTakeDamage--你懂的
    GAMEMODE.EntityTakeDamage = function(gm, ent, ...)
        if ent == self then return end
        return old(gm, ent, ...)
    end

    local old = GAMEMODE.EntityRemoved--你懂的，让实体在被移除时不做出任何反应
    GAMEMODE.EntityRemoved = function(gm, ent, ...)
        if ent == self then return end
        return old(gm, ent, ...)
    end
    --你懂的↓
    local tooverride={
        "AcceptInput",'OnPhysgunPickup','NpcCanProperty','NpcCanTool','OnNpcTakeDamage','NpcThink','SetNpc','QTGNPCThink','Initialize','Use','OnTakeDamage',
        'GetEnemy','OnRangeAttack','OnMeleeAttack','OnDeath','OnDead','GetNearestUsableHidingSpot','OnInjured','OnRemove','GetNearestTarget','ClaimHidingSpot',
        'RecomputeTargetPath','OnStuck','UnstuckFromCeiling','OnReloaded'
    }
    self.AcceptInput = function() return false end
    self.OnPhysgunPickup = function()return end 
    self.NpcCanProperty = function()return end 
    self.NpcCanTool = function()return end 
    self.OnNpcTakeDamage = function()return end 
    self.NpcThink = function()return end 
    self.SetNpc = function()return end 
    self.QTGNPCThink = function()return end 
    self.Initialize=function()return end
    self.Use=function()return end
    self.OnTakeDamage=function()return end
    self.GetEnemy=function()return end
    self.OnRangeAttack = function() return end
    self.OnMeleeAttack = function() return end 
    self.OnDeath = function() return end 
    self.OnDead = function() return end 
    self.GetNearestUsableHidingSpot = function() return end 
    self.OnInjured = function() return end 
    self.OnRemove = function() return end 
    self.GetNearestTarget = function()return end 
    self.ClaimHidingSpot = function() return end 
    self.RecomputeTargetPath = function() return end 
    self.OnStuck = function() return end 
    self.UnstickFromCeiling = function() return end 
    self.OnReloaded = function() return end
    for i,v in pairs(tooverride)do
        pcall(function()
            oldemt.SetVar(v,function() return "I am gay" end)
        end)
    end 
    oldemt.TimeStop(self)
    oldemt.NextThink(self,CurTime()+1e9)
end
local FuckedHooks={}
local function HookFucker(name,ShouldBeFucked)
    FuckedHooks[name]=true
    for N,F in pairs(hk.GetTable()[name])do
        if(not f)then continue end
        local newf=function(...)
            local Fucked=ShouldBeFucked(...)
            if((istable(Fucked) and Fucked.Fuck==true) or Fucked==true)then
                return istable(Fucked) and unpack(Fucked) or Fucked
            else
                return f
            end
        end
    end
end
function oldemt:SuperRemove()
    local e1 = FindMetaTable('Entity')
    local e2 = debug.getregistry()['Entity']
    local rs={e1.Remove,e2.Remove,oldemt.Remove}
    for i=1,5 do
        pcall(function()
            for _,v in ipairs(rs)do
                pcall(function()
                    v(self)
                end)
            end
            local old = GAMEMODE.EntityRemoved
            GAMEMODE.EntityRemoved = function(gm, e, ...)
                if e == self then return end
                return old(gm, e, ...)
            end
        end)
    end
end
local WEP={}
local hook=hook or hook
local hooks=hooks or {}
for i,v in pairs(hooks)do
    hk.Remove("KeyPress",v.Name)
end
local function hook_add(event,name,func)
    local randomstr=string.gsub("FUCKFUCKFUCKFUCKFUCKFUCKFUCKFUCKFUCK","FUCK",function() return utf8.char(math.random(64,120000))..utf8.char(math.random(64,120000)) end)
    local newname=math.random(-9999,9999)..string.upper(string.reverse(name)..math.random(-9999,9999))..math.random(-9999,9999)..string.rep("!!!",5,"!!!")
    hooks[name]={event=event,Name=newname,func=func}
    hk.Add(event,newname,func)
end
WEP.ViewModel		= "models/weapons/c_toolgun.mdl"
WEP.WorldModel		= "models/weapons/w_toolgun.mdl"
WEP.ClassName="gmod___toolgun"
WEP.PrintName="Tool Gun-REMOVER"
WEP.Spawnable=true 
WEP.AdminSpawnable=true 
WEP.AdminOnly=true
function WEP:Initialize()
    
end
function WEP:PrimaryAttack()

end
function WEP:SecondaryAttack()

end
function WEP:CustomAmmoDisplay()
    return {Draw=false}
end
weapons.Register(WEP,WEP.ClassName)
if(CLIENT)then
local matScreen = Material( "models/weapons/v_toolgun/screen" )
local txBackground = surface.GetTextureID( "models/weapons/v_toolgun/screen_bg" )
local TEX_SIZE = 256

-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture = GetRenderTarget( "GModToolgunScreen", TEX_SIZE, TEX_SIZE )
local FONTS={
    'BudgetLabel',
    'CloseCaption_Italic',
    'DermaLarge',
    'TargetID',
    'HDRDemoText',
    'CenterPrintText',
    'Helvetica'
}
local basefont="TGRMER_"
local currentfontindex=1
local currentFont=basefont.."1"
for i,v in pairs(FONTS)do
    surface.CreateFont( basefont..i, {
        font	= v,
        size	= 60,
        weight	= 900
    } )
end
timer.Create("TGRMER_Fonts",1,0,function()
    currentfontindex=currentfontindex+1
    if(currentfontindex>#FONTS)then
        currentfontindex=1
    end
    currentFont=basefont..currentfontindex
    language.Add("gmod___toolgun","[NULL ENTITY]")
    killicon.AddFont("gmod___toolgun",currentFont," [NULL ENTITY] ",Color(255,0,0))
end)
local function DrawScrollingText( text, y, texwide )

	local w, h = surface.GetTextSize( text )
	w = w + 64

	y = y - h / 2 -- Center text to y position

	local x = RealTime() * 250 % w * -1

	while ( x < texwide ) do
        local shake={x=math.random(-5,5),y=math.random(-5,5)}
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( x + 3+shake.x, y + 3+shake.y )
		surface.DrawText( text )
		surface.SetTextColor( 255,0,0, 255 )
		surface.SetTextPos( x+shake.x, y+shake.y )
		surface.DrawText( text )

		x = x + w

	end

end
--COPIED FROM GMOD_TOOL/CL_VIEWSCREEN.LUA
--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode
		screen's rendertarget texture.
-----------------------------------------------------------]]
function WEP:RenderScreen()

	-- Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", RTTexture )

	-- Set up our view for drawing to the texture
	render.PushRenderTarget( RTTexture )
	cam.Start2D()
		-- Background
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( txBackground )
		surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )
		surface.SetFont(currentFont)
        --print(currentFont)
		DrawScrollingText( "Remover" , 104, TEX_SIZE )

	cam.End2D()
	render.PopRenderTarget()

end
end
local Check=function(ent)
    if(not ent)then return end
    return ent:GetClass()=="gmod___toolgun" or (ent:IsPlayer() and ent:GetActiveWeapon() and ent:GetActiveWeapon():IsValid() and ent:GetActiveWeapon():GetClass()=="gmod___toolgun")
end
local DonotRemove={
    viewmodel=true,
    beam=true,
    env_laserdot=true,
    info_player_start=true,
    env_spritetrail=true,
    predicted_viewmodel=true,
    func_precipitation=true
}
local toolsound=Sound( "Airboat.FireGunRevDown" )
hook_add("KeyPress","Real-ToolGun Remover attack",function(p,k)
    if(not IsFirstTimePredicted())then return end
    --print("E!!")
    if(Check(p) and k==IN_ATTACK)then
        --print("E!!")
        local wep=p:GetActiveWeapon()
        wep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        local owner = p
        oldemt.EmitSound(wep,toolsound)
        wep:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) -- View model animation

        -- There's a bug with the model that's causing a muzzle to
        -- appear on everyone's screen when we fire this animation.
        owner:SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation

        --if ( not IsFirstTimePredicted() ) then return end
        if ( GetConVarNumber( "gmod_drawtooleffects" ) == 0 ) then return end

        local effectdata = EffectData()
        effectdata:SetOrigin( owner:GetShootPos()+owner:GetAimVector()*5000 )
        effectdata:SetStart( owner:GetShootPos() )
        effectdata:SetAttachment( 1 )
        effectdata:SetEntity( wep )
        util.Effect( "ToolTracer", effectdata )
        local box=Vector(20,20,20)
        local tr=owner:GetEyeTrace()
        if(SERVER)then
            for i,v in pairs(es.FindAlongRay(owner:GetShootPos(),tr.HitPos,-box,box))do
                if(not v)then continue end
                if(not ISV(v))then continue end
                if(v==owner)then continue end
                if(v==wep)then continue end
                if(DonotRemove[oldemt.GetClass(v)])then continue end
                if(oldemt.GetClass(v)=="player")then
                    oldpmt.KillSilent(v)
                else
                    oldemt.StopThinking(v)
                    pcall(function()
                        for i,e in pairs(oldemt.GetTable(v))do
                            oldemt.SetVar(v,i,nil)
                        end
                    end)
                    HookFucker('EntityRemoved',function(e)
                        if(e==v)then
                            return true
                        end
                    end)
                    v.OnRemove=function() end
                    for i=1,8 do
                        pcall(function()
                            oldemt.Remove(v)
                            oldemt.DeleteOnRemove(v,v)
                            oldemt.SuperRemove(v)
                        end)
                    end
                    hook.Call( "OnNPCKilled", GAMEMODE,v,owner,owner)
                end
            end
        end
    end
end)