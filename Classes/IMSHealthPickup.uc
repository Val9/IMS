//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSHealthPickup extends Pawn
	placeable;

function PostBeginPlay()
{
	// If the pickup is spawned, make sure it cannot be spawned again
	IMSGame(WorldInfo.Game).bHealthPickupIsAlive = true;
	// Play the spinning animation
	Mesh.PlayAnim('sk_pickup_idle',, true, true);
	
	// If the pickup isn't picked up within 10 seconds, destroy it
	SetTimer(10, false, 'DestroyPickup');
	super.PostBeginPlay();
}

function DestroyPickup()
{
		IMSGame(WorldInfo.Game).bHealthPickupIsAlive = false;
		Destroy();
}

auto state Idle
{
	ignores TakeDamage;
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	// Make sure on the player can use this pickup
	if (Pawn(Other) == IMSPawn(Pawn(Other)))
	{
		self.PlaySound(SoundCue'mobile_assets_scifi.A_Powerup_Berzerk_PickupCue',,,, self.Location);
		// Increase the player health by 25%
		IMSPawn(Pawn(Other)).Health += IMSPawn(Pawn(Other)).HealthMax * 0.25;
		
		// Make sure the player Health doesn't go above his maximum health
		if (IMSPawn(Pawn(Other)).Health > IMSPawn(Pawn(Other)).HealthMax)
		{
			IMSPawn(Pawn(Other)).Health = Clamp(IMSPawn(Pawn(Other)).Health, 0, IMSPawn(Pawn(Other)).HealthMax);
		}
		
		// Destry the pickup
		IMSGame(WorldInfo.Game).bHealthPickupIsAlive = false;
		Destroy();
	}
}

defaultproperties
{
	Begin Object Class=AnimNodeSequence Name=InitialPickupAnim
	End Object
	
	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
  	BlockRigidBody=false;
 		CollideActors=true;
  	BlockZeroExtent=false;

	Animations=InitialPickupAnim
	
	AnimSets(0)=AnimSet'mobile_assets_scifi.sk_pickup_animset'
	PhysicsAsset=PhysicsAsset'mobile_assets_scifi.sk_healthpickup_physics'
  SkeletalMesh=SkeletalMesh'mobile_assets_scifi.sk_healthpickup'
 	
	End Object
	Mesh=InitialSkeletalMesh;
	
	Components.Add(InitialSkeletalMesh);
	
	CollisionType=COLLIDE_NoCollision
	bNoEncroachCheck=true
  
	Begin Object Name=CollisionCylinder
		CollisionRadius=0064.000000
    CollisionHeight=0128.000000
	End Object
    
	CylinderComponent=CollisionCylinder
}
	
