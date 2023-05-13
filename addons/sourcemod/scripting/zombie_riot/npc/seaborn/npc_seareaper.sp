#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/fast_zombie/wake1.wav",
};

static const char g_HurtSounds[][] =
{
	"npc/fast_zombie/leap1.wav"
};

static const char g_leap_scream[][] =
{
	"npc/fast_zombie/fz_scream1.wav"
};

static const char g_IdleSounds[][] =
{
	"npc/fast_zombie/idle1.wav",
	"npc/fast_zombie/idle2.wav",
	"npc/fast_zombie/idle3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/fast_zombie/fz_alert_close1.wav",
	"npc/fast_zombie/fz_alert_far1.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/fast_zombie/fz_frenzy1.wav"
};

methodmap SeaReaper < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(this.Anger)
		{
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		}
		else
		{
			EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);	
	}
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_leap_scream[GetRandomInt(0, sizeof(g_leap_scream) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);	
	}
	
	public SeaReaper(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		SeaReaper npc = view_as<SeaReaper>(CClotBody(vecPos, vecAng, "models/zombie/fast.mdl", "1.75", data[0] ? "3750" : "3000", ally, false, true));
		// 20000 x 0.15
		// 25000 x 0.15

		i_NpcInternalId[npc.index] = data[0] ? SEAREAPER_ALT : SEAREAPER;
		npc.SetActivity("ACT_WALK");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, SeaReaper_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, SeaReaper_ClotThink);
		
		npc.m_flSpeed = 75.0;	// 0.3 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.Anger = false;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 50, 50, 255, 255);
		
		npc.StartPathing();
		return npc;
	}
}

public void SeaReaper_ClotThink(int iNPC)
{
	SeaReaper npc = view_as<SeaReaper>(iNPC);

	if(i_NpcInternalId[npc.index] == SEAREAPER_ALT)
	{
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
	}
	
	if(npc.Anger)
		SDKHooks_TakeDamage(npc.index, 0, 0, 2.0, DMG_DROWN);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.Anger)
		{
			npc.PlayHurtSound();
			npc.m_blPlayHurtAnimation = false;
		}
		else
		{
			if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") - 300) < GetEntProp(npc.index, Prop_Data, "m_iHealth"))
			{
				npc.AddGesture("ACT_FASTZOMBIE_FRENZY");
				npc.SetActivity("ACT_RUN");
				npc.PlayAngerSound();

				npc.Anger = true;
				npc.m_flSpeed = 1250.0;	// 5.0 x 250
				npc.m_iTarget = 0;
				npc.m_flNextThinkTime = gameTime + 1.5;
				npc.StopPathing();
			}
		}
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 0.5;

		if(npc.Anger)
		{
			spawnRing_Vectors(vecMe, 100.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.4, 6.0, 0.1, 1, 1000.0);
			Explode_Logic_Custom(0.0, 0, npc.index, -1, vecMe, 400.0, _, _, true, _, false, _, SeaRepear_ExplodePost);
		}
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = npc.Anger ? GetVectorDistance(vecTarget, vecMe, true) : FAR_FUTURE;		
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, i_NpcInternalId[npc.index] == SEAREAPER_ALT ? 75.0 : 60.0, DMG_CLUB);
						// 400 x 0.15
						// 500 x 0.15

						SeaSlider_AddNeuralDamage(target, npc.index,i_NpcInternalId[npc.index] == SEAREAPER_ALT ? 8 : 6);
						// 400 x 0.1 x 0.15
						// 500 x 0.1 x 0.15
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 22500.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_FASTZOMBIE_BIG_SLASH");

				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.55;

				//npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flNextMeleeAttack = gameTime + 3.0;
				npc.m_flHeadshotCooldown = gameTime + 1.1;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public void SeaRepear_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	SeaSlider_AddNeuralDamage(victim, attacker, i_NpcInternalId[attacker] == SEAREAPER_ALT ? 15 : 12);
	// 400 x 0.2 x 0.15
	// 500 x 0.2 x 0.15
}

public Action SeaReaper_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	SeaReaper npc = view_as<SeaReaper>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaReaper_NPCDeath(int entity)
{
	SeaReaper npc = view_as<SeaReaper>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, SeaReaper_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, SeaReaper_ClotThink);
}