
class KOTWHelm_Base extends CItemEntity
{
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var helmCap : SItemUniqueId;
		var hairIds : array<SItemUniqueId>;
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		var hasHelm : bool;
		var i : int;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		helmCap = inv.GetItemId( 'kotw_helm_cap' );
		hairIds = inv.GetItemsByCategory( 'hair' );
		hasHelm = inv.HasItem( 'kotw_helm_cap' );
		
		witcher.RemoveAbilityAll('HelmetArmor');
		witcher.AddAbilityMultiple( 'HelmetArmor', witcher.GetLevel() );
		
		if( hasHelm )
		{
			for(i=0; i<hairIds.Size(); i+=1)
				inv.UnmountItem( hairIds[i] );
			inv.MountItem( helmCap );
		}
		else kotwAddAndEquipItem( 'kotw_helm_cap', witcher );
		
		if( !FactsDoesExist('hair_removed') )
			FactsAdd( "hair_removed", 1, -1 );
	}
}

class KOTWHelm_V1_1 extends W3QuestUsableItem
{
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		witcher.RemoveAbilityAll('HelmetArmor');
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
			witcher.inv.RemoveItem( ids[i] );
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isHelmEquipped : bool;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_helm_v1_1' );
		visorUp = inv.GetItemId( 'kotw_visor_v1_1a' );
		visorDown = inv.GetItemId( 'kotw_visor_v1_1' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isVisorUp = inv.IsItemMounted( visorUp );
		isVisorDown = inv.IsItemMounted( visorDown );
		
		super.OnUsed(usedBy);
		
		if( !isHelmEquipped )
			kotwRemoveHelmItems(witcher);
		
		if( !FactsDoesExist('hair_removed') && !inv.HasItem( 'kotw_helm_v1_1') && !inv.HasItem( 'kotw_visor_v1_1a') && !inv.HasItem( 'kotw_visor_v1_1') )
		{
			kotwAddAndEquipItem( 'kotw_helm_v1_1', witcher );
			kotwAddAndEquipItem( 'kotw_visor_v1_1', witcher );
			inv.AddAnItem( 'kotw_visor_v1_1a', 1);
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isVisorUp && !isVisorDown )
			{
				inv.MountItem( helm );
				inv.MountItem( visorDown );
			}
			else
			if( isHelmEquipped && isVisorDown ) 
			{ 
				inv.UnmountItem( visorDown );
				inv.MountItem( visorUp );
			} 
			else
			if( isHelmEquipped && isVisorUp ) 
			{ 
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

class KOTWHelm_V2_1 extends W3QuestUsableItem
{		
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		witcher.RemoveAbilityAll('HelmetArmor');
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
			witcher.inv.RemoveItem( ids[i] );
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isHelmEquipped : bool;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_helm_v2_1' );
		visorUp = inv.GetItemId( 'kotw_visor_v2_1a' );
		visorDown = inv.GetItemId( 'kotw_visor_v2_1' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isVisorUp = inv.IsItemMounted( visorUp );
		isVisorDown = inv.IsItemMounted( visorDown );
		
		super.OnUsed(usedBy);
		
		if( !isHelmEquipped )
			kotwRemoveHelmItems(witcher);
		
		if( !FactsDoesExist('hair_removed') && !thePlayer.inv.HasItem( 'kotw_helm_v2_1') && !thePlayer.inv.HasItem( 'kotw_visor_v2_1a') && !thePlayer.inv.HasItem( 'kotw_visor_v2_1') )
		{
			kotwAddAndEquipItem( 'kotw_helm_v2_1', witcher );
			kotwAddAndEquipItem( 'kotw_visor_v2_1a', witcher );
			inv.AddAnItem( 'kotw_visor_v2_1', 1);
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isVisorUp && !isVisorDown )
			{
				inv.MountItem( helm );
				inv.MountItem( visorDown );
			}
			else
			if( isHelmEquipped && isVisorDown ) 
			{ 
				inv.UnmountItem( visorDown );
				inv.MountItem( visorUp );
			} 
			else
			if( isHelmEquipped && isVisorUp ) 
			{ 
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

class KOTWHelm_V2_2 extends W3QuestUsableItem
{		
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		witcher.RemoveAbilityAll('HelmetArmor');
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
			witcher.inv.RemoveItem( ids[i] );
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isHelmEquipped : bool;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_helm_v2_2' );
		visorUp = inv.GetItemId( 'kotw_visor_v2_2a' );
		visorDown = inv.GetItemId( 'kotw_visor_v2_2' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isVisorUp = inv.IsItemMounted( visorUp );
		isVisorDown = inv.IsItemMounted( visorDown );
		
		super.OnUsed(usedBy);
		
		if( !isHelmEquipped )
			kotwRemoveHelmItems(witcher);
		
		if( !FactsDoesExist('hair_removed') && !thePlayer.inv.HasItem( 'kotw_helm_v2_2') && !thePlayer.inv.HasItem( 'kotw_visor_v2_2a') && !thePlayer.inv.HasItem( 'kotw_visor_v2_2') )
		{
			kotwAddAndEquipItem( 'kotw_helm_v2_2', witcher );
			kotwAddAndEquipItem( 'kotw_visor_v2_2a', witcher );
			inv.AddAnItem( 'kotw_visor_v2_2', 1);
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isVisorUp && !isVisorDown )
			{
				inv.MountItem( helm );
				inv.MountItem( visorDown );
			}
			else
			if( isHelmEquipped && isVisorDown ) 
			{ 
				inv.UnmountItem( visorDown );
				inv.MountItem( visorUp );
			} 
			else
			if( isHelmEquipped && isVisorUp ) 
			{ 
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

class KOTWHelm_V2_3 extends W3QuestUsableItem
{		
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		witcher.RemoveAbilityAll('HelmetArmor');
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
			witcher.inv.RemoveItem( ids[i] );
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isHelmEquipped : bool;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_helm_v2_3' );
		visorUp = inv.GetItemId( 'kotw_visor_v2_3a' );
		visorDown = inv.GetItemId( 'kotw_visor_v2_3' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isVisorUp = inv.IsItemMounted( visorUp );
		isVisorDown = inv.IsItemMounted( visorDown );
		
		super.OnUsed(usedBy);
		
		if( !isHelmEquipped )
			kotwRemoveHelmItems(witcher);
		
		if( !FactsDoesExist('hair_removed') && !thePlayer.inv.HasItem( 'kotw_helm_v2_3') && !thePlayer.inv.HasItem( 'kotw_visor_v2_3a') && !thePlayer.inv.HasItem( 'kotw_visor_v2_3') )
		{
			kotwAddAndEquipItem( 'kotw_helm_v2_3', witcher );
			kotwAddAndEquipItem( 'kotw_visor_v2_3', witcher );
			inv.AddAnItem( 'kotw_visor_v2_3a', 1);
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isVisorUp && !isVisorDown )
			{
				inv.MountItem( helm );
				inv.MountItem( visorDown );
			}
			else
			if( isHelmEquipped && isVisorDown ) 
			{ 
				inv.UnmountItem( visorDown );
				inv.MountItem( visorUp );
			} 
			else
			if( isHelmEquipped && isVisorUp ) 
			{ 
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

class KOTWHelm_Vampire extends W3QuestUsableItem
{
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		witcher.RemoveAbilityAll('HelmetArmor');
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
			witcher.inv.RemoveItem( ids[i] );
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm, mask : SItemUniqueId;
		var isHelmEquipped : bool;
		var isMaskEquipped : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_vampire_helm' );
		mask = inv.GetItemId( 'kotw_vampire_mask' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isMaskEquipped = inv.IsItemMounted( mask );
		
		super.OnUsed(usedBy);
		
		if( !isHelmEquipped )
			kotwRemoveHelmItems(witcher);
		
		if( !FactsDoesExist('hair_removed') && !inv.HasItem( 'kotw_vampire_helm') && !inv.HasItem( 'kotw_vampire_mask') )
		{
			kotwAddAndEquipItem( 'kotw_vampire_helm', witcher );
			kotwAddAndEquipItem( 'kotw_vampire_mask', witcher );
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isMaskEquipped )
			{
				inv.MountItem( helm );
				inv.MountItem( mask );
			}
			else if( isMaskEquipped && isHelmEquipped ) 
			{ 
				inv.UnmountItem( mask );
			} 
			else if( isHelmEquipped && !isMaskEquipped )
			{
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

exec function kotwResetHelm()
{
	var inv : CInventoryComponent;	
	var i : int;
	var ids : array< SItemUniqueId >;
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
	witcher.RemoveAbilityAll('HelmetArmor');
	FactsRemove( "hair_removed" );
	
	for(i=0; i<ids.Size(); i+= 1)
		witcher.inv.RemoveItem( ids[i] );
}

exec function kotwRemoveAllHair()
{
	var inv : CInventoryComponent;	
	var i : int;
	var ids : array< SItemUniqueId >;
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	ids = witcher.inv.GetItemsByCategory( 'hair' );
	for(i=0; i<ids.Size(); i+= 1)
		witcher.inv.RemoveItem( ids[i] );
}
