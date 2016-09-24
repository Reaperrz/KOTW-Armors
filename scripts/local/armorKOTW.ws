// Enum containing all of the armor set types in the mod.
enum EKotwArmorType
{
	EKAT_Gothic,
	EKAT_Dimeritium,
	EKAT_MeteoriteSilver
}

// Enum containing the infusion types from Dimeritium armor set ability
enum EArmorInfusionType
{
	EAIT_Shock,
	EAIT_Fire,
	EAIT_Ice,
	EAIT_None
}

// Enum containing the cached sign types for meteorite silver plate
enum EMeteoriteSignType
{
	EMST_Yrden,
	EMST_Quen,
	EMST_Igni,
	EMST_Axii,
	EMST_Aard,
	EMST_None
}


// Returns the kotwArmorSetHandler object to use the abilities from and check the values in.
function kotwArmors() : kotwArmorSetHandler
{
	return theGame.kotwArmorHandler;
}


class kotwArmorSetHandler
{
	/*********************************************************
	Armor Counting and Ability Display
	**********************************************************/
	private var kotwArmorCount : array <int>;
	private var currentHelmet : SItemUniqueId;
	
	// Returns the item ID of the currently worn helmet
	public function GetCurrentlyWornHelmet() : SItemUniqueId
	{
		return currentHelmet;
	}
	
	// Saves the currently worn helmet's ID (used to check tags)
	public function SetCurrentlyWornHelmet( itemID : SItemUniqueId )
	{
		currentHelmet = itemID;
	}
	
	// Gets the number of items currently worn by the player of the specified type.
	// The array indexes are in order (so 0 is Gothic Plate, 1 is Dimeritium, etc).
	public function GetArmorSetCount( set : EKotwArmorType ) : int
	{
		return kotwArmorCount[ArmorEnumToID(set)];
	}
	
	// Updates the number of pieces worn of the type of armor that was unequipped / equipped in the inventory.
	// Needs to be added to equipping and unequipping events (also to helmet equipping).
	public function UpdateArmorSetCount( item : SItemUniqueId )
	{
		var setType : EKotwArmorType;
		
		setType = GetSetTypeFromTags(item);
		kotwArmorCount[ArmorEnumToID(setType)] = CountSetPieces(setType);
	}
	
	// Displays a notification on screen when a piece of armor is equipped.
	// First it displays the set's name and the count and then the ability it adds when a full set is present.
	public function DisplaySetSynergyMessage( set : EKotwArmorType )
	{
		theGame.GetGuiManager().ShowNotification( GetNotificationNameBySet(set) + GetArmorSetCount(set) + "/5" +"<br><br>" + GetNotificationTextBySet(set), 6000);
	}
	
	// Counts the number of armor pieces of a specified type that the player is wearing.
	private function CountSetPieces( set : EKotwArmorType ) : int
	{
		var i, pieces : int;
		var inv : CInventoryComponent;
		var witcher : W3PlayerWitcher;
		var items : array<SItemUniqueId>;
		
		pieces = 0;
		items.Resize(5);
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		
		witcher.GetItemEquippedOnSlot(EES_Armor,	 items[0]);
		witcher.GetItemEquippedOnSlot(EES_Boots,	 items[1]);
		witcher.GetItemEquippedOnSlot(EES_Pants,	 items[2]);
		witcher.GetItemEquippedOnSlot(EES_Gloves,	 items[3]);
		items.PushBack( GetCurrentlyWornHelmet() );
		
		for(i=0; i<5; i+=1)
			if( inv.ItemHasTag(items[i], GetTagFromSetType(set)) )
				pieces += 1;
		
		return pieces;
    }
   
