//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSGame extends FrameworkGame;

// Scoring relevant
var int CurrentScore, SavedCurrentScore, HighScore;

// Elapsed PlayTime, relevant for the scoring system
var int PlayTime;

// Number of shooting enemies alive
var int AliveShootingEnemyCount;

// Number of sniping enemies alive
var int AliveSnipingEnemyCount;

// Health Pickup has been spawned
var bool bHealthPickupIsAlive;

// Rage Pickup has been spawned
var bool bRagePickupIsAlive;

// Should we draw the final scoring screen?
var bool bDrawFinalScores;

var IMSSave Save;

var IMSPawn P;

var IMSPlayerController PC;

var string MapName;

// Are we in the main menu?
var bool bIsInMainMenu;

function PostBeginPlay()
{
	// Initialize our Save class
	Save = new class'IMSSave';
	
	// Get the mapname, if it's our "main menu" map, we set bIsInMainMenu to true
	MapName = WorldInfo.GetMapName();
	
	if(MapName == "mobile_map_mainscreen")
	{
		bIsInMainMenu = true;
	}
	
	// Always load the scores
	LoadScores();
	
	super.PostBeginPlay();
}

function GameTimers()
{
	SetTimer(10.0, true, 'IncreasePlayTime');
	
	// Save certain player values every few seconds in case the device crashes, the player exits the game etc.
	// This requires quite some computing time
	
	SetTimer(2.5, true, 'SavePlayerVars');
}

function IncreasePlayTime()
{
	// Unless the player is in the main menu, increase the playtime 10, called every 10 seconds
	
	if (!bIsInMainMenu)
	{
		PlayTime += 10;
	}
}

// Called by PlayDying() on the Pawn
function GameOver()
{
	local IMSShootingEnemy IMSShootingEnemy;
	local IMSSnipingEnemy IMSSnipingEnemy;
	
	if(IMSPlayerController(WorldInfo.GetALocalPlayerController()).IsDead() == true)
	{
		// Save the last score the player had
		SavedCurrentScore = CurrentScore;
		
		CompareScores();
		SaveScores();
		
		// Kill every shooting enemy
		foreach WorldInfo.AllPawns(class'IMSShootingEnemy', IMSShootingEnemy)
		{
			IMSShootingEnemy.Destroy();
		}
		
		// Set the number of shooting enemies alive to 0
		AliveShootingEnemyCount = 0;
	
		// Kill every sniping enemy
		foreach WorldInfo.AllPawns(class'IMSSnipingEnemy', IMSSnipingEnemy)
		{
			IMSSnipingEnemy.Destroy();
		}
		
		// Set the number of alive sniping enemies to 0
		AliveSnipingEnemyCount = 0;
		
		ResetAll();
		
		// In 5 Seconds, draw the final scoring screen
		SetTimer(5,,'DrawFinalScores');
		
		// In 10 seconds, reset the game
		SetTimer(10,,'ResetGame');
		
		IMSPlayerController(WorldInfo.GetALocalPlayerController()).AdManager.ShowBanner(true);
	}
}

function ResetGame()
{
	bDrawFinalScores = false;
	
	IMSPlayerController(WorldInfo.GetALocalPlayerController()).AdManager.HideBanner();
	
	RestartPlayer(IMSPlayerController(WorldInfo.GetALocalPlayerController()));
	
	// If the player was in rage mode by the time he died, get him back to normal mode
	
	if(IMSPlayerController(WorldInfo.GetALocalPlayerController()).bRageMode == true)
	{
		IMSPlayerController(WorldInfo.GetALocalPlayerController()).NormalMode();
	}
}

function DrawFinalScores()
{
	// Draw the final scores
	bDrawFinalScores = true;
}

function CompareScores()
{
	// If the player's current score is higher than the highest score, set the new HighScore
	if(SavedCurrentScore > HighScore)
	{
		HighScore = SavedCurrentScore;
	}
}

function SaveScores()
{	
	// Save scoring values to our IMSSave object
	Save.SaveCurrentScore = CurrentScore;
	Save.SaveHighScore = HighScore;
	Save.SavePlayTime = PlayTime;
	
	class'Engine'.static.BasicSaveObject(Save, "GameState.bin", true, 1);
}

