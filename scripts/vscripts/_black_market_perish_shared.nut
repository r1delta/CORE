function main()
{
	Globalize( NewBlackMarketPerishable )
	if ( IsUI() )
	{
		Globalize( GetPerishable )
	}
	else
	{
		Globalize( GetPlayerPerishable )
	}


	if ( IsServer() )
		IncludeFile( "mp/_black_market_perish" )
}

class cBlackMarketPerishable
{
	// same fields as the persistent data
	nextRestockDate = 0
	perishableType	= null
	cardRef 		= null
	coinCost 		= 0
	new 			= false
}

function NewBlackMarketPerishable()
{
	return cBlackMarketPerishable()
}

if ( IsUI() )
{
	function GetPerishable( index )
	{
		local perishable = NewBlackMarketPerishable()
		local prefix = "bm.blackMarketPerishables[" + index + "]"
		perishable.nextRestockDate  = GetPersistentVar( prefix + ".nextRestockDate" )
		perishable.perishableType  	= GetPersistentVar( prefix + ".perishableType" )
		perishable.cardRef  		= GetPersistentVar( prefix + ".cardRef" )
		perishable.coinCost  		= GetPersistentVar( prefix + ".coinCost" )
		perishable.new	  			= GetPersistentVar( prefix + ".new" )
		return perishable
	}
}
else
{
	function GetPlayerPerishable( player, index )
	{
		local perishable = NewBlackMarketPerishable()
		local prefix = "bm.blackMarketPerishables[" + index + "]"
		perishable.nextRestockDate  = player.GetPersistentVar( prefix + ".nextRestockDate" )
		perishable.perishableType  	= player.GetPersistentVar( prefix + ".perishableType" )
		perishable.cardRef  		= player.GetPersistentVar( prefix + ".cardRef" )
		perishable.coinCost  		= player.GetPersistentVar( prefix + ".coinCost" )
		perishable.new	  			= player.GetPersistentVar( prefix + ".new" )
		return perishable
	}
}