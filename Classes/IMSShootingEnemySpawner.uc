//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSShootingEnemySpawner extends Actor
	placeable;


function PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnTimer();
}


function SpawnShootingEnemies()
{
	local IMSPlayerController PC;
	
	PC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
	
	// If there are less than 3 shooting enemies alive and the player is far enough away from the spawner, spawn the unit and give it the default inventory
	if(IMSGame(WorldInfo.Game).AliveShootingEnemyCount < 3 && abs(VSize(PC.Pawn.Location - self.Location)) > 700 && PC.IsDead() == false)
	{
		Spawn(class'IMSShootingEnemy',,,self.Location);
		AddDefaultInventory();
	}
}

// Spawn a unit every 5 seconds
function SpawnTimer()
{
	SetTimer(5, true, 'SpawnShootingEnemies');
}

function AddDefaultInventory()
{ 
	local Weapon DefaultPrimaryWeapon;
	local IMSShootingAI C;
	
	// Iterating through every ShootingAI Controller
	foreach WorldInfo.AllControllers(class'IMSShootingAI', C)
	{
		DefaultPrimaryWeapon = Spawn(class'IMSEnemyPulseRifle',,,C.Pawn.Location);

		// Give the controller's pawn a weapon unless it already has one
		// This is important, because it seems like pawns can have multiple weapons at the same time
		// giving it a "shotgun"-like effect when firing.
		
		if (DefaultPrimaryWeapon != none && C.Pawn != none && C.Pawn.Weapon == none)
		{
			DefaultPrimaryWeapon.GiveTo(C.Pawn);
		}
	}
}


defaultproperties
{
	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=0.5
		bTreatAsASprite=True
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Arrow)
	
	Begin Object Class=SpriteComponent Name=Sprite
	Sprite=Texture2D'EngineResources.StreamingPauseIcon'
	HiddenGame=true
	HiddenEditor=false
	AlwaysLoadOnClient=False
	AlwaysLoadOnServer=False
 	//Scale=1
	End Object
	
	Components.Add(Sprite)
}
