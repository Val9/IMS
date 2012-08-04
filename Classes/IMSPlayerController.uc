//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSPlayerController extends GamePlayerController;

var int Level, XP, NextLevelXP;
var float XP_DamageMultiplier;

var bool bRageMode;
var int RageAmount;

var InGameAdManager AdManager;


var MobilePlayerInput MPI;

var MobileInputZone SliderZone;
var MobileInputZone StickMoveZone;
var MobileInputZone StickLookZone;

var vector2D ViewportSize;

var vector PlayerViewOffset;
var rotator CurrentCameraRotation;

simulated function PostBeginPlay()
{	
	// Check if the player can level up - player values are only saved every 2.5 seconds
	// and if some joker exits the game in a certain moment he won't level correctly unless we do this
	CheckForLevelUp();
	
	AdManager = class'PlatformInterfaceBase'.static.GetInGameAdManager();
	
  if (AdManager != none)
  {   
   	AdManager.AddDelegate(AMD_ClickedBanner, OnUserClickedAdvertisement);
   	AdManager.AddDelegate(AMD_UserClosedAd, OnUserClosedAdvertisement);

		AdManager.HideBanner();
	
		if(IMSGame(WorldInfo.Game).bIsInMainMenu == true)
		{
   		AdManager.ShowBanner(true);
		}
	
		if(IMSGame(WorldInfo.Game).bIsInMainMenu == false)
		{
			AdManager.HideBanner();
		}
  }
	
	super.PostBeginPlay();
}

function OnUserClickedAdvertisement(const out PlatformInterfaceDelegateResult Result)
{
   `log("MobilePC::OnUserClickedBanner");
}

event OnUserClosedAdvertisement(const out PlatformInterfaceDelegateResult Result)
{
   `log("MobilePC::OnUserClosedAd");
}

event Destroyed()
{
   super.Destroyed();

   if (AdManager != none)
   {
      AdManager.ClearDelegate(AMD_ClickedBanner, OnUserClickedAdvertisement);
      AdManager.ClearDelegate(AMD_UserClosedAd, OnUserClosedAdvertisement);
   }
}

event InitInputSystem()
{		
	super.InitInputSystem();
	MPI=MobilePlayerInput(PlayerInput);
	
	// If we are in the main menu, open our main menu (DURRR)
	if(IMSGame(WorldInfo.Game).bIsInMainMenu)
	{
		MPI.OpenMenuScene(class'IMS.IMSMainMenuScene');
	}
}

simulated event GetPlayerViewPoint(out vector out_Location, out Rotator out_Rotation)
{
	super.GetPlayerViewpoint(out_Location, out_Rotation);
	
	// If the player isn't in the main menu, set the camera to our bird's eye perspective
	if(Pawn != none && IMSGame(WorldInfo.Game).bIsInMainMenu != true)
	{
		out_Location = Pawn.Location + PlayerViewOffset;
		out_Rotation = rotator(Pawn.Location - out_Location);
	}
	
	CurrentCameraRotation = out_Rotation;
}

function Rotator GetAdjustedAimFor(Weapon W, vector StartFireLoc)
{
	return Pawn.Rotation;
}


