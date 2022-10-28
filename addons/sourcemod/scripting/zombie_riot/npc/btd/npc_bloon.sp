#pragma semicolon 1
#pragma newdecls required

//#define FORCE_BLOON_ENABLED

enum
{
	Bloon_Red = 0,
	Bloon_Blue,
	Bloon_Green,
	Bloon_Yellow,
	Bloon_Pink,
	Bloon_Black,
	Bloon_White,
	Bloon_Purple,
	Bloon_Lead,
	Bloon_Zebra,
	Bloon_Rainbow,
	Bloon_Ceramic
}

static const float BloonSpeeds[] =
{
	250.0,
	260.0,
	280.0,
	315.0,
	360.0,	// Pink
	280.0,	// Black
	290.0,	// White
	310.0,	// Purple
	250.0,	// Lead
	280.0,	// Zebra
	295.0,	// Rainbow
	300.0	// Ceramic
};

static const int BloonHealth[] =
{
//	Health	Type		RGB	Multi
	100,	// Red		1
	200,	// Blue		2
	300,	// Green	3
	400,	// Yellow	4
	500,	// Pink		5	x1
	1100,	// Black	11	x6
	1100,	// White	11	x6
	1100,	// Purple	11	x6
	2300,	// Lead		23	x13
	2300,	// Zebra	23	x13
	4700,	// Rainbow	47	x27
	10400	// Ceramic	104	x64
};

static const char Type[] = "12345bwpl789";

static const char SoundPop[][] =
{
	"zombie_riot/btd/pop01.wav",
	"zombie_riot/btd/pop02.wav",
	"zombie_riot/btd/pop03.wav",
	"zombie_riot/btd/pop04.wav"
};

static const char SoundLead[][] =
{
	"zombie_riot/btd/hitmetal01.wav",
	"zombie_riot/btd/hitmetal02.wav",
	"zombie_riot/btd/hitmetal03.wav",
	"zombie_riot/btd/hitmetal04.wav"
};

static const char SoundPurple[][] =
{
	"zombie_riot/btd/hitpurple01.wav",
	"zombie_riot/btd/hitpurple02.wav",
	"zombie_riot/btd/hitpurple03.wav",
	"zombie_riot/btd/hitpurple04.wav"
};

static const char SoundCeramicHit[][] =
{
	"zombie_riot/btd/hitceramic01.wav",
	"zombie_riot/btd/hitceramic02.wav",
	"zombie_riot/btd/hitceramic03.wav",
	"zombie_riot/btd/hitceramic04.wav"
};

static const char SoundCeramicPop[][] =
{
	"zombie_riot/btd/ceramicdestroyed01.wav",
	"zombie_riot/btd/ceramicdestroyed02.wav",
	"zombie_riot/btd/ceramicdestroyed04.wav"
};

static const char BloonSprites[][] =
{
	"red",
	"blue",
	"green",
	"yellow",
	"pink",
	"black",
	"white",
	"purple",
	"lead",
	"zebra",
	"rainbow",
	"ceramic"
};

static int GetBloonTypeOfData(const char[] data, bool &camo, bool &fortified, bool &regrow)
{
	int type;
	for(int i; i<sizeof(Type); i++)
	{
		if(data[0] == Type[i])
		{
			type = i;
			break;
		}
	}
	
	camo = StrContains(data[1], "c") != -1;
	fortified = StrContains(data[1], "f") != -1;
	regrow = StrContains(data[1], "r") != -1;
	return type;
}

static float BloonSpeedMulti()
{
	if(CurrentRound < 80)
		return 1.0;
	
	if(CurrentRound < 100)
		return 1.0 + (CurrentRound - 79) * 0.02;
	
	return 1.0 + (CurrentRound - 70) * 0.02;
}

int Bloon_Health(bool fortified, int type)
{
	if(!fortified)
		return BloonHealth[type];
	
	if(type == Bloon_Lead)
		return (BloonHealth[type] * 4) - BloonHealth[Bloon_Black];
	
	if(type == Bloon_Ceramic)
		return (BloonHealth[type] * 2) - BloonHealth[Bloon_Rainbow];
	
	return BloonHealth[type] * 2;
}