	/*********************************************************
	Tag Handling and Localized Text
	**********************************************************/
    // Returns the set type of the item based on the item set tag (the tag has to be BEFORE the last tag in the XML.
    private function GetSetTypeFromTags( item : SItemUniqueId ) : EKotwArmorType
    {
		var itemTags : array <name>;
		var inv : CInventoryComponent;
		
		inv = GetWitcherPlayer().GetInventory();
		inv.GetItemTags(item, itemTags);
		switch( itemTags[itemTags.Size() - 1] )
		{
			case 'GothicSetTag': 		return EKAT_Gothic;
			case 'DimeritiumSetTag': 	return EKAT_Dimeritium;
			case 'MeteoriteSetTag': 	return EKAT_MeteoriteSilver;
		}
    }
    
    // Returns the item set tag based on the item's set type.
    private function GetTagFromSetType( set : EKotwArmorType ) : name
    {
		switch(set)
		{
			case EKAT_Gothic :				return 'GothicSetTag';
			case EKAT_Dimeritium :			return 'DimeritiumSetTag';
			case EKAT_MeteoriteSilver :		return 'MeteoriteSetTag';
		}
    }
    
    // Returns the armor name for the notification message based on the set type.
    private function GetNotificationNameBySet( set : EKotwArmorType ) : string
    {
		switch(set)
		{
			case EKAT_Gothic :				return GetLocStringByKey('GothicNotification');
			case EKAT_Dimeritium :			return GetLocStringByKey('DimeritiumNotification');
			case EKAT_MeteoriteSilver :		return GetLocStringByKey('MeteoriteNotification');
		}
    }
    
    // Returns the armor ability for the notification message based on the set type.
    private function GetNotificationTextBySet( set : EKotwArmorType ) : string
    {
		switch(set)
		{
			case EKAT_Gothic :				return GetLocStringByKey('GothicAbility');
			case EKAT_Dimeritium :			return GetLocStringByKey('DimeritiumAbility');
			case EKAT_MeteoriteSilver :		return GetLocStringByKey('MeteoriteAbility');
		}
    }
    
    // Returns the position of the armor piece count in the array based on the given armor type tag.
    private function ArmorEnumToID( set : EKotwArmorType ) : int
    {
		switch(set)
		{
			case EKAT_Gothic :				return 0;
			case EKAT_Dimeritium :			return 1;
			case EKAT_MeteoriteSilver :		return 2;
		}
    }
    
    // Returns the armor type based on the position in the array.
    private function ArmorIDToEnum( ID : int ) : EKotwArmorType
    {
		switch(ID)
		{
			case 0 :	return EKAT_Gothic;
			case 1 :	return EKAT_Dimeritium;
			case 2 :	return EKAT_MeteoriteSilver;
		}
    }
    
	/*********************************************************
	Set Bonus Abilities
	**********************************************************/
    // - Gothic Set - //
    
    // Makes player immune to staggering while blocking and full set is equipped.
    public function BlockingStaggerImmunity( playerVictim : CR4Player, out action : W3DamageAction, attackAction : W3Action_Attack )
    {
		if( playerVictim && attackAction && attackAction.IsActionMelee() && attackAction.IsParried() && GetArmorSetCount(EKAT_Gothic) == 5 )
			action.SetHitAnimationPlayType(EAHA_ForceNo);
    }
    
    // 50% chance that player will resist stagger on a blockable attack.
    public function AttackStaggerImmunity( playerVictim : CR4Player, out action : W3DamageAction, attackAction : W3Action_Attack )
    {
		if( playerVictim && attackAction && attackAction.CanBeParried() && GetArmorSetCount(EKAT_Gothic) == 5 && RandRange(100,0) > 50 )
			action.SetHitAnimationPlayType(EAHA_ForceNo);
    }
    
    // - Dimeritium Set - //
    
    // Infusion and discharge variables
    private saved var dimeritiumInfusion : EArmorInfusionType;
    private saved var infusionDamage : float;
    private saved var armorCharges : int;
    private var compatibleDamage : name;
    