function SavePlayerLevelVars()
{		
	PC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
	
	// Save values relevant to the player level to our IMSSave object unless the player is in the main menu
	if(IMSPawn(PC.Pawn) != none && !bIsInMainMenu)
	{
		Save.SaveHealthMax = IMSPawn(PC.Pawn).HealthMax;
		Save.SaveShieldAmountMax = IMSPawn(PC.Pawn).ShieldAmountMax;
		Save.SaveDamageModifier = IMSPawn(PC.Pawn).DamageModifier;
		
		Save.SaveDamageMultiplier = PC.XP_DamageMultiplier;
		Save.SaveLevel = PC.Level;
		Save.SaveNextLevelXP = PC.NextLevelXP;
	
		class'Engine'.static.BasicSaveObject(Save, "GameState.bin", true, 1);
	}
}

function SavePlayerVars()
{
	PC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
	
	// Save general player values to our IMSSave object unless the player is in the main menu
	if(IMSPawn(PC.Pawn) != none && !bIsInMainMenu)
	{
		
		Save.SaveHealth = IMSPawn(PC.Pawn).Health;
		Save.SaveShieldAmount = IMSPawn(PC.Pawn).ShieldAmount;
		
		Save.SavePlayerLocation = IMSPawn(PC.Pawn).Location;
		Save.SavePlayerRotation = IMSPawn(PC.Pawn).Rotation;
		
		Save.SaveXP = PC.XP;
		Save.SaveRageAmount = PC.RageAmount;
	
		class'Engine'.static.BasicSaveObject(Save, "GameState.bin", true, 1);
	}
}

function LoadScores()
{
	// Loadan' scores
	if(class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1))
	{
		class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1);
	
		PlayTime = Save.SavePlayTime;
		CurrentScore = Save.SaveCurrentScore;
		HighScore = Save.SaveHighScore;
	}
}

function LoadPlayerLevelVars()
{
	if(class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1))
	{
		PC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
		
		// Load our player level values and set them to the player's pawn and playercontroller unless he is in the main menu
		if(IMSPawn(PC.Pawn) != none && !bIsInMainMenu)
		{
			class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1);
	
			IMSPawn(PC.Pawn).HealthMax = Save.SaveHealthMax;
			IMSPawn(PC.Pawn).ShieldAmountMax = Save.SaveShieldAmountMax;
			IMSPawn(PC.Pawn).DamageModifier = Save.SaveDamageModifier;

			PC.XP_DamageMultiplier = Save.SaveDamageMultiplier;
			PC.Level = Save.SaveLevel;
			PC.NextLevelXP = Save.SaveNextLevelXP;
		}
	}
}

function LoadPlayerVars()
{
	if(class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1))
	{
		PC = IMSPlayerController(WorldInfo.GetALocalPlayerController());
		
		// Load our general player values and set them to the player's pawn and playercontroller unless he is in the main menu
		if(IMSPawn(PC.Pawn) != none && !bIsInMainMenu)
		{
			class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1);

			IMSPawn(PC.Pawn).Health = Save.SaveHealth;
			IMSPawn(PC.Pawn).ShieldAmount = Save.SaveShieldAmount;
			
			IMSPawn(PC.Pawn).SetLocation(Save.SavePlayerLocation);
			IMSPawn(PC.Pawn).SetRotation(Save.SavePlayerRotation);
			
			PC.XP = Save.SaveXP;
			PC.RageAmount = Save.SaveRageAmount;
		}
	}
}

function ResetAll()
{
	// Set every value back to their defaults
	
	if(class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1))
	{
		class'Engine'.static.BasicLoadObject(Save, "GameState.bin", true, 1);
	
		CurrentScore = 0;
		Save.SavePlayTime = 0;
		Save.SaveCurrentScore = 0;
		Save.SaveHealthMax = 100;
		Save.SaveShieldAmountMax = 100;
		Save.SaveDamageModifier = 1;
		Save.SaveDamageMultiplier = 1;
		Save.SaveLevel = 1;
		Save.SaveNextLevelXP = 1000;
		Save.SaveXP = 0;
		Save.SaveHealth = 100;
		Save.SaveShieldAmount = 100;
		Save.SavePlayerLocation = Vect(0, 0, 32);
		Save.SavePlayerRotation = Rot(0, 0, 0);
		Save.SaveRageAmount = 0;
	
	class'Engine'.static.BasicSaveObject(Save, "GameState.bin", true, 1);
	}
}

defaultproperties
{
 	PlayerControllerClass=class'IMS.IMSPlayerController'
 	DefaultPawnClass=class'IMS.IMSPawn'
	HUDType=class'IMS.IMSHUD'
 	bWaitingToStartMatch=true
 	bDelayedStart=false
	bRestartLevel=false
}