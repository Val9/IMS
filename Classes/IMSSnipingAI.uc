//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSSnipingAI extends AIController;

function PostBeginPlay()
{
	super.PostBeginPlay();
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition); // Posess our Pawn
	Pawn.SetMovementPhysics(); // PHYS_Moving
}

function GetEnemy() // Find something to shoot at, yes that means you!
{
	if(Enemy == none)
 		{
		if(IMSPlayerController(WorldInfo.GetALocalPlayerController()).Pawn != none)
		{
   	 	Enemy = IMSPlayerController(WorldInfo.GetALocalPlayerController()).Pawn;
		}
	}
}

auto state Seeking
 {
Begin:

	GetEnemy();

	if(Enemy != none)
	{
	MoveToward(Enemy, Enemy, 550, true);

	if (VSize(Pawn.Location - Enemy.Location) <= 650)
			GotoState('Shooting');

	else
		goto 'Begin';
	}
}

state Attacking
{

local vector X, Y, Z, XStrafeVector, YStrafeVector;

Begin:

if(Enemy != none)
{

	GetAxes(Pawn.Rotation, X, Y, Z);

//Strafe in Y Direction
if (abs(Enemy.Location.Y - Pawn.Location.Y) < 25 && abs(Enemy.Location.X - Pawn.Location.X) > 25)
{
	YStrafeVector.Y = RandRange(-300, 300);
	MoveTo(Pawn.Location + YStrafeVector, Enemy);
	GotoState('Shooting');
}

// Strafe in X Direction
if (abs(Enemy.Location.X - Pawn.Location.X) < 25 && abs(Enemy.Location.Y - Pawn.Location.Y) > 25)
{
	XStrafeVector.X = RandRange(-300, 300);
	MoveTo(Pawn.Location + XStrafeVector, Enemy);
	GotoState('Shooting');
}

else
	GotoState('Shooting');
}
}

state Shooting
{
	Begin:	
	
	if(Enemy != none)
	{
		Pawn.StartFire(0);

		if (VSize(Pawn.Location - Enemy.Location) <= 650)
		{
			GotoState('Attacking');
		}
		
		else 
			GotoState('Seeking');
	}
}

defaultproperties
{

}