    // Returns the damage type to be used based on infusion type
    private function InfusionTypeToDamage( infusion : EArmorInfusionType ) : name
    {
		switch(infusion)
		{
			case EAIT_Shock :	return theGame.params.DAMAGE_NAME_SHOCK;
			case EAIT_Fire :	return theGame.params.DAMAGE_NAME_FIRE;
			case EAIT_Ice :		return theGame.params.DAMAGE_NAME_FROST;
		}
    }
    
    // Returns the name of the appropriate visual effect based on infusion type
    private function InfusionTypeToEffect( infusion : EArmorInfusionType ) : name
    {
		switch(infusion)
		{
			case EAIT_Shock :	return 'runeword_yrden';
			case EAIT_Fire :	return 'runeword_igni';
			case EAIT_Ice :		return 'runeword_aard';
		}
    }
    
    // Returns the infusion type to be stored based on the incoming damage type
    private function DamageTypeToInfusion( damageType : name ) : EArmorInfusionType
    {
		switch(damageType)
		{
			case theGame.params.DAMAGE_NAME_ELEMENTAL :	return EAIT_Shock;
			case theGame.params.DAMAGE_NAME_SHOCK :		return EAIT_Shock;
			case theGame.params.DAMAGE_NAME_FIRE :		return EAIT_Fire;
			case theGame.params.DAMAGE_NAME_FROST :		return EAIT_Ice;
			default : return EAIT_None;
		}
    }
    
    // Returns if the incoming damage is magical or not
    private function IsDamageTypeCompatible( action : W3DamageAction ) : bool
    {
		var i, DTCount : int;
		var damages : array <SRawDamage>;
		
		DTCount = action.GetDTs(damages);
		for(i=0; i<DTCount; i+=1)
			switch(damages[i].dmgType)
			{
				case theGame.params.DAMAGE_NAME_ELEMENTAL :	compatibleDamage = damages[i].dmgType; return true;
				case theGame.params.DAMAGE_NAME_SHOCK :		compatibleDamage = damages[i].dmgType; return true;
				case theGame.params.DAMAGE_NAME_FIRE :		compatibleDamage = damages[i].dmgType; return true;
				case theGame.params.DAMAGE_NAME_FROST :		compatibleDamage = damages[i].dmgType; return true;
			}
    }
    
    // Plays the associated effects on the enemy based on infusion type
    private function PlayInfusionHitEffect( type : EArmorInfusionType, victim : CEntity )
    {
		switch(type)
		{
			case EAIT_Shock :
				
			break;
			
			case EAIT_Fire :
				victim.AddTimer('Runeword1DisableFireFX', 1.f);
				victim.PlayEffect('critical_burning');
			break;
			
			case EAIT_Ice :
				
			break;
		}
    }
    
    // Sets the type of stored infusion
    private function SetInfusionType( type : EArmorInfusionType )
    {
		dimeritiumInfusion = type;
    }
    
    // Returns the type of stored infusion
    private function GetInfusionType() : EArmorInfusionType
    {
		return dimeritiumInfusion;
    }
    
    // Returns the damage value of the stored infusion
    private function GetInfusionDamage() : float
    {
		return infusionDamage;
    }
    
    // Quickly applies a custom effect based on some simple parameters
    private function ApplyCustomEffect( creator : CGameplayEntity, victim : CActor, source : string, effect : EEffectType )
    {
		var customEffect : SCustomEffectParams;
		
		customEffect.creator = creator;
		customEffect.sourceName = source;
		customEffect.effectType = effect;
		victim.AddEffectCustom(customEffect);
    }
    
    // Sets the damage type and damage value of the stored infusion based on the incoming attack
    public function SetInfusionVariables( action : W3DamageAction, attackAction : W3Action_Attack )
    {
		var infusionType : EArmorInfusionType;
		
		if( action.attacker && GetArmorSetCount(EKAT_Dimeritium) == 5 && (W3PlayerWitcher)action.victim && action.DealsAnyDamage() && IsDamageTypeCompatible(action) )
		{
			infusionDamage = action.processedDmg.vitalityDamage / 10;
			infusionType = DamageTypeToInfusion(compatibleDamage);
			
			SetInfusionType(infusionType);
			PlayInfusionEffect();
		}
    }
    