void Bloon_MapStart()
{
	#if defined FORCE_BLOON_ENABLED
	char buffer[256];
	for(int i; i<sizeof(SoundCeramicHit); i++)
	{
		PrecacheSound(SoundCeramicHit[i]);
		FormatEx(buffer, sizeof(buffer), "sound/%s", SoundCeramicHit[i]);
		AddFileToDownloadsTable(buffer);
	}
	for (int i = 0; i < (sizeof(SoundCeramicPop));   i++)
	{
		PrecacheSound(SoundCeramicPop[i]);
		FormatEx(buffer, sizeof(buffer), "sound/%s", SoundCeramicPop[i]);
		AddFileToDownloadsTable(buffer);
	}
	for(int i; i<sizeof(SoundLead); i++)
	{
		PrecacheSound(SoundLead[i]);
		FormatEx(buffer, sizeof(buffer), "sound/%s", SoundLead[i]);
		AddFileToDownloadsTable(buffer);
	}
	for(int i; i<sizeof(SoundPop); i++)
	{
		PrecacheSound(SoundPop[i]);
		FormatEx(buffer, sizeof(buffer), "sound/%s", SoundPop[i]);
		AddFileToDownloadsTable(buffer);
	}
	for(int i; i<sizeof(SoundPurple); i++)
	{
		PrecacheSound(SoundPurple[i]);
		FormatEx(buffer, sizeof(buffer), "sound/%s", SoundPurple[i]);
		AddFileToDownloadsTable(buffer);
	}
	
	static const char Properties[][] = { "", "f", "fg", "g" };
	for(int i; i<sizeof(BloonSprites); i++)
	{
		if(i == Bloon_Ceramic)
			continue;
		
		for(int a; a<sizeof(Properties); a++)
		{
			FormatEx(buffer, sizeof(buffer), "materials/zombie_riot/btd/%s%s.vmt", BloonSprites[i], Properties[a]);
			PrecacheModel(buffer);
			AddFileToDownloadsTable(buffer);
			
			FormatEx(buffer, sizeof(buffer), "materials/zombie_riot/btd/%s%s.vtf", BloonSprites[i], Properties[a]);
			AddFileToDownloadsTable(buffer);
		}
	}
	
	for(int i; i<sizeof(Properties); i++)
	{
		for(int a=1; a<5; a++)
		{
			FormatEx(buffer, sizeof(buffer), "materials/zombie_riot/btd/%s%d%s.vmt", BloonSprites[Bloon_Ceramic], a, Properties[i]);
			PrecacheModel(buffer);
			AddFileToDownloadsTable(buffer);
			
			FormatEx(buffer, sizeof(buffer), "materials/zombie_riot/btd/%s%d%s.vtf", BloonSprites[Bloon_Ceramic], a, Properties[i]);
			AddFileToDownloadsTable(buffer);
		}
	}
	
	PrecacheModel("models/zombie_riot/btd/bloons_hitbox.mdl");
	AddFileToDownloadsTable("models/zombie_riot/btd/bloons_hitbox.dx80.vtx");
	AddFileToDownloadsTable("models/zombie_riot/btd/bloons_hitbox.dx90.vtx");
	AddFileToDownloadsTable("models/zombie_riot/btd/bloons_hitbox.mdl");
	AddFileToDownloadsTable("models/zombie_riot/btd/bloons_hitbox.vvd");
	#endif
}

static int BType[MAXENTITIES];
static bool Regrow[MAXENTITIES];
//static bool Camo[MAXENTITIES];
static int TypeOg[MAXENTITIES];
static int Sprite[MAXENTITIES];

