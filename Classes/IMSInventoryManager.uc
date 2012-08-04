//=============================================================================
// Copyright 2012 Benjamin Franke
//=============================================================================

class IMSInventoryManager extends InventoryManager;

function PostBeginPlay()
{
	super.PostBeginPlay();
}

defaultproperties
{
		PendingFire(0)=0
}