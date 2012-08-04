//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSSnipingEnemySpawner extends Actor
	placeable;

// Mostly the same as IMSShootingEnemySpawner, see there for explanation
function PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnTimer();
}


function SpawnSnipingEnemies()
{
	local IMSPlayerController PC;
	
	PC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
	
	if(IMSGame(WorldInfo.Game).AliveSnipingEnemyCount < 1 && abs(VSize(PC.Pawn.Location - self.Location)) > 700 && PC.IsDead() == false)
	{
		Spawn(class'IMSSnipingEnemy',,,self.Location);
		AddDefaultInventory();
	}
}


function SpawnTimer()
{
	SetTimer(5, true, 'SpawnSnipingEnemies');
}

function AddDefaultInventory()
{ 
	local Weapon DefaultPrimaryWeapon;
	local IMSSnipingAI C;
	
	foreach WorldInfo.AllControllers(class'IMSSnipingAI', C)
	{
		DefaultPrimaryWeapon = Spawn(class'IMSEnemySniperRifle',,,C.Pawn.Location);

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