methodmap Bloon < CClotBody
{
	property int m_iType
	{
		public get()
		{
			return BType[this.index];
		}
		public set(int value)
		{
			BType[this.index] = value;
		}
	}
	property int m_iOriginalType
	{
		public get()
		{
			return TypeOg[this.index];
		}
		public set(int value)
		{
			TypeOg[this.index] = value;
		}
	}
	property bool m_bRegrow
	{
		public get()
		{
			return Regrow[this.index];
		}
		public set(bool value)
		{
			Regrow[this.index] = value;
		}
	}
	/*property bool m_bCamo
	{
		public get()
		{
			return Camo[this.index];
		}
		public set(bool value)
		{
			Camo[this.index] = value;
		}
	}*/
	property bool m_bFortified
	{
		public get()
		{
			return this.m_bLostHalfHealth;
		}
		public set(bool value)
		{
			this.m_bLostHalfHealth = value;
		}
	}
	property int m_iSprite
	{
		public get()
		{
			return EntRefToEntIndex(Sprite[this.index]);
		}
		public set(int value)
		{
			Sprite[this.index] = EntIndexToEntRef(value);
		}
	}
	public void PlayLeadSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundLead) - 1);
		EmitSoundToAll(SoundLead[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayPurpleSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundPurple) - 1);
		EmitSoundToAll(SoundPurple[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayHitSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundCeramicHit) - 1);
		EmitSoundToAll(SoundCeramicHit[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayDeathSound()
	{
		if(this.m_iType == Bloon_Ceramic)
		{
			int sound = GetRandomInt(0, sizeof(SoundCeramicPop) - 1);
			EmitSoundToAll(SoundCeramicPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
			EmitSoundToAll(SoundCeramicPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
			EmitSoundToAll(SoundCeramicPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
		}
		else
		{
			int sound = GetRandomInt(0, sizeof(SoundPop) - 1);
			EmitSoundToAll(SoundPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
			EmitSoundToAll(SoundPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
			EmitSoundToAll(SoundPop[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0);
		}
	}
	public int UpdateBloonInfo()
	{
		this.m_iBleedType = this.m_iType == Bloon_Lead ? BLEEDTYPE_METAL : BLEEDTYPE_RUBBER;
		this.m_flSpeed = BloonSpeeds[this.m_iType] * BloonSpeedMulti();
		
		int sprite = this.m_iSprite;
		if(sprite > MaxClients && IsValidEntity(sprite))
		{
			AcceptEntityInput(sprite, "HideSprite");
			RemoveEntity(sprite);
		}
		
		sprite = CreateEntityByName("env_sprite");
		if(sprite != -1)
		{
			char buffer[128];
			if(this.m_iType == Bloon_Ceramic)
			{
				int rainbow = Bloon_Health(this.m_bFortified, Bloon_Rainbow);
				int health = (GetEntProp(this.index, Prop_Data, "m_iHealth") - rainbow) * 5;
				int maxhealth = GetEntProp(this.index, Prop_Data, "m_iMaxHealth") - rainbow;
				int type = (health / maxhealth);
				if(type == 5)
					type = 4;
				
				FormatEx(buffer, sizeof(buffer), "zombie_riot/btd/%s%d%s%s.vmt", BloonSprites[this.m_iType], type + 1, this.m_bFortified ? "f" : "", this.m_bRegrow ? "g" : "");
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "zombie_riot/btd/%s%s%s.vmt", BloonSprites[this.m_iType], this.m_bFortified ? "f" : "", this.m_bRegrow ? "g" : "");
			}
			
			DispatchKeyValue(sprite, "model", buffer);
			DispatchKeyValueFloat(sprite, "scale", 0.25);
			DispatchKeyValue(sprite, "rendermode", "7");
			
			if(this.m_bCamo)
				DispatchKeyValue(sprite, "renderamt", "45");
			
			DispatchSpawn(sprite);
			ActivateEntity(sprite);
			
			SetEntPropEnt(sprite, Prop_Send, "m_hOwnerEntity", this.index);
			AcceptEntityInput(sprite, "ShowSprite");
			
			float pos[3];
			GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 40.0;
			TeleportEntity(sprite, pos, NULL_VECTOR, NULL_VECTOR);
			SetVariantString("!activator");
			AcceptEntityInput(sprite, "SetParent", this.index, sprite);
			
			this.m_iSprite = sprite;
		}
	}
	public int RegrowsInto(int level)
	{
		if(level < Bloon_Black)
			return level;
		
		switch(level)
		{
			case 5:
			{
				switch(this.m_iOriginalType)
				{
					case Bloon_White:
					{
						return Bloon_White;
					}
					case Bloon_Purple:
					{
						return Bloon_Purple;
					}
					default:
					{
						return Bloon_Black;
					}
				}
			}
			case 6:
			{
				switch(this.m_iOriginalType)
				{
					case Bloon_Lead:
					{
						return Bloon_Lead;
					}
					default:
					{
						return Bloon_Zebra;
					}
				}
			}
			case 7:
			{
				return Bloon_Rainbow;
			}
			case 8:
			{
				return Bloon_Ceramic;
			}
		}
		
		return 0;
	}
	public int UpdateBloonOnDamage()
	{
		int health = GetEntProp(this.index, Prop_Data, "m_iHealth");
		for(int i; i<9; i++)
		{
			int type = this.RegrowsInto(i);
			if(health <= Bloon_Health(this.m_bFortified, type))
			{
				if(this.m_iType != type || type == Bloon_Ceramic)
				{
					if(this.m_iType > type)
						this.PlayDeathSound();
					
					this.m_iType = type;
					this.UpdateBloonInfo();
				}
				break;
			}
		}
	}
	public Bloon(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool camo, regrow, fortified;
		int type = GetBloonTypeOfData(data, camo, fortified, regrow);
		Building_CamoOrRegrowBlocker(camo, regrow);
		
		char buffer[7];
		IntToString(Bloon_Health(fortified, type), buffer, sizeof(buffer));
		
		Bloon npc = view_as<Bloon>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bloons_hitbox.mdl", "1.0", buffer, ally));
		
		i_NpcInternalId[npc.index] = BTD_BLOON;
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = NOTHING;	
		npc.m_iNpcStepVariation = NOTHING;	
		npc.m_bDissapearOnDeath = true;
		
		npc.m_bCamo = camo;
		npc.m_bFortified = fortified;
		npc.m_bRegrow = regrow;
		npc.m_iType = type;
		npc.m_iOriginalType = type;
		npc.UpdateBloonInfo();
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Bloon_ClotDamaged);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bloon_ClotDamagedPost);
		SDKHook(npc.index, SDKHook_Think, Bloon_ClotThink);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		
		npc.StartPathing();
		
		
		return npc;
	}
}

//TODO 
//Rewrite
public void Bloon_ClotThink(int iNPC)
{
	Bloon npc = view_as<Bloon>(iNPC);
	
	float gameTime = GetGameTime();
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_bRegrow)
	{
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		if(health < maxhealth)
		{
			health += 3 + (npc.m_iOriginalType * 4);
			if(health > maxhealth)
				health = maxhealth;
			
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			npc.UpdateBloonOnDamage();
		}
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
													
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			//float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			PF_SetGoalVector(npc.index, PredictSubjectPosition(npc, PrimaryThreatIndex));
		}
		else
		{
			PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < 10000)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				
				Handle swingTrace;
				if(npc.DoAimbotTrace(swingTrace, PrimaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						for(int i; i<9; i++)
						{
							if(npc.RegrowsInto(i) == npc.m_iType)
							{
								if(target <= MaxClients)
								{
									if(npc.m_bFortified)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 1.0 + float(i) * 0.8 * 1.4, DMG_CLUB, -1, _, vecHit);
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 1.0 + float(i) * 0.8, DMG_CLUB, -1, _, vecHit);
									}
								}
								else
								{
									if(npc.m_bFortified)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 2.0 + float(i) * 1.6 * 1.4, DMG_CLUB, -1, _, vecHit);
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 2.0 + float(i) * 1.6, DMG_CLUB, -1, _, vecHit);
									}
								}
								delete swingTrace;
							}
						}
					}
				}
			}
		}
		
		npc.StartPathing();
		
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Bloon_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	Bloon npc = view_as<Bloon>(victim);
	
	bool hot;
	bool cold;
	bool magic;
	bool pierce;
	
	if((damagetype & DMG_SLASH) || Building_DoesPierce(attacker))
	{
		pierce = true;
	}
	else
	{
		if((damagetype & DMG_BLAST) && f_IsThisExplosiveHitscan[attacker] != GetGameTime())
		{
			hot = true;
			pierce = true;
		}
		
		if(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_ICE)
		{
			cold = true;
		}
		
		if(damagetype & DMG_PLASMA)
		{
			magic = true;
			pierce = true;
		}
		else if((damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[victim] & ZR_DAMAGE_LASER_NO_BLAST))
		{
			magic = true;
		}
	}
	
	switch(npc.m_iType)
	{
		case Bloon_Black:
		{
			if(hot)
				damage *= 0.15;
		}
		case Bloon_White:
		{
			if(cold)
				damage *= 0.15;
		}
		case Bloon_Purple:
		{
			if(magic)
			{
				damage *= 0.1;
				npc.PlayPurpleSound();
			}
		}
		case Bloon_Lead:
		{
			if(!pierce)
			{
				damage *= 0.15;
				npc.PlayLeadSound();
			}
		}
		case Bloon_Zebra:
		{
			if(hot || cold)
				damage *= 0.15;
		}
		case Bloon_Ceramic:
		{
			npc.PlayHitSound();
		}
	}
	return Plugin_Changed;
}

public void Bloon_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Bloon npc = view_as<Bloon>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bloon_NPCDeath(int entity)
{
	Bloon npc = view_as<Bloon>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bloon_ClotDamagedPost);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Bloon_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Bloon_ClotThink);
	
	int sprite = npc.m_iSprite;
	if(sprite > MaxClients && IsValidEntity(sprite))
	{
		AcceptEntityInput(sprite, "HideSprite");
		RemoveEntity(sprite);
	}
}
