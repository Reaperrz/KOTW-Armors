class W3Effect_DimeritiumCharge extends CBaseGameplayEffect
{
	private var DimeritiumArmor : kotwArmorSetHandler;
	default effectType = EET_DimeritiumCharge;
	default isPositive = true;
	
	private function CacheObject()
	{
		DimeritiumArmor = kotwArmors();
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		CacheObject();		
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		CacheObject();
	}
	
	public function GetCharge() : int
	{
		return DimeritiumArmor.GetDimeritiumCharge();
	}
	
	public function GetMaxCharge() : int
	{
		return 6;
	}
}

class W3Effect_MeteoriteUpgrade extends CBaseGameplayEffect
{
	private var MeteoriteArmor : kotwArmorSetHandler;
	default effectType = EET_MeteoriteUpgrade;
	default isPositive = true;
	
	private function CacheObject()
	{
		MeteoriteArmor = kotwArmors();
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		CacheObject();		
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		CacheObject();
	}
	
	public function GetUpgradeLevel() : int
	{
		return MeteoriteArmor.GetMeteoriteUpgradeLevel();
	}
	
	public function GetMaxUpgradeLevel() : int
	{
		return 5;
	}
}
