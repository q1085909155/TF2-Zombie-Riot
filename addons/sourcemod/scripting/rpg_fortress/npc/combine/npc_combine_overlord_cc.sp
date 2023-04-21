#pragma semicolon 1
#pragma newdecls required

methodmap CombineOverlordCC < CombineSoldier
{
	public CombineOverlordCC(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CombineOverlordCC npc = view_as<CombineOverlordCC>(BaseSquad(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_OVERLORD_CC;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_bRanged = false;

		// Melee attack
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		// Pulse attack
		npc.m_flNextRangedAttack = GetGameTime() + 15.0;
		npc.m_flNextRangedAttackHappening = 0.0;

		// Movement delay
		npc.m_flNextRangedSpecialAttackHappens = npc.m_flNextRangedAttack + 60.0;

		npc.m_flMeleeArmor = 0.1001;
		npc.m_flRangedArmor = 0.1001;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, CombineOverlordCC_TakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombineOverlordCC_ClotThink);

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 180, 155, 155, 255);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		return npc;
	}
}

public void CombineOverlordCC_ClotThink(int iNPC)
{
	CombineOverlordCC npc = view_as<CombineOverlordCC>(iNPC);

	SetVariantInt(1);
	AcceptEntityInput(npc.index, "SetBodyGroup");

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	float vecMe[3];
	vecMe = WorldSpaceCenter(npc.index);
	BaseSquad_BaseThinking(npc, vecMe);

	bool canWalk = (npc.m_iTargetWalk || !npc.m_iTargetAttack);
	if(npc.m_iTargetAttack)
	{
		float vecTarget[3];
		vecTarget = WorldSpaceCenter(npc.m_iTargetAttack);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				npc.FaceTowards(vecTarget, 20000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTargetAttack))
				{
					int target = TR_GetEntityIndex(swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						TR_GetEndPosition(vecTarget, swingTrace);

						ExtinguishEntity(target);
						IgniteEntity(target, 10.0);

						// E2 L20 = 150, E2 L25 = 165
						SDKHooks_TakeDamage(target, npc.index, npc.index, Level[npc.index] * 3.0, DMG_CLUB, -1, _, vecTarget);
						npc.PlaySwordHit();
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextRangedAttackHappening)
		{
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				
				npc.FaceTowards(vecTarget, 20000.0);

				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				
				if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
				{
					ExtinguishEntity(npc.m_iTargetAttack);
					IgniteEntity(npc.m_iTargetAttack, 10.0);
					//StartHealingTimer(npc.m_iTargetAttack, 0.1, -1.0, 100);

					npc.PlayOverload();
				}

				if(npc.m_flRangedArmor > 1.1001)
					npc.m_flRangedArmor = 1.1001;

				if(npc.m_flMeleeArmor > 1.1001)
					npc.m_flMeleeArmor = 1.1001;

				npc.m_flRangedArmor -= 0.1;
				if(npc.m_flRangedArmor < 0.01)
					npc.m_flRangedArmor = 0.0101;
				
				npc.m_flMeleeArmor -= 0.1;
				if(npc.m_flMeleeArmor < 0.01)
					npc.m_flMeleeArmor = 0.0101;
			}
			else if(Can_I_See_Enemy(npc.index, npc.m_iTargetAttack) == npc.m_iTargetAttack)
			{
				npc.FaceTowards(vecTarget, 2000.0);
			}
		}
		else if(GetVectorDistance(vecTarget, vecMe, true) < (NORMAL_ENEMY_MELEE_RANGE_FLOAT * NORMAL_ENEMY_MELEE_RANGE_FLOAT))
		{
			if(npc.m_flNextMeleeAttack < gameTime && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_ACHILLES_ATTACK_DAGGER");
				
				npc.PlaySwordFire();

				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.95;
			}
		}
		else
		{
			if((npc.m_flNextRangedAttack < gameTime || (i_NpcFightOwner[npc.index] && !npc.m_iTargetWalk)) && IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTargetAttack)))
			{
				npc.AddGesture("ACT_MELEE_PULSE");

				npc.m_flNextRangedAttackHappening = gameTime + 0.35;
				npc.m_flNextRangedAttack = gameTime + 17.5;

				float time = gameTime + 0.95;
				if(npc.m_flNextRangedSpecialAttackHappens < time)
					npc.m_flNextRangedSpecialAttackHappens = time;
			}
		}

		if(npc.m_flNextRangedSpecialAttackHappens > gameTime)
			canWalk = false;
	}

	if(canWalk)
	{
		BaseSquad_BaseWalking(npc, vecMe, true);
	}
	else
	{
		npc.StopPathing();
	}

	BaseSquad_BaseAnim(npc, 73.6, "ACT_PRINCE_IDLE", "ACT_PRINCE_WALK");
}

public Action CombineOverlordCC_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CombineOverlordCC npc = view_as<CombineOverlordCC>(victim);

	if(damagetype & DMG_CLUB)
	{
		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		npc.m_flMeleeArmor += 0.0125;
	}
	else if(!(damagetype & DMG_SLASH))
	{
		EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		npc.m_flRangedArmor += 0.005;
	}

	return Plugin_Changed;
}

void CombineOverlordCC_NPCDeath(int entity)
{
	CombineOverlordCC npc = view_as<CombineOverlordCC>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, CombineOverlordCC_TakeDamage);
	SDKUnhook(npc.index, SDKHook_Think, CombineOverlordCC_ClotThink);

	if(!npc.m_bGib)
		npc.PlayDeath();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
