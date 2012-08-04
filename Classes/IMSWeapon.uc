//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSWeapon extends Weapon;

var ParticleSystemComponent MuzzleFlash;
var ParticleSystem RegularMuzzleFlash, SuperMuzzleFlash;
var name MuzzleFlashSocket;
var float MuzzleFlashDuration;
var	array<SoundCue>	WeaponFireSnd;

var bool bMuzzleFlashAttached;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

// Overridden so the Player cannot aim up or down
simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
		SpawnedProjectile.Damage += IMSPlayerController(WorldInfo.GetALocalPlayerController()).Level;
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			// *** This is where we override the up/down aiming
			AimDir.Z = 0;
			SpawnedProjectile.Init( AimDir );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}


simulated function AttachToPawn(Pawn newPawn)
{
	local IMSPawn IMSPawn;

	if (Mesh != none && NewPawn != none && NewPawn.Mesh != None)
	{
		IMSPawn = IMSPawn(NewPawn);
		
		if (IMSPawn != None && IMSPawn.Mesh.GetSocketByName(IMSPawn.WeaponSocket) != none)
		{
		IMSPawn.Mesh.AttachComponentToSocket(Mesh, IMSPawn.WeaponSocket);
		Mesh.SetShadowParent(IMSPawn.Mesh);
		}
	}
}

simulated function FireAmmunition()
{
	PlayFiringSound();
	super.FireAmmunition();
}

// Play the firing sound, this is not part of the native Weapon class
simulated function PlayFiringSound()
{
		if ( WeaponFireSnd[CurrentFireMode] != None )
		{
			MakeNoise(1.0);
			self.PlaySound(WeaponFireSnd[CurrentFireMode],,,, self.Location);
	}
}

simulated event vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	local SkeletalMeshComponent WMesh;
	local SkeletalMeshSocket FSocket;
	local vector SocketLocation;
	
	WMesh = SkeletalMeshComponent(Mesh);
	
	if (WMesh != none)
	{
		FSocket = WMesh.GetSocketByName('MuzzleFlashSocket');
		
		if (FSocket != none)
		{
			WMesh.GetSocketWorldLocationAndRotation('MuzzleFlashSocket', SocketLocation);
			return SocketLocation;
		}
	}
}

simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	CauseMuzzleFlash();
}

simulated function StopFireEffects(byte FireModeNum)
{
	StopMuzzleFlash();
}

simulated event CauseMuzzleFlash()
{
	local ParticleSystem MuzzleTemplate;
	
	if (Instigator != None && SuperMuzzleFlash != None)
	{
		if ( !bMuzzleFlashAttached )
		{
			AttachMuzzleFlash();
		}
		if (MuzzleFlash != None)
		{
			if (!MuzzleFlash.bIsActive || MuzzleFlash.bWasDeactivated)
			{
				// If the player is in rage mode, play the "supermuzzleflash"
				if (IMSPlayerController(WorldInfo.GetALocalPlayerController()).bRageMode == true)
				{
					MuzzleTemplate = SuperMuzzleFlash;
				}
				// Otherwise play the regular one
				else if (MuzzleFlash != None)
				{
					MuzzleTemplate = RegularMuzzleFlash;
				}
				if (MuzzleTemplate != MuzzleFlash.Template)
				{
					MuzzleFlash.SetTemplate(MuzzleTemplate);
				}
				MuzzleFlash.ActivateSystem();
			}
		}

		// Set when to turn it off.
		SetTimer(MuzzleFlashDuration,false,'MuzzleFlashTimer');
	}
}

simulated event MuzzleFlashTimer()
{
	if (MuzzleFlash != none)
	{
		MuzzleFlash.DeactivateSystem();
	}
}

simulated event StopMuzzleFlash()
{
	ClearTimer('MuzzleFlashTimer');
	MuzzleFlashTimer();

	if ( MuzzleFlash != none )
	{
		MuzzleFlash.DeactivateSystem();
	}
}

simulated function AttachMuzzleFlash()
{
	local SkeletalMeshComponent WMesh;

	// Attach the Muzzle Flash
	bMuzzleFlashAttached = true;
	WMesh = SkeletalMeshComponent(Mesh);
	
	if (WMesh != none)
	{
		if ((RegularMuzzleFlash != none) || (SuperMuzzleFlash != none) )
		{
			MuzzleFlash = new(Outer) class'ParticleSystemComponent';
			MuzzleFlash.bAutoActivate = false;
			MuzzleFlash.SetDepthPriorityGroup(SDPG_Foreground);
			WMesh.AttachComponentToSocket(MuzzleFlash, MuzzleFlashSocket);
		}
	}
}

state WeaponEquipping
{
	simulated function WeaponEquipped()
	{
		AttachToPawn(Instigator);
		GotoState('Active');
	}
}
		
defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bAcceptsDynamicDecals=false
		CastShadow=true
		bCastDynamicShadow=true
	End Object

	Mesh=MySkeletalMeshComponent
	Components.Add(MySkeletalMeshComponent);
	
	FiringStatesArray(0)=WeaponFiring
	MuzzleFlashSocket=MuzzleFlashSocket
}