
SetWeaponSound( "fire", "Weapon_r1357.Single" )
PrecacheWeaponAssets()

// sets the RSPN-101 color to red, remove when using different model
self.SetWeaponSkin( 2 )

const OVERLAY_THINK_ID = "CancelOverlayAction"
const OVERLAY_FADE_DURATION = 1.0
RegisterSignal( OVERLAY_THINK_ID )

last_adsVal <- false
last_adsValChangeTime <- null
last_adsFrac <- 0.0
last_adsFracAtTransition <- 0.0

function OnWeaponActivate( activateParams )
{
	OverlayThinkStart()
}

function OnWeaponDeactivate( deactivateParams )
{
	OverlayThinkStop()
}

function OnWeaponPrimaryAttack( attackParams )
{
	PlayWeaponSound( "fire" )
	self.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS, 0.2 )
	self.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, 0 )
}

function OnClientAnimEvent( name )
{	
}

function ScopeOverlay_Think()
{
	local player = self.GetWeaponOwner()
	Signal( self, OVERLAY_THINK_ID )
	EndSignal( self, OVERLAY_THINK_ID )
	EndSignal( player, "OnDeath" )
	
	local frac
	
	while(1)
	{
		frac = player.GetAdsFraction()
		Overlay_Show( frac )
		Wait(0)	
	}
}

function Overlay_Show( alpha )
{	
	Hud.Show( "WeaponScope8x" )
	Hud.Show( "WeaponScopeSizeBarLeft" )
	Hud.Show( "WeaponScopeSizeBarRight" )
	
	Hud.SetColor( "WeaponScope8x", 255, 255, 255, 255 * alpha )
	Hud.SetColor( "WeaponScopeSizeBarLeft", 255, 255, 255, 255 * alpha )
	Hud.SetColor( "WeaponScopeSizeBarRight", 255, 255, 255, 255 * alpha )
}

function Overlay_Hide()
{
	Hud.Hide( "WeaponScope8x" )
	Hud.Hide( "WeaponScopeSizeBarLeft" )
	Hud.Hide( "WeaponScopeSizeBarRight" )
}

function OverlayThinkStart()
{
	if ( IsServer() )
		return
	
	local player = self.GetWeaponOwner()
	if ( !player )
		return
	if ( !player.IsPlayer() )
		return
	
	thread ScopeOverlay_Think()
}

function OverlayThinkStop()
{
	if ( IsServer() )
		return
	
	Signal( self, OVERLAY_THINK_ID )
	Overlay_Hide()
}