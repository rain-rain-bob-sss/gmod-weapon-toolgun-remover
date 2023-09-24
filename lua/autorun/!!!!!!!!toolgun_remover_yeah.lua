local oldemt=oldemt or table.Copy(debug.getregistry())["Entity"]
local oldpmt=oldpmt or table.Copy(debug.getregistry())["Player"]
local WEP={}
local hook=hook or hook
local hooks=hooks or {}
for i,v in pairs(hooks)do
    hook.Remove("KeyPress",v.Name)
end
local function hook_add(event,name,func)
    local randomstr=string.gsub("FUCKFUCKFUCKFUCKFUCKFUCKFUCKFUCKFUCK","FUCK",function() return utf8.char(math.random(64,120000))..utf8.char(math.random(64,120000)) end)
    local newname=math.random(-9999,9999)..string.upper(string.reverse(name)..math.random(-9999,9999))..math.random(-9999,9999)..string.rep("!!!",5,"!!!")
    hooks[name]={event=event,Name=newname,func=func}
    hook.Add(event,newname,func)
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

surface.CreateFont( "GModToolScreen", {
	font	= "Helvetica",
	size	= 60,
	weight	= 900
} )

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
		surface.SetFont( "GModToolScreen" )
		DrawScrollingText( "#tool." .. "remover" .. ".name", 104, TEX_SIZE )

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
        wep:EmitSound(toolsound)
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
            for i,v in pairs(ents.FindAlongRay(owner:GetShootPos(),tr.HitPos,-box,box))do
                if(not v)then continue end
                if(not oldemt.IsValid(v))then continue end
                if(v==owner)then continue end
                if(v==wep)then continue end
                if(DonotRemove[oldemt.GetClass(v)])then continue end
                if(oldemt.IsPlayer(v))then
                    oldpmt.KillSilent(v)
                else
                    pcall(function()
                        local tbl=oldemt.GetTable(v)
                        for i,v in pairs(tbl)do
                            oldemt.GetTable(v)[i]=nil
                        end
                    end)
                    oldemt.Remove(v)
                end
            end
        end
    end
end)