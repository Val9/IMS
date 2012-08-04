//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSHUD extends MobileHUD;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

// Simply draws two recangles
function DrawBar(float Value, float MaxValue, float RelativeX, float RelativeY, int R, int G, int B)
{
	local int PosX, PosY, RectSizeX, RectSizeY;
	local float BarSize;
	
	BarSize = Value / MaxValue;
		
	RectSizeX = 350 * RatioX;
	RectSizeY = 10 * RatioY;
	
	PosX = (SizeX/2) - (RectSizeX/2);
	PosY = RelativeY * SizeY;
	
	Canvas.SetPos(PosX, PosY);
	Canvas.SetDrawColor(R, G, B, 200);
	
// Draws the first rectangle, size is based on how much "Value" you have
	Canvas.DrawRect((RectSizeX * BarSize), RectSizeY);

	Canvas.SetPos(PosX + (RectSizeX * BarSize), PosY);
	Canvas.SetDrawColor(125, 125, 125, 150);

// Draws the second rectangle, size is based on how big "MaxValue - Value" is
	Canvas.DrawRect(RectSizeX - (RectSizeX * BarSize), RectSizeY);
}

// Draws the scoring text
function DrawScore(int PlayerScore, float RelativeX, float RelativeY, int R, int G, int B)
{
	local int PosX, PosY;
	
	// Relative positioning
	PosX = RelativeX * SizeX;
	PosY = RelativeY * SizeY;
	
	Canvas.SetPos(PosX, PosY);
	Canvas.SetDrawColor(R, G, B, 200);
	Canvas.Font=MultiFont'CastleFonts.Positec';
	Canvas.DrawText("Score:" @ PlayerScore);
	
}

// Draws the rage mode overlay
function DrawRageModeOverlay()
{
	local float ScaleFactor;
	local int PosY;
	
	Canvas.SetPos(0, 0);
	Canvas.SetDrawColor(255, 0, 0);
	DrawCenteredText("Rage!", 0.25);
	
	// This is necessary to keep the overlay centered
	PosY = (SizeY - 1024) / 2;
	Canvas.SetPos(0, PosY);
	
	// Scalingfactor is based on the sceen resolution
	ScaleFactor = SizeX / 1024;
	Canvas.SetDrawColor(255, 255, 255);
	Canvas.DrawTextureBlended(Texture2D'mobile_assets_scifi.fx_blood', ScaleFactor, BLEND_Additive);
}

// Well f*** me sideways, a few hours after I came up with this way to center text
// I found our that there's bool bCentered (or something like that) that let's you 
// center text automatically, I still decided to keep this
		
function DrawCenteredText(string Text, float RelativeY)
{
	local float TextSizeX, TextSizeY;
	local int PosX, PosY;
	
	PosX = SizeX / 2;
	PosY = SizeY * RelativeY;
	
	Canvas.TextSize(Text, TextSizeX, TextSizeY);
	Canvas.SetPos(PosX - (TextSizeX / 2), PosY);
	Canvas.Font=MultiFont'CastleFonts.Positec';
	Canvas.DrawText(Text);
}

function DrawEndScore(int Endscore, float RelativeY)
{
	local float TextSizeX, TextSizeY;
	local int PosX, PosY;
	
	PosX = SizeX / 2;
	PosY = SizeY * RelativeY;
	
	Canvas.TextSize(EndScore, TextSizeX, TextSizeY);
	Canvas.SetPos(PosX - (TextSizeX / 2), PosY);
	Canvas.Font=MultiFont'CastleFonts.Positec';
	Canvas.DrawText(EndScore);
}


// Almost identical to DrawRageModeOverlay()
function DrawDeathScreen()
{
	local float ScaleFactor;
	local int PosY;
	
	PosY = (SizeY - 1024) / 2;
	
	Canvas.SetPos(0, PosY);

	ScaleFactor = SizeX / 1024;
	
	Canvas.DrawTextureBlended(Texture2D'mobile_assets_scifi.fx_ragemode', ScaleFactor, BLEND_Additive);
}

