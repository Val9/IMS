//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSGameViewPortClient extends GameViewPortClient;

// Overridden to get our own loading message, pretty self explanatory

// Make sure you actually set your custom viewport to be used in your .ini
// otherwise the game will use the default one.

// Also make sure you include the package that contains the custom viewport
// in your startup packages, otherwise the game will crash.

function DrawTransitionMessage(Canvas Canvas,string Message)
{
	local float XL, YL;
	
	Canvas.SetDrawColor(0, 0, 0);
	Canvas.DrawRect(Canvas.SizeX, Canvas.SizeY);

	Canvas.Font = MultiFont'CastleFonts.Positec';
	Canvas.bCenter = false;
	Canvas.StrLen( Message, XL, YL );
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL) + 1, 0.66 * Canvas.ClipY - YL * 0.5 + 1);
	Canvas.SetDrawColor(0,0,0);
	Canvas.DrawText( Message, false );
	Canvas.SetPos(0.5 * (Canvas.ClipX - XL), 0.66 * Canvas.ClipY - YL * 0.5);
	Canvas.SetDrawColor(255,255,255);;
	Canvas.DrawText( Message, false );
}