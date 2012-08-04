//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSPawn extends Pawn;

// Weapon socket name
var name WeaponSocket;

// Relevant to the shielding system
var int ShieldAmount, ShieldAmountMax;

// See above
var bool bCanRegenerateShields;

// Are we dead yet?
var bool bHasDied;

// Modifies damage based on the player level
var float DamageModifier;


function PostBeginPlay()
{
	// Unless we are in the main menu
	if(!IMSGame(WorldInfo.Game).bIsInMainMenu)
	{
		//	Enable Regeneration in 5 seconds
		SetTimer(5,, 'EnableRegeneration');
		
		//	The delay on SetStats is necessary because the pawn sometimes just isn't "there" yet
		//	when PostBeginPlay() is called (yes, I'm not kidding) and would return 'none'.
		SetTimer(0.1, false, 'SetStats');
		
		//	Start all the game timers
		IMSGame(WorldInfo.Game).GameTimers();
	}
	super.PostBeginPlay();
}

function SetMeshVisibility(bool bVisible)
{
	Mesh.SetOwnerNoSee(false);
}

function SetStats()
{
	// Initialize and save (just to be sure) all of our player values
	// We do this to be sure that none of the MaxValues are 0 - with a Value / MaxValue 
	// division in the DrawBar() function in IMSHUD we'd get a division by 0 and an infinite
	// bar instead.
	
	IMSGame(WorldInfo.Game).LoadPlayerLevelVars();
	IMSGame(WorldInfo.Game).LoadPlayerVars();
	IMSGame(WorldInfo.Game).SavePlayerLevelVars();
	IMSGame(WorldInfo.Game).SavePlayerVars();
}

function AddDefaultInventory()
{
	local Weapon DefaultPrimaryWeapon;

	// Give the player the default weapon
	DefaultPrimaryWeapon = Spawn(class'IMSPulseRifle',,,self.Location);

	if (DefaultPrimaryWeapon != none && self != none)
	{
		DefaultPrimaryWeapon.GiveTo(self);
		`log("Weapon given to" @ Controller.Pawn);
	}
}

function RegenerateShields()
{
	// If the player's shields aren't full and he can regenerate, increase his shield amount by 1 every tick
	if (ShieldAmount < ShieldAmountMax && bCanRegenerateShields)
	ShieldAmount += 1;
}

function EnableRegeneration()
{
	// Enable shield regeneration
	bCanRegenerateShields = true;
}

function DisplayShieldMaterial()
{
	// Display the shield material when we're hit
	self.Mesh.SetMaterial(0, MaterialInterface'mobile_assets_scifi.sk_ims_mobilepawn_shield_mat');
	
	// Set the pawn material back to default after 0.1 seconds
	SetTimer(0.1, false, 'ClearOverlayMaterial');
}

function DisplayHurtMaterial()
{
	// See above, only that our shields have failed this time
	self.Mesh.SetMaterial(0, MaterialInterface'mobile_assets_scifi.sk_ims_mobilepawn_hurt_mat');
	SetTimer(0.1, false, 'ClearOverlayMaterial');
}

function ClearOverlayMaterial()
{
	self.Mesh.SetMaterial(0, MaterialInterface'mobile_assets_scifi.sk_ims_mobilepawn_mat');
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// If the player isn't in rage mode, increase the player rage amound and see if HE MAD ENOUGH
	if(IMSPlayerController(WorldInfo.GetALocalPlayerController()).bRageMode == false)
	{
		IMSPlayerController(WorldInfo.GetALocalPlayerController()).RageAmount += Damage;
		IMSPlayerController(WorldInfo.GetALocalPlayerController()).CheckForRageMode();
	}
	
	// If the player still has shields left...
	if (ShieldAmount > 0)
	{
		// ... display the shield material when hit
		DisplayShieldMaterial();
		// ... increase damage so the player loses more shields than he would lose health
		// ... the higher your level the less damage your shields will take
		ShieldAmount -= (Damage * 2)*DamageModifier;
		// ... disable shield reneration
		bCanRegenerateShields = false;
		// ... and enable it back again in 5 seconds
		SetTimer(5,, 'EnableRegeneration');
	}
	
	// If the player has no shields left...
	if (ShieldAmount <= 0)
	{
		// ... if the shield amount went negative, clamp it back to 0 - this is just to prevent buggyness on our HUD
		ShieldAmount = Clamp(ShieldAmount, 0, ShieldAmountMax);
		// ... display the damage material
		DisplayHurtMaterial();
		// and call the regular TakeDamage() function so the player takes damage regularly
		super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
}

// Set the pawn to ragdoll mode, copied from UTPawn
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
	super.PlayDying(DamageType, HitLoc);
		
	// HUAAAAAARRRRRRGGGHHHHHH
	self.PlaySound(SoundCue'mobile_assets_scifi.A_Effort_EnigmaMean_Death_Cue',,,, self.Location);
	
	// All ragdoll related, once again copied from UTPawn
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
	
	// Play a falling sound, to make the ragdoll more AWESOME
	self.PlaySound(SoundCue'mobile_assets_scifi.A_Character_BodyImpact_BodyFall_Cue',,,, self.Location);
	// Set the actor to automatically destroy in ten seconds.
	LifeSpan = 10.f;
	
	// Call GameOver in IMSGame
	IMSGame(WorldInfo.Game).GameOver();
}

function Tick(float DeltaTime)
{
	// Regenerate the shields
	RegenerateShields();
	super.Tick(DeltaTime);
}

State Dying
{
	// This is important for our ragdoll system, if we don't ignore TakeDamage, the ragdoll will freeze if it takes damage
	ignores TakeDamage, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;
}

defaultproperties
{
// Components.Remove(Sprite)
	Begin Object class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
 		ModShadowFadeoutTime=0.25
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

  	PhysicsAsset=PhysicsAsset'mobile_assets_scifi.sk_ims_mobilepawn_physics'
   	AnimSets(0)=AnimSet'mobile_assets_scifi.sk_ims_mobilepawn_animset'
   	AnimTreeTemplate=AnimTree'mobile_assets_scifi.sk_ims_mobilepawn_animtree'
   	SkeletalMesh=SkeletalMesh'mobile_assets_scifi.sk_ims_mobilepawn'
 	
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
	GroundSpeed = 500
	bRollToDesired = true
	bCanRegenerateShields = false

	WeaponSocket=WeaponPoint
	InventoryManagerClass=class'IMS.IMSInventoryManager'
	
	ShieldAmount = 100
	ShieldAmountMax = 100
	DamageModifier = 1.0
}