// Mobile Input System Setup, copied from SimplePC
function SetupZones()
{
	local float Ratio;
	local float Spacer;

	StickMoveZone = MPI.FindZone("UberStickMoveZone");
	StickLookZone = MPI.FindZone("UberStickLookZone");

	LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);

	Ratio = ViewportSize.Y / ViewportSize.X;

	// The values here were picked after a long process of trail and error.  They basically
	// represent the collective "it feels right".  These work for EpicCitadel.  You will want to
	// choose values that work for you.

	Spacer = (Ratio == 0.75) ? 96 : 64;
	Spacer *= (ViewportSize.X / 1024);

	if (StickMoveZone != none)
	{
		if (Ratio == 0.75)
		{
			StickMoveZone.SizeX = ViewportSize.X * 0.12;
			StickMoveZone.SizeY = StickMoveZone.SizeX;

			StickMoveZone.ActiveSizeX = StickMoveZone.SizeX;
			StickMoveZone.ActiveSizeY = StickMoveZone.SizeY;
		}

		StickMoveZone.SizeX = Spacer + StickMoveZone.SizeX;
		StickMoveZone.SizeY = Spacer + StickMoveZone.SizeY;

		if (Ratio == 0.75) 
		{
			StickMoveZone.SizeY *= 1.5;
		}

		StickMoveZone.X = 0;
		StickMoveZone.Y = ViewportSize.Y - StickMoveZone.SizeY;

		StickMoveZone.CurrentCenter.X = StickMoveZone.X + StickMoveZone.SizeX - (StickMoveZone.ActiveSizeX*0.5); 
		if (Ratio == 0.75)
		{
			StickMoveZone.CurrentCenter.Y = ViewportSize.Y - StickMoveZone.SizeY * 0.33;
		}
		else
		{
			StickMoveZone.CurrentCenter.Y = StickMoveZone.Y + StickMoveZone.ActiveSizeY * 0.5;
		}
		StickMoveZone.CurrentLocation = StickMoveZone.CurrentCenter;
		StickMoveZone.InitialCenter = StickMoveZone.CurrentCenter;
		StickMoveZone.bCenterOnEvent = true;
	}

	if (StickLookZone != none)
	{
		if (Ratio == 0.75)
		{
			StickLookZone.SizeX = ViewportSize.X * 0.12;
			StickLookZone.SizeY = StickLookZone.SizeX;

			StickLookZone.ActiveSizeX = StickLookZone.SizeX;
			StickLookZone.ActiveSizeY = StickLookZone.SizeY;
		}

		StickLookZone.SizeX = Spacer + StickLookZone.SizeX;
		StickLookZone.SizeY = Spacer + StickLookZone.SizeY;
		if (Ratio == 0.75) 
		{
			StickLookZone.SizeY *= 1.5;
		}


		StickLookZone.X = ViewportSize.X - StickLookZone.SizeX;
		StickLookZone.Y = ViewportSize.Y - StickLookZone.SizeY;

		StickLookZone.CurrentCenter.X = StickLookZone.X + (StickLookZone.ActiveSizeX*0.5);
		if (Ratio == 0.75)
		{
			StickLookZone.CurrentCenter.Y = ViewportSize.Y - StickLookZone.SizeY * 0.33;
		}
		else
		{
			StickLookZone.CurrentCenter.Y = StickLookZone.Y + StickLookZone.ActiveSizeY * 0.5;
		}

		StickLookZone.CurrentLocation = StickLookZone.CurrentCenter;
		StickLookZone.InitialCenter = StickLookZone.CurrentCenter;
		StickLookZone.bCenterOnEvent = true;
	}
}

state PlayerWalking
{
	// The left sticks returns values for aForward (X) and aStrafe (Y), the right stick returns
	// values for aLookUp (Y) and aTurn (X). We will use these to create our desired input functionality.
	
	// Link Pawn movement to the left stick within the camera's local space, not the pawn's local space.
	function ProcessMove(float DeltaTime, vector newAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local vector X, Y, Z, StickAccel;
		
		GetAxes(CurrentCameraRotation, X, Y, Z);
		StickAccel = PlayerInput.aForward * Z + PlayerInput.aStrafe * Y;
		StickAccel.Z = 0;
					
		super.ProcessMove(DeltaTime, StickAccel, DoubleClickMove, DeltaRot);
		
		// Check if the player is firing here
		PlayerFire();
	}

	// Link Pawn rotation to the right stick so it always faces the direction of the stick.
	function UpdateRotation(float DeltaTime)
	{
		local vector X, Y, Z;
		local rotator StickRotation;

		GetAxes(CurrentCameraRotation, X, Y, Z);
		StickRotation = rotator(PlayerInput.aLookUp * Z + PlayerInput.aTurn * Y);
	
		if (StickRotation.Yaw != 0)
		Pawn.FaceRotation(StickRotation, DeltaTime);
	}
	
	// Touching the right stick into any direction will make the Player shoot in that direction
	// I used to check for this in PlayerTick(), however the functionality of PlayerTick() changed
	// with the May UDK Beta
	function PlayerFire()
	{		
		if(PlayerInput.aLookUp != 0 || PlayerInput.aTurn != 0) // If the inputvalues in X or Y aren't 0 ...
			{
				self.StartFire(0);
			}
			
		else
			{
				self.StopFire(0);
			}
	}
}

