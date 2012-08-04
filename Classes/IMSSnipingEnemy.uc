//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSSnipingEnemy extends Pawn
	placeable;

// Mostly the same as IMSShootingEnemy, see there for explanation

var int EnemyXP, EnemyScore;

var name WeaponSocket;

function PostBeginPlay()
{
	SpawnDefaultController();
	IMSGame(WorldInfo.Game).AliveSnipingEnemyCount++;
	super.PostBeginPlay();
}

simulated function SetPawnRBChannels(bool bRagdollMode)
{
	Mesh.SetRBChannel((bRagdollMode) ? RBCC_Pawn : RBCC_Untitled3);
	Mesh.SetRBCollidesWithChannel(RBCC_Default, bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn, bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, !bRagdollMode);
	Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, bRagdollMode);
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local IMSPlayerController IMSPC;
	IMSPC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
	
	self.PlaySound(SoundCue'mobile_assets_scifi.A_Effort_EnigmaMean_Death_Cue',,,, self.Location);
	
	SetTimer(0.1, false, 'SpawnPickUp');
	if (IMSPC != none)
	{
		IMSPC.XP +=  EnemyXP + (50 * IMSPC.Level); // Add Enemy XP
		IMSGame(WorldInfo.Game).AliveSnipingEnemyCount--; // Decrease the AliveShootingEnemy amount bz one
		IMSPC.CheckForLevelUp(); // Check if the Player has leveled up by our XP increase
		IMSPC.CheckForRageMode();
		
		IMSGame(WorldInfo.Game).CurrentScore += EnemyScore + (IMSGame(WorldInfo.Game).PlayTime); // Increase the Playerscore
		 // And finally call the super
		IMSGame(WorldInfo.Game).SaveScores();
	}
	
	super.PlayDying(DamageType, HitLoc);
	
	Mesh.MinDistFactorForKinematicUpdate = 0.0;
	Mesh.ForceSkelUpdate();
	Mesh.SetTickGroup(TG_PostAsyncWork);
	CollisionComponent = Mesh;
	CylinderComponent.SetActorCollision(false, false);
	Mesh.SetActorCollision(true, false);
	Mesh.SetTraceBlocking(true, true);
	SetPawnRBChannels(true);
	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.f;

	if (Mesh.bNotUpdatingKinematicDueToDistance)
	{
		Mesh.UpdateRBBonesFromSpaceBases(true, true);
	}

	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
	Mesh.bUpdateKinematicBonesFromAnimation = false;
	Mesh.WakeRigidBody();

	self.PlaySound(SoundCue'mobile_assets_scifi.A_Character_BodyImpact_BodyFall_Cue',,,, self.Location);
	// Set the actor to automatically destroy in ten seconds.
	LifeSpan = 5.f;
}

function SpawnPickup()
{
	local float PlayerHealth;
	local int PickUpChance, ChoosePickup;
	
	local vector SpawnLocation;
	
	local IMSPlayerController IMSPC;
	
	IMSPC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
	
	PickupChance = Rand(10);
	
	if (PickupChance == 0)
	{
		ChoosePickup = Rand(1);
		PlayerHealth = IMSPC.Pawn.Health / IMSPC.Pawn.HealthMax;
		
		SpawnLocation = self.Location;
		SpawnLocation.Z = self.Location.Z + 32;
		
		// If PlayerHealth is low, alwazs go for the Health Pickup
		if (PlayerHealth < 0.25 && IMSGame(WorldInfo.Game).bHealthPickupIsAlive != true)
			{
				Spawn(class'IMSHealthPickup',,,SpawnLocation); 
			}
		
		// If we roll a HealthPickup, check if the PlayerHealth isn|t full
		if (ChoosePickup == 0 && PlayerHealth != 1 && IMSGame(WorldInfo.Game).bRagePickupIsAlive != true)
			{
				Spawn(class'IMSRagePickup',,,SpawnLocation); 
			}
		
		// If we roll a HealthPickup and the PlayerHealth is full, go for a different Pickup
		if (ChoosePickup == 0 && PlayerHealth == 1 && IMSGame(WorldInfo.Game).bRagePickupIsAlive != true)
			{
				Spawn(class'IMSRagePickup',,,SpawnLocation); 
			}
	}
}

function DisplayHurtMaterial()
{
	self.Mesh.SetMaterial(0, MaterialInterface'mobile_assets_scifi.sk_henemy01_hurt_mat');
	SetTimer(0.1, false, 'ClearOverlayMaterial');
}

function ClearOverlayMaterial()
{
	self.Mesh.SetMaterial(0, MaterialInterface'mobile_assets_scifi.sk_henemy02_mat');
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	DisplayHurtMaterial();
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

State Dying
{
	ignores TakeDamage, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;
}

defaultproperties
{
	Components.Remove(Sprite)
  Begin Object class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
  ModShadowFadeoutTime=0.25
  MinTimeBetweenFullUpdates=0.2
  AmbientGlow=(R=.01,G=.01,B=.01,A=1)
  AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
  bSynthesizeSHLight=TRUE
  End Object
  Components.Add(MyLightEnvironment)

  Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
  CastShadow=true
  bCastDynamicShadow=true
  bOwnerNoSee=false
	bHasPhysicsAssetInstance=true
 	LightEnvironment=MyLightEnvironment;
 	BlockRigidBody=true;
 	CollideActors=true;
	BlockZeroExtent=true;

 	PhysicsAsset=PhysicsAsset'mobile_assets_scifi.sk_henemy01_physics'
 	AnimSets(0)=AnimSet'mobile_assets_scifi.sk_ims_mobilepawn_animset'
 	AnimTreeTemplate=AnimTree'mobile_assets_scifi.sk_ims_mobilepawn_animtree'
 	SkeletalMesh=SkeletalMesh'mobile_assets_scifi.sk_henemy02'
 	End Object

 	Mesh=InitialSkeletalMesh;
 	Components.Add(InitialSkeletalMesh); 


 	CollisionType=COLLIDE_BlockAll
 	Begin Object Name=CollisionCylinder
 	CollisionRadius=0032.000000
 	CollisionHeight=0032.000000
 	End Object
 	CylinderComponent=CollisionCylinder

 	DrawScale = 3.0
 	GroundSpeed = 300
	
	InventoryManagerClass=class'IMS.IMSInventoryManager'
	WeaponSocket=WeaponPoint
	ControllerClass=class'IMS.IMSSnipingAI'
	
	EnemyXP = 300
	EnemyScore = 500
}