// Draw our final scoring hud, pretty self-explanatory
function DrawScoreHud()
{
	Canvas.Reset();
	Canvas.SetPos(0, 0);
	
	Canvas.SetDrawColor(0,0,0);
	Canvas.DrawRect(SizeX, SizeY);
	
	Canvas.SetDrawColor(255,255,255);
	Canvas.Font=MultiFont'CastleFonts.Positec';
	DrawCenteredText("You're dead.", 0.25);
	DrawCenteredText("Your Score is:", 0.40);
	
	Canvas.SetDrawColor(255,0,0);
	DrawEndScore(IMSGame(WorldInfo.Game).SavedCurrentScore, 0.45);
	
	Canvas.SetDrawColor(255,255,255);
	DrawCenteredText("The current Highscore is:", 0.50);
	
	Canvas.SetDrawColor(255,0,0);
	DrawEndScore(IMSGame(WorldInfo.Game).HighScore, 0.55);
	
	Canvas.SetDrawColor(255,255,255);
	DrawCenteredText("Respawning in 5 seconds...", 0.65);
}

// 	DrawHUD() is called every Tick, so I found it easiest to check what and what not to draw 
//	by using booleans
event DrawHUD()
{	
	// Unless the player is dead dead or in the main menu, draw the basic HUD
	if (PlayerOwner.Pawn != none && !PlayerOwner.IsDead() && IMSGame(WorldInfo.Game).bIsInMainMenu != true)
	{
		DrawBar(PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax, 0.33, 0.9, 255, 200, 200);
		DrawBar(IMSPawn(PlayerOwner.Pawn).ShieldAmount, IMSPawn(PlayerOwner.Pawn).ShieldAmountMax, 0.33, 0.875, 200, 200, 255);
		DrawBar(IMSPlayerController(WorldInfo.GetALocalPlayerController()).XP, IMSPlayerController(WorldInfo.GetALocalPlayerController()).NextLevelXP, 0.33, 0.925, 255, 255, 255);
		DrawScore(IMSGame(WorldInfo.Game).CurrentScore, 0.75, 0.075, 255, 255, 255);
		DrawCenteredText("Level:" @ IMSPlayerController(WorldInfo.GetALocalPlayerController()).Level, 0.95);
		
		// If the player is in rage mode, draw the rage overlay
		if (IMSPlayerController(WorldInfo.GetALocalPlayerController()).bRageMode == true)
		{
			DrawRageModeOverlay();
		}
		
		// If the Shields have failed, give the player a visual hint
		if (IMSPawn(PlayerOwner.Pawn).ShieldAmount <= 0)
		{
			DrawCenteredText("Shields failed!", 0.825);
		}
	}
	
	// If the player is dead and bDrawFinalScores is false, draw the death screen
	if(PlayerOwner.IsDead() == true && IMSGame(WorldInfo.Game).bDrawFinalScores == false)
	{
		DrawDeathScreen();
	}
	
	// If the player is dead and bDrawFinalScores is true, draw the final scoring screen
	if(PlayerOwner.IsDead() == true && IMSGame(WorldInfo.Game).bDrawFinalScores == true)
	{
		DrawScoreHud();
	}
	
	super.DrawHUD();
}

defaultproperties
{
	JoystickBackground=Texture2D'MobileResources.T_MobileControls_texture'
	JoystickBackgroundUVs=(U=0,V=0,UL=126,VL=126)
	JoystickHat=Texture2D'MobileResources.T_MobileControls_texture'
	JoystickHatUVs=(U=128,V=0,UL=78,VL=78)

	ButtonImages(0)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonImages(1)=Texture2D'MobileResources.HUD.MobileHUDButton3'
	ButtonUVs(0)=(U=0,V=0,UL=32,VL=32)
	ButtonUVs(1)=(U=0,V=0,UL=32,VL=32)

	TrackballBackground=none
	TrackballTouchIndicator=Texture2D'MobileResources.T_MobileControls_texture'
	TrackballTouchIndicatorUVs=(U=160,V=0,UL=92,VL=92)

	ButtonFont = Font'EngineFonts.SmallFont'
	ButtonCaptionColor=(R=0,G=0,B=0,A=255);
}