//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSProjectile extends MobileProjectile;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

// *** Overridden ***
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{

	if( ActorsToIgnoreWhenHit.Find(Other.Class) != INDEX_NONE )
	{
		// The hit actor is one that should be ignored
		return;
	}


	if (DamageRadius > 0.0)
	{
		Explode(HitLocation, HitNormal);
	}
	
	// If the player is in rage mode, the projectile will do massive damage
	else if (IMSPlayerController(WorldInfo.GetALocalPlayerController()).bRageMode == true)
	{
		Damage = Damage * 100;
		
		PlaySound(ImpactSound);
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		Shutdown();
	}
	
	// If the player is in normal mode, the damage is increased a little by the level of the player
	else
	{
		Damage = Damage * IMSPlayerController(WorldInfo.GetALocalPlayerController()).XP_DamageMultiplier;
		
		PlaySound(ImpactSound);
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		Shutdown();
	}
}

defaultproperties
{

}