    // Deals the appropriate amount and type of damage to an enemy based on stored infusion
    public function DealInfusionDamage( action : W3DamageAction )
    {
		var infusionDamage : W3DamageAction;
		var infusionType : EArmorInfusionType;
		
		infusionType = GetInfusionType();
		if( (W3PlayerWitcher)action.attacker && infusionType != EAIT_None && GetArmorSetCount(EKAT_Dimeritium) == 5 )
		{
			infusionDamage = new W3DamageAction in theGame;
			infusionDamage.Initialize( action.attacker, action.victim, action.causer, action.GetBuffSourceName(), EHRT_None, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
			infusionDamage.SetCannotReturnDamage(true);
			infusionDamage.SetCanPlayHitParticle(false);
			infusionDamage.SetHitAnimationPlayType(EAHA_ForceNo);
			infusionDamage.AddDamage( InfusionTypeToDamage(infusionType), GetInfusionDamage() );
			
			PlayInfusionHitEffect(infusionType, action.victim);
			PlayInfusionSound(infusionType, (CActor)witcher);
			theGame.damageMgr.ProcessAction(infusionDamage);
			RemoveInfusionEffects();
			delete infusionDamage;
		}
    }
    
    // Plays the associated sound effects based on infusion type
    public function PlayInfusionSound( type : EArmorInfusionType, actor : CActor )
    {
		if( GetArmorSetCount(EKAT_Dimeritium) == 5 )
			switch(type)
			{
				case EAIT_Shock :
					actor.SoundEvent('sign_yrden_shock_activate');
				break;
				
				case EAIT_Fire :
					actor.SoundEvent('sign_igni_charge_begin');
				break;
				
				case EAIT_Ice :
					actor.SoundEvent('sign_axii_charge_begin');
				break;
			}
    }
    
    // Removes all infusion visual effects from weapon and removes the saved infusion
    public function RemoveInfusionEffects()
    {
		var items : array<SItemUniqueId>;
		var weapon : CItemEntity;
		var inv : CInventoryComponent;
		
		inv = GetWitcherPlayer().GetInventory();
		items = inv.GetHeldWeapons();
		
		weapon = inv.GetItemEntityUnsafe(items[0]);
		weapon.StopEffect('runeword_aard');
		weapon.StopEffect('runeword_igni');
		weapon.StopEffect('runeword_yrden');
		SetInfusionType(EAIT_None);
    }
    
    // Adds the appropriate infusion's visual effect to the currently equipped weapon
    public function PlayInfusionEffect()
    {
		var items : array<SItemUniqueId>;
		var weapon : CItemEntity;
		var inv : CInventoryComponent;
		var infusionType : EArmorInfusionType;
		
		infusionType = GetInfusionType();
		if( infusionType != EAIT_None && GetArmorSetCount(EKAT_Dimeritium) == 5 )
		{
			inv = GetWitcherPlayer().GetInventory();
			items = inv.GetHeldWeapons();
			
			weapon = inv.GetItemEntityUnsafe(items[0]);
			weapon.PlayEffect( InfusionTypeToEffect(infusionType) );
		}
    }
    
    // Increases the armor's charges when attacked by magic attacks
    public function IncreaseDimeritiumCharge( action : W3DamageAction )
    {
		var witcher : W3PlayerWitcher;
		var healthPerc : float;
		
		witcher = (W3PlayerWitcher)action.victim;
		if( witcher && action.DealsPhysicalOrSilverDamage() && GetArmorSetCount(EKAT_Dimeritium) == 5 && IsDamageTypeCompatible(action) )
		{
			healthPerc = witcher.GetStatMax(BCS_Vitality) / action.processedDmg.vitalityDamage;
			if( healthPerc < 0.25 )
				armorCharges += 1;
			else
			if( healthPerc < 0.55 )
				armorCharges += 2;
			else
				armorCharges += 3;
			
			witcher.PlayEffect('default_fx_bear_abl2');
			ApplyCustomEffect(witcher, (CActor)action.attacker, "DimeritiumRepel", EET_Stagger);
		}
    }
    
    // Returns the amount of charges the armor has
    public function GetDimeritiumCharge() : int
    {
		return armorCharges;
    }
    
    // Discharges the armor when the player is hit and the armor is fully charged
    public function DischargeArmor( action : W3DamageAction )
    {
		var dischargeEffect : W3DamageAction;
		var witcher : W3PlayerWitcher;
		var dischargeDamage : float;
		var actorAttacker : CActor;
		
		witcher = (W3PlayerWitcher)action.victim;
		actorAttacker = (CActor)action.attacker;
		if( witcher && actorAttacker && action.DealsPhysicalOrSilverDamage() && GetArmorSetCount(EKAT_Dimeritium) == 5 && action.IsActionMelee() && GetDimeritiumCharge() >= 6 )
		{	
			if( actorAttacker.UsesVitality() )
				dischargeDamage = actorAttacker.GetStatMax(BCS_Vitality) / 4;
			else
				dischargeDamage = actorAttacker.GetStatMax(BCS_Essence) / 8;
			
			dischargeEffect = new W3DamageAction in theGame.damageMgr;
			dischargeEffect.Initialize( witcher, action.attacker, witcher, 'DimeritiumDischarge', EHRT_Light, CPS_SpellPower, false, true, false, false, 'hit_shock' );	
			dischargeEffect.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, dischargeDamage);
			dischargeEffect.SetCannotReturnDamage(true);
			dischargeEffect.SetCanPlayHitParticle(true);
			dischargeEffect.SetHitAnimationPlayType(EAHA_ForceNo);
			dischargeEffect.SetHitEffect('hit_electric_quen');
			dischargeEffect.SetHitEffect('hit_electric_quen', true);
			dischargeEffect.SetHitEffect('hit_electric_quen', false, true);
			dischargeEffect.SetHitEffect('hit_electric_quen', true, true);
			
			witcher.PlayEffect('quen_force_discharge_bear_abl2_armour');
			witcher.PlayEffect('hit_electric_quen');
			ApplyCustomEffect(witcher, actorAttacker, "DimeritiumDischarge", EET_LongStagger);
			theGame.damageMgr.ProcessAction(dischargeEffect);		
			delete dischargeEffect;
		}
    }
    // - Meteorite Silver Set - //
    
