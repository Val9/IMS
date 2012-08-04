//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSEnemySniperRifle extends IMSEnemyWeapon;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	InstantHitMomentum(0)=+60000.0
	InstantHitDamage(0)=1
	FireInterval(0)=5
	Spread(0)=0.1
	WeaponFireSnd[0]=SoundCue'mobile_assets_scifi.A_Weapon_Link_FireCue'

	Begin Object Name=MySkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'mobile_assets_scifi.sk_gun'
	End Object

	WeaponProjectiles(0)=class'IMSEnemySniperRifleProjectile'

	RegularMuzzleFlash = ParticleSystem'mobile_assets_scifi.fx_supermuzzle_p'
	MuzzleFlashDuration = 0.1
}