function CheckForLevelUp()
{
	if (XP >= NextLevelXP) // If the Player's current XP is greater thatn the XP required for the next level...
	{
		LevelUp();
	}
}

function LevelUP()
{
	Level++; // Increase the Player Level by one
	
	StatsUp();
	XP -= NextLevelXP; // If XP is greater and not equal to NextXP give the Player the XP overhead
	NextLevelXP = NextLevelXP + 500; // Increase the amount of XP required to level up
}

function StatsUP()
{
	// With every levelup, the player does more damage
	XP_DamageMultiplier += 0.1;
	
	// ... his maximum health increases
	IMSPawn(Pawn).HealthMax += 5;
	
	// ... his health is replenished
	IMSPawn(Pawn).Health = IMSPawn(Pawn).HealthMax;
			
	// ... his maximum shield amount increases
	IMSPawn(Pawn).ShieldAmountMax += 5;
	
	// ... his current shield amount increases depending on how much he has left, if he has any shields left
	if (IMSPawn(Pawn).ShieldAmount != 0)
	{
		IMSPawn(Pawn).ShieldAmount += IMSPawn(Pawn).ShieldAmount * float(IMSPawn(Pawn).ShieldAmount / IMSPawn(Pawn).ShieldAmountMax);
		IMSPawn(Pawn).ShieldAmount = Clamp(IMSPawn(Pawn).ShieldAmount, 0, IMSPawn(Pawn).ShieldAmountMax);
	}
	
	// ... his shields take less damage (but not 0)
	if(IMSPawn(Pawn).DamageModifier >= 0.01)
	{
		IMSPawn(Pawn).DamageModifier -= 0.01;
	}
	
	// ... aaaaaaaaaaand save his level related variables
	IMSGame(WorldInfo.Game).SavePlayerLevelVars();
}

function CheckForRageMode()
{
	// Check if the player has enough rage for rage mode and he is not already in ragemode
	if(RageAmount >=100 && bRageMode != true)
	{
		// Enable rage mode
		RageMode();
		// Draw the rage HUD overlay
		bRageMode = true;
	}
	
	else
	{
		return;
	}
}

function RageMode()
{
// Make the player mode awesomier
if(IMSPawn(Pawn) != none)
{
	IMSPawn(Pawn).GroundSpeed = 750;
	IMSPawn(Pawn).Weapon.Spread[0] = 0;
	IMSWeapon(Pawn.Weapon).FireInterval[0] = IMSWeapon(Pawn.Weapon).FireInterval[0] / 2;
	IMSWeapon(Pawn.Weapon).MuzzleFlashDuration = IMSWeapon(Pawn.Weapon).MuzzleFlashDuration / 2;
	SetTimer(5, false, 'NormalMode');
}
}

function NormalMode()
{
// Return to the default variables
if(IMSPawn(Pawn) != none)
	{
	IMSPawn(Pawn).GroundSpeed = IMSPawn(Pawn).default.GroundSpeed;
	IMSPawn(Pawn).Weapon.Spread[0] = IMSPawn(Pawn).Weapon.default.Spread[0];
	IMSWeapon(Pawn.Weapon).FireInterval[0] =  IMSWeapon(Pawn.Weapon).default.FireInterval[0];
	IMSWeapon(Pawn.Weapon).MuzzleFlashDuration = IMSWeapon(Pawn.Weapon).default.MuzzleFlashDuration;
	bRageMode = false;
	// Set the rage amount back to 0
	RageAmount = 0;
	}
}
		

defaultproperties
{
	PlayerViewOffset=(X=-64, Y=0, Z=750)
	InputClass=class'GameFramework.MobilePlayerInput'
	Level = 1 // Starting level is 1, not 0
	NextLevelXP = 1000
	
	bRageMode = false
	RageAmount = 0
	
	XP_DamageMultiplier = 1
} 