    // Cached sign type and upgrade level variables
    private saved var cachedSignType : EMeteoriteSignType;
    private saved var meteoriteUpgradeLevel : int;

	// Returns the sign type that the meteorite armor is charged with
	private function GetCachedSignType() : EMeteoriteSignType
	{
		return cachedSignType;
	}
	
	// Sets the charged sign type for the armor
	public function SetCachedSignType( sign : name )
	{
		switch(sign)
		{
			case 'Yrden':	cachedSignType = EMST_Yrden;	break;
			case 'Quen':	cachedSignType = EMST_Quen;		break;
			case 'Igni':	cachedSignType = EMST_Igni;		break;
			case 'Axii':	cachedSignType = EMST_Axii;		break;
			case 'Aard':	cachedSignType = EMST_Aard;		break;
		}
	}
	
	// Upgrades the meteorite armor by adding abilities to it
	public function UpgradeMeteoriteArmor( upgradeType : name )
	{
		var i : int;
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		var meteoriteArmors : array <SItemUniqueId>;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		meteoriteArmors = inv.GetItemsByTag('MeteoriteSetTag');
		
		if( GetArmorSetCount(EKAT_MeteoriteSilver) == 5 )
		{
			switch(upgradeType)
			{
				case 'Yrden':
					if( !FactsDoesExist('MeteoriteYrdenUpgrade') )
					{
						meteoriteUpgradeLevel += 1;
						FactsAdd('MeteoriteYrdenUpgrade');
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmorPartWhatever1') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteYrdenUpgrade', false);
					}
				break;
				
				case 'Quen':
					if( !FactsDoesExist('MeteoriteQuenUpgrade') )
					{
						meteoriteUpgradeLevel += 1;
						FactsAdd('MeteoriteQuenUpgrade');
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmorPartWhatever2') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteQuenUpgrade', false);
					}
				break;
				
				case 'Igni':
					if( !FactsDoesExist('MeteoriteIgniUpgrade') )
					{
						meteoriteUpgradeLevel += 1;
						FactsAdd('MeteoriteIgniUpgrade');
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmorPartWhatever3') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteIgniUpgrade', false);
					}
				break;
				
