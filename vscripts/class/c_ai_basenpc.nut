
// function GetDoomedState()
function C_AI_BaseNPC::GetDoomedState()
{
	local soul = this.GetTitanSoul()
	if ( !IsValid( soul ) )
		return 0.0
		
	return soul.IsDoomed();
}