#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfirm.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};


static const char g_RangedAttackSoundsSecondary[][] = {
	"ambient/levels/labs/electric_explosion5.wav",
};

static const char g_RangedAttackSounds[][] = {
	"misc/halloween/spell_lightning_ball_cast.wav",
};

static const char g_RangedReloadSound[][] = {
	"misc/halloween/spell_mirv_cast.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void PhantomKnight_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
}

static bool b_IsPhantomFake[MAXENTITIES];
static float f_AttackHappensAoe[MAXENTITIES];
static float f_StareAtEnemy[MAXENTITIES];
static int i_PhantomsSpawned[MAXENTITIES];

methodmap PhantomKnight < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() 
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedReloadSound() 
	{
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedAttackSecondarySound()
	{
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	
	public PhantomKnight(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		PhantomKnight npc = view_as<PhantomKnight>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", GetLucianHealth(), ally));
		
		//Normal sized Miniboss!
		i_NpcInternalId[npc.index] = PHANTOM_KNIGHT;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_CUSTOM_IDLE_LUCIAN");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iChanged_WalkCycle = -1;
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		float wave = float(ZR_GetWaveCount()+1); //Wave scaling
		
		wave *= 0.1;

		npc.m_flWaveScale = wave;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 150.0;
		npc.m_flNextRangedAttack = GetGameTime() + 5.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime() + 10.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flDoingAnimation = 0.0;
		npc.m_fbRangedSpecialOn = false;

		f_AttackHappensAoe[npc.index] = 0.0;
		b_IsPhantomFake[npc.index] = false;
		f_StareAtEnemy[npc.index] = 0.0; 
		i_PhantomsSpawned[npc.index] = 0; 

		npc.m_flMeleeArmor = 1.25; 		//Melee should be rewarded for trying to face this monster
		npc.m_flRangedArmor = 0.75;		//Due to his speed, ranged will deal less
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, PhantomKnight_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, PhantomKnight_ClotThink);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 200, 200, 200, 255);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		//sword

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/hw2013_shamans_skull/hw2013_shamans_skull.mdl"
		,_,_, 2.0);
		//face

	//	SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
	//	SetEntityRenderColor(npc.m_iWearable3, 130, 130, 130, 255);

		npc.m_iWearable2 = npc.EquipItem("forward", "models/workshop/player/items/soldier/sf14_hellhunters_headpiece/sf14_hellhunters_headpiece.mdl",_,_, 1.2);
		//Hat

		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 200, 200, 255);


		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 255, 150, 150, 255);
		//Cape


		
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void PhantomKnight_ClotThink(int iNPC)
{
	PhantomKnight npc = view_as<PhantomKnight>(iNPC);
	
	float gameTime = GetGameTime();
/*
	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	*/
	static int NoEnemyFound;
	npc.Update();	
	/*
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
//		npc.PlayHurtSound();
	}
	*/
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime) //Find a new victim to destroy.
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	
	if(!npc.m_bisWalking) //Dont move, or path. so that he doesnt rotate randomly.
	{
		npc.m_flSpeed = 0.0;
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;	
	}
	//No else, We will set the speed and pathing ourselves down below.
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 55.0;
					if(b_IsPhantomFake[npc.index]) //Make sure that he wont do damage if its a fake 
					{
						damage = 33.0;
					}

					npc.PlayMeleeHitSound();
					if(target > 0) 
					{
						if(target <= MaxClients)
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_CLUB);
						}
						else
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 4.0 * npc.m_flWaveScale, DMG_CLUB);	
						}
					}
				}
				delete swingTrace;
			}
		}
	}

	if(f_AttackHappensAoe[npc.index])
	{
		if(f_AttackHappensAoe[npc.index] < gameTime)
		{
			float damage = 400.0;
			if(b_IsPhantomFake[npc.index]) //Make sure that he wont do damage if its a fake 
			{
				damage = 190.0;
			}
			npc.PlayRangedReloadSound();
			i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_CLUB_DAMAGE;
			makeexplosion(npc.index, npc.index, WorldSpaceCenter(npc.index), "", RoundToCeil(damage * npc.m_flWaveScale), 110,_,_,_, false);

			f_StareAtEnemy[npc.index] = GetGameTime() + 2.0;
			f_AttackHappensAoe[npc.index] = 0.0;
			//Do aoe logic!
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		NoEnemyFound = 0;
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		//Get position for just travel here.
		
		//BEHAVIORS:
		//We do not attack normally by default, we are cool and only dash and attack like that normally,
		//just do SUPER cool melee swings if MUST be. Ignoring Barricades helps alot here to simplify this.
		//Sadly have to respect enemy npcs so lol.
		//They are too close to us. Engage in Melee attack.
		//But we also dont want him to engage in this state when he cant even attack like during a cooldown.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < Pow(500.0, 2.0) && npc.m_flNextRangedSpecialAttack < gameTime && !b_IsPhantomFake[npc.index]) //Teleport has first priority, do this!
		{
			//Fakes cant teleport (would be too much)
			npc.m_iState = 4; //Do A teleport to behind or atleast close to the enemy! If i get stuck and get teleported back, thats no issue, i will own a clone regardless!
		}
		else if(flDistanceToTarget < Pow(150.0, 2.0) && npc.m_flNextRangedAttack < gameTime)
		{
			npc.m_iState = 2; //Do Aoe Ranged Attack To everything around him
		}
		else if(flDistanceToTarget < Pow(100.0, 2.0) && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else if(f_StareAtEnemy[npc.index] > gameTime) //no enemy is close enough to do anything, but i just did an aoe attack, stare at them.
		{
			npc.m_iState = 3; //Stare at the enemy and into their soul.
		}
		else if(flDistanceToTarget > Pow(90.0, 2.0))
		{
			npc.m_iState = 0; //Walk to target
		}
		else 
		{
			npc.m_iState = 3; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				npc.m_flSpeed = 150.0; //Walk slowly cus we cool
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_CUSTOM_WALK_LUCIAN");
				}
			}
			case 1:
			{			
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in rape, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					if(npc.m_iChanged_WalkCycle != 3) 	
					{
						npc.m_iChanged_WalkCycle = 3;
						npc.SetActivity("ACT_CUSTOM_ATTACK_LUCIAN");
					}

					//SPAWN COOL EFFECT
					float flPos[3];
					float flAng[3];
					GetAttachment(npc.index, "special_weapon_effect", flPos, flAng);
				
					int particle = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.75);
							
					SetParent(npc.index, particle, "special_weapon_effect");
					//SPAWN COOL EFFECT

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.6;
					npc.m_flNextMeleeAttack = gameTime + 2.5; //make him attack very slowly
					npc.m_bisWalking = false;
				}
			}	
			case 2:
			{
				int Enemy_I_See;
							
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				//Can i see This enemy, is something in the way of us?
				//Dont want to do the aoe burst if i cant even see the enemy!
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.PlayRangedSound();
					if(npc.m_iChanged_WalkCycle != 2) 	
					{
						npc.m_iChanged_WalkCycle = 2;
						npc.SetActivity("ACT_CUSTOM_AOE_LUCIAN");
					}
					
					f_AttackHappensAoe[npc.index] = gameTime + 0.7; //One second time to dodge this explosive attack!

					//SPAWN COOL EFFECT
					float flPos[3];
					float flAng[3];
					GetAttachment(npc.index, "special_weapon_effect", flPos, flAng);
				
					int particle = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 1.5);
							
					SetParent(npc.index, particle, "special_weapon_effect");
					//SPAWN COOL EFFECT

					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_flNextRangedAttack = gameTime + 8.0; //make him attack very slowly
					npc.m_bisWalking = false;
				}
			}	
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 5) 	
				{
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_CUSTOM_IDLE_LUCIAN");
				}
				
				//Stare. Dont even attack. Dont do anything. Just look. This should also be impossible to backstab.
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				npc.m_bisWalking = false;
			}
			case 4:
			{
				float VecForward[3];
				float vecRight[3];
				float vecUp[3];
				float vecPos[3];
				
				GetVectors(npc.m_iTarget, VecForward, vecRight, vecUp); //Sorry i dont know any other way with this :(
				vecPos = GetAbsOrigin(npc.m_iTarget);
				vecPos[2] += 5.0;
				
				float vecSwingEnd[3];
				vecSwingEnd[0] = vecPos[0] - VecForward[0] * (100);
				vecSwingEnd[1] = vecPos[1] - VecForward[1] * (100);
				vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/

				/*
				float vectest[3];
				vectest[0] = vecSwingEnd[0];
				vectest[1] = vecSwingEnd[1];
				vectest[2] = vecSwingEnd[2] + 54;
				int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
				TE_SetupBeamPoints(vecSwingEnd, vectest, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
				TE_SendToAll();
				*/

				float vecPos_Npc[3];
				float vecPosMiddle_Npc[3];
				float vecAng_Npc[3];
				vecPos_Npc = GetAbsOrigin(npc.index);
				vecPosMiddle_Npc = WorldSpaceCenter(npc.index);
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAng_Npc);

				bool Succeed = NPC_Teleport(npc.index, vecSwingEnd);
				if(Succeed)
				{
					npc.PlayRangedAttackSecondarySound();
					if(npc.m_iChanged_WalkCycle != 1) 	
					{
						npc.m_iChanged_WalkCycle = 1;
						npc.SetActivity("ACT_CUSTOM_TELEPORT_LUCIAN");
					}
					npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
					if(i_PhantomsSpawned[npc.index] <= 5 || (ZR_GetWaveCount() > 60 && i_PhantomsSpawned[npc.index] <= 10)) //We want a limit on how many fakes he can have.
					{
						//If its wave 60 or above, he can spawn 10 instead

						//spawn fakes!
						int fake_spawned = view_as<int>(PhantomKnight(1, vecPos_Npc, vecAng_Npc, b_IsAlliedNpc[npc.index]));
						if(IsValidEntity(view_as<int>(fake_spawned)))
						{
							if(b_thisNpcIsABoss[npc.index]) //If he is a boss, make his clones a boss.
							{
								b_thisNpcIsABoss[view_as<int>(fake_spawned)] = true;
								SetEntProp(view_as<int>(fake_spawned), Prop_Send, "m_bGlowEnabled", true);
							}
							Zombies_Currently_Still_Ongoing += 1;
							b_IsPhantomFake[view_as<int>(fake_spawned)] = true;

							int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

							maxhealth /= 6;

							SetEntProp(view_as<int>(fake_spawned), Prop_Data, "m_iHealth", maxhealth);
							SetEntProp(view_as<int>(fake_spawned), Prop_Data, "m_iMaxHealth", maxhealth);

							//clones have 10% of his health

							i_PhantomsSpawned[npc.index] += 1; //Add one more.
						}
					}
					ParticleEffectAt(vecPosMiddle_Npc, "drg_cow_explosioncore_normal", 0.5);

					npc.m_flNextRangedSpecialAttack = gameTime + 15.0; //Teleport every 15 seconds.
					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_bisWalking = false;
				}
				else
				{
					npc.m_flNextRangedSpecialAttack = gameTime + 1.0; //Try again later.
				}
				//Do Teleport Logic and attack right after.
			}
		}
	}
	else
	{
		NoEnemyFound += 1;
		if(NoEnemyFound > 5)
		{
			if(npc.m_iChanged_WalkCycle != 5) 	//There was no enemy after trying to find one for 5 times (half a second). Just dont do anything.
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_CUSTOM_IDLE_LUCIAN");
			}
		}
		//no victim died or just isnt valid anymore, find another victim to murder.
		npc.m_flGetClosestTargetTime = 0.0;
	}
	npc.PlayIdleAlertSound();
}

public Action PhantomKnight_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	PhantomKnight npc = view_as<PhantomKnight>(victim);
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker, true))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
		
	return Plugin_Changed;
}

public void PhantomKnight_NPCDeath(int entity)
{
	PhantomKnight npc = view_as<PhantomKnight>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, PhantomKnight_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, PhantomKnight_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static char[] GetLucianHealth()
{
	int health = 180;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(CurrentRound+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
	}
	else if(CurrentRound+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}