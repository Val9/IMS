//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSMainMenuScene extends MobileMenuScene;

var transient WorldInfo	WorldInfo;


event InitMenuScene(MobilePlayerInput PlayerInput, int ScreenWidth, int ScreenHeight, bool bIsFirstInitialization)
{
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	super.InitMenuScene(PlayerInput, ScreenWidth, Screenheight, bIsFirstInitialization);;
}

event OnTouch(MobileMenuObject Sender, ETouchType EventType, float TouchX, float TouchY)
{
	if(Sender == none)
	{
		return;
	}
	
	if(Sender.Tag == "PlayButton")
	{
		IMSGame(WorldInfo.Game).bIsInMainMenu = false;
		// Open the game's map, I have yet to find a different way to do this
		IMSPlayerController(WorldInfo.GetALocalPlayerController()).ConsoleCommand("open mobile_map_scifi");
		InputOwner.CloseMenuScene(self);
	}
	
	if(Sender.Tag == "ResetButton")
	{
		IMSGame(WorldInfo.Game).ResetAll();
	}
} 

defaultproperties
{
  Left=0
  Top=0
  Width=1.0
  Height=1.0
  bRelativeWidth=true
	bRelativeHeight=true
	
Begin Object Class=MobileMenuImage Name=IMSLogo
      Tag="IMSLogo"
      Left=0.125
      Top=0
      Width=0.75
      Height=0.5
			bRelativeLeft=true
      bRelativeWidth=true
      bRelativeHeight=true
      Image=Texture2D'mobile_assets_scifi.ims_mainmenu'
      ImageDrawStyle=IDS_Stretched
      ImageUVs=(bCustomCoords=true,U=0,V=0,UL=1024,VL=512)
   End Object
   MenuObjects.Add(IMSLogo)
	
	Begin Object Class=MobileMenuButton Name=PlayButton
      Tag="PlayButton"
      Left=0.125
      Top=0.75
      Width=128
      Height=64
      bRelativeLeft=true
      bRelativeTop=true
			//bRelativeWidth=true
      //bRelativeHeight=true
     // TopLeeway=20
      Images(0)=Texture2D'mobile_assets_scifi.ims_mainmenu'
      Images(1)=Texture2D'mobile_assets_scifi.ims_mainmenu'
      ImagesUVs(0)=(bCustomCoords=true,U=0,V=512,UL=256,VL=128)
      ImagesUVs(1)=(bCustomCoords=true,U=0,V=640,UL=256,VL=128)
   End Object
   MenuObjects.Add(PlayButton)
	
		Begin Object Class=MobileMenuButton Name=ResetButton
      Tag="ResetButton"
      Left=0.775
      Top=0.75
      Width=128
      Height=64
      bRelativeLeft=true
      bRelativeTop=true
			//bRelativeWidth=true
      //bRelativeHeight=true
     // TopLeeway=20
      Images(0)=Texture2D'mobile_assets_scifi.ims_mainmenu'
      Images(1)=Texture2D'mobile_assets_scifi.ims_mainmenu'
      ImagesUVs(0)=(bCustomCoords=true,U=256,V=512,UL=256,VL=128)
      ImagesUVs(1)=(bCustomCoords=true,U=256,V=640,UL=256,VL=128)
   End Object
   MenuObjects.Add(ResetButton)
}