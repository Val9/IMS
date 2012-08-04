//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSEnemyPulseRifleProjectile extends IMSEnemyProjectile;

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'mobile_assets_scifi.fx_gunfire_p'
	ImpactSound=SoundCue'mobile_assets_scifi.A_Weapon_Link_ImpactCue'
	Damage = 2
}