				case 'Axii':
					if( !FactsDoesExist('MeteoriteAxiiUpgrade') )
					{
						meteoriteUpgradeLevel += 1;
						FactsAdd('MeteoriteAxiiUpgrade');
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmorPartWhatever4') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteAxiiUpgrade', false);
					}
				break;
				
				case 'Aard':
					if( !FactsDoesExist('MeteoriteAardUpgrade') )
					{
						meteoriteUpgradeLevel += 1;
						FactsAdd('MeteoriteAardUpgrade');
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmorPartWhatever5') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteAardUpgrade', false);
					}
				break;
			}
		}
	}
	
	// Returns the upgrade level of the meteorite armor
    public function GetMeteoriteUpgradeLevel() : int
    {
		return meteoriteUpgradeLevel;
	}
}

class kotwArmor_v2_1 extends CItemEntity
{
    event OnSpawned( spawnData : SEntitySpawnData )
    {
		super.OnSpawned( spawnData );
        kotwLevelItems();
    }
    
    private function kotwGetItemLevel( item : SItemUniqueId ) : int
    {
		var itemCategory : name;
		var itemAttributes : array<SAbilityAttributeValue>;
		var itemName : name;
		var isWitcherGear : bool;
		var isRelicGear : bool;
		var witcher : W3PlayerWitcher;
		var level, baseLevel, itemQuality : int;
		var inv : CInventoryComponent;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		itemQuality = RoundMath(CalculateAttributeValue( inv.GetItemAttributeValue(item, 'quality' ) ));
		itemCategory = inv.GetItemCategory(item);
		itemName = inv.GetItemName(item);
		
		isWitcherGear = false;
		isRelicGear = false;
		if ( itemQuality == 5 ) isWitcherGear = true;
		if ( itemQuality == 4 ) isRelicGear = true;
		
		switch(itemCategory)
		{
			case 'armor' :
			case 'boots' : 
			case 'gloves' :
			case 'pants' :
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'armor') );
			break;
				
			case 'silversword' :
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'SilverDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'BludgeoningDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'RendingDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'ElementalDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'FireDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'PiercingDamage') );
			break;
				
			case 'steelsword' :
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'SlashingDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'BludgeoningDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'RendingDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'ElementalDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'FireDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'SilverDamage') );
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'PiercingDamage') );
			break;
				
			case 'crossbow' :
				itemAttributes.PushBack( inv.GetItemAttributeValue(item, 'attack_power') );
			break;
				 
			default :
				break;
		}
		
		level = theGame.params.GetItemLevel(itemCategory, itemAttributes, itemName, baseLevel);
		if ( baseLevel > witcher.GetMaxLevel() ) 
			level = baseLevel;

		if ( isWitcherGear ) level = level - 2;
		if ( isRelicGear ) level = level - 1;
		if ( level < 1 ) level = 1;
		
		if ( level > witcher.GetMaxLevel() ) 
			level = witcher.GetMaxLevel();
		
		return level;
    }
	
    private function kotwLevelItems()
    {
        var inv : CInventoryComponent;
        var items : array<SItemUniqueId>;
        var level, i, n, levelDiff : int;
        var itemName, itemCategory, levelAbility : name;
		var itemTags : array <name>;
        var itemAttributes2 : array <SAbilityAttributeValue>;
       
        inv = GetWitcherPlayer().GetInventory();
        items = inv.GetItemsByTag( 'kotwArmor' );
       
        for( n=0; n<items.Size(); n+=1 )
        {
			inv.GetItemTags(items[n], itemTags);
			levelAbility = itemTags[itemTags.Size()];
            itemCategory = inv.GetItemCategory( items[n] );
            itemName = inv.GetItemName(items[n]);
            levelDiff = GetWitcherPlayer().GetLevel() - kotwGetItemLevel(items[n]);
           
            if( levelDiff > 0 )
            {
                switch(itemCategory)
                {
                    case 'armor' :
                        for (i=0; i<levelDiff; i+=1)
						{
                            inv.AddItemCraftedAbility(items[n], 'autogen_fixed_armor_armor', true);
                            inv.AddItemCraftedAbility(items[n], levelAbility, true);
						}
						
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'armor') );
                    break;
                   
                    case 'boots' :
                        for (i=0; i<levelDiff; i+=1)
						{
                            inv.AddItemCraftedAbility(items[n], 'autogen_fixed_pants_armor', true);
                            inv.AddItemCraftedAbility(items[n], levelAbility, true);
						}
						
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'armor') );
                    break;
                   
                    case 'gloves' :
                        for (i=0; i<levelDiff; i+=1)
						{
                            inv.AddItemCraftedAbility(items[n], 'autogen_fixed_gloves_armor', true);
                            inv.AddItemCraftedAbility(items[n], levelAbility, true);
						}
						
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'armor') );
                    break;
                   
                    case 'pants' :
                        for (i=0; i<levelDiff; i+=1)
						{
                            inv.AddItemCraftedAbility(items[n], 'autogen_fixed_pants_armor', true);
                            inv.AddItemCraftedAbility(items[n], levelAbility, true);
						}
						
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'armor') );
                    break;
                   
                    case 'silversword' :
                        for (i=0; i<levelDiff; i+=1)
						{
                            inv.AddItemCraftedAbility(items[n], 'autogen_fixed_silver_dmg', true);
                            inv.AddItemCraftedAbility(items[n], levelAbility, true);
						}
						
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'SilverDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'RendingDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'ElementalDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'FireDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'PiercingDamage') );
                    break;
                   
                    case 'steelsword' :
                        for (i=0; i<levelDiff; i+=1)
						{
                            inv.AddItemCraftedAbility(items[n], 'autogen_fixed_steel_dmg', true);
                            inv.AddItemCraftedAbility(items[n], levelAbility, true);
						}
						
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'SlashingDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'BludgeoningDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'RendingDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'ElementalDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'FireDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'SilverDamage') );
                        itemAttributes2.PushBack( inv.GetItemAttributeValue(items[n], 'PiercingDamage') );
                    break;
                   
                    default : break;
                }
            }
        }
    }
}

exec function kotwAddArmor()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_helm_v1_1_usable' );
	witcher.inv.AddAnItem( 'kotw_armor_v1_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v1_1' );
	witcher.inv.AddAnItem( 'kotw_gloves_v1_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v1_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v1_2' );
	witcher.inv.AddAnItem( 'kotw_boots_v1_2' );
}

exec function kotwAddArmor2()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_helm_v2_3_usable' );
	witcher.inv.AddAnItem( 'kotw_armor_v2_3' );
	witcher.inv.AddAnItem( 'kotw_boots_v2_3' );
	witcher.inv.AddAnItem( 'kotw_gloves_v2_3' );
	witcher.inv.AddAnItem( 'kotw_legs_v2_3' );
	witcher.inv.AddAnItem( 'kotw_legs_v2_3_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v2_3_1' );
}
