//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSRagePickup extends Pawn
	placeable;

// See IMSHealthPickup

function PostBeginPlay()
{
	IMSGame(WorldInfo.Game).bRagePickupIsAlive = true;
	Mesh.PlayAnim('sk_pickup_idle',, true, true);
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
	local IMSPlayerController IMSPC;
	IMSPC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
		
	if (Pawn(Other) == IMSPawn(Pawn(Other)))
	{
		self.PlaySound(SoundCue'mobile_assets_scifi.A_Powerup_Berzerk_PickupCue',,,, self.Location);
		
		IMSPC.RageAmount += 100;
		IMSPC.CheckForRageMode();
		
		if (IMSPC.RageAmount > 100)
		{
			IMSPC.RageAmount = Clamp(IMSPC.RageAmount, 0, 100);
		}
		
		IMSGame(WorldInfo.Game).bRagePickupIsAlive = false;
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
  SkeletalMesh=SkeletalMesh'mobile_assets_scifi.sk_powerpickup'
 	
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
	
