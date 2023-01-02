#pragma semicolon 1
#pragma newdecls required

#define LASERBEAM "sprites/laserbeam.vmt"

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/medic_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/medic_mvm_painsharp01.mp3",
	"vo/mvm/norm/medic_mvm_painsharp02.mp3",
	"vo/mvm/norm/medic_mvm_painsharp03.mp3",
	"vo/mvm/norm/medic_mvm_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/medic_mvm_battlecry01.mp3",
	"vo/mvm/norm/medic_mvm_battlecry02.mp3",
	"vo/mvm/norm/medic_mvm_battlecry03.mp3",
	"vo/mvm/norm/medic_mvm_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void Alt_Medic_Constructor_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel("models/bots/medic/bot_medic.mdl");
	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM);
}

methodmap Alt_Medic_Constructor < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public Alt_Medic_Constructor(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.0", "3500", ally));
		
		i_NpcInternalId[npc.index] = ALT_MEDIC_HEALER_3;	//3 being the 3rd stage of alt waves.
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Alt_Medic_Constructor_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Alt_Medic_Constructor_ClotThink);
		
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_iWearable5 = INVALID_ENT_REFERENCE;
		Is_a_Medic[npc.index] = true;
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		
		npc.m_bnew_target = false;
		npc.StartPathing();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_medigun/c_medigun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable6	= npc.EquipItem("head", "models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		npc.StartPathing();
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
			
		return npc;
	}
	public void StartHealing(int iEnt)
	{
		int im_iWearable3 = this.m_iWearable3;
		if(im_iWearable3 != INVALID_ENT_REFERENCE)
		{
			this.Healing = true;
			
		//	EmitSoundToAll("m_iWearable3s/medigun_heal.wav", this.index, SNDCHAN_m_iWearable3);
		}
	}	
	public void StopHealing()
	{
		int iBeam = this.m_iWearable5;
		if(iBeam != INVALID_ENT_REFERENCE)
		{
			int iBeamTarget = GetEntPropEnt(iBeam, Prop_Send, "m_hOwnerEntity");
			if(IsValidEntity(iBeamTarget))
			{
				AcceptEntityInput(iBeamTarget, "ClearParent");
				RemoveEntity(iBeamTarget);
			}
			
			AcceptEntityInput(iBeam, "ClearParent");
			RemoveEntity(iBeam);
			
			EmitSoundToAll("weapons/medigun_no_target.wav", this.index, SNDCHAN_WEAPON);
			
		//	StopSound(this.index, SNDCHAN_m_iWearable3, "m_iWearable3s/medigun_heal.wav");
			
			this.Healing = false;
		}
	}
}

//TODO 
//Rewrite
public void Alt_Medic_Constructor_ClotThink(int iNPC)
{
	Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(!npc.m_bFUCKYOU)
	{
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 5000.0;
		}
		
		int PrimaryThreatIndex = npc.m_iTarget;
		if(IsValidAlly(npc.index, PrimaryThreatIndex))
		{
				PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
				float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
				float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
				
				if(flDistanceToTarget < 250000)
				{
					if(flDistanceToTarget < 62500)
					{
						PF_StopPathing(npc.index);
						npc.m_bPathing = false;	
					}
					else
					{
						npc.StartPathing();
						npc.m_bPathing = false;		
					}
					if(!npc.m_bnew_target)
					{
						npc.StartHealing(PrimaryThreatIndex);
						npc.m_iWearable4 = ConnectWithBeam(npc.m_iWearable3, PrimaryThreatIndex, 100, 100, 250, 3.0, 3.0, 1.35, LASERBEAM);
						npc.Healing = true;
						npc.m_bnew_target = true;
					}
					SetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth", GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth") + 60);
					if(GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth") >= GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iMaxHealth"))
					{
						SetEntProp(PrimaryThreatIndex, Prop_Data, "m_iHealth", GetEntProp(PrimaryThreatIndex, Prop_Data, "m_iMaxHealth"));
					}
					
					npc.FaceTowards(WorldSpaceCenter(PrimaryThreatIndex), 2000.0);
				}
				else
				{
					if(IsValidEntity(npc.m_iWearable4))
						RemoveEntity(npc.m_iWearable4);
						
					npc.StartPathing();
					npc.m_bPathing = false;		
					npc.m_bnew_target = false;					
				}
		}
		else
		{
			
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
				
			npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
			
			SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
		
			if(IsValidEntity(npc.m_iWearable4))
				RemoveEntity(npc.m_iWearable4);
				
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.StopHealing();
			npc.Healing = false;
			npc.m_bnew_target = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_bFUCKYOU = true;
			npc.m_iTarget = GetClosestAlly(npc.index);
		}
	}
	else if(npc.m_bFUCKYOU)
	{
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			if(!npc.m_bFUCKYOU_move_anim)
			{
				int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.m_bFUCKYOU_move_anim = true;
			}
			npc.m_flSpeed = 400.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		}
		
		int PrimaryThreatIndex = npc.m_iTarget;
		
		if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
		{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
				float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
				
				//Predict their pos.
				if(flDistanceToTarget < npc.GetLeadRadius()) {
					
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
					
				/*	int color[4];
					color[0] = 255;
					color[1] = 255;
					color[2] = 0;
					color[3] = 255;
				
					int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
				
					TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
					TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
					
					PF_SetGoalVector(npc.index, vPredictedPos);
				} else {
					PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
				}
				
				//Target close enough to hit
				if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
				{
					//Look at target so we hit.
			//		npc.FaceTowards(vecTarget, 1000.0);
					
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
					{
						//Play attack ani
						if (!npc.m_flAttackHappenswillhappen)
						{
							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
							npc.PlayMeleeSound();
							npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
							npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
							npc.m_flAttackHappenswillhappen = true;
						}
							
						if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
						{
							Handle swingTrace;
							npc.FaceTowards(vecTarget, 20000.0);
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
							{
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									
									if(target <= MaxClients)
										SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, 400.0, DMG_CLUB, -1, _, vecHit);
									
									
									
									
									// Hit sound
									npc.PlayMeleeHitSound();
									
								} 
							}
							delete swingTrace;
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
							npc.m_flAttackHappenswillhappen = false;
						}
						else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
						{
							npc.m_flAttackHappenswillhappen = false;
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
						}
					}
				}
				else
				{
					npc.StartPathing();
					
				}
		}
		else
		{
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
	npc.PlayIdleAlertSound();
}

public Action Alt_Medic_Constructor_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &m_iWearable3, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Alt_Medic_Constructor_NPCDeath(int entity)
{
	Alt_Medic_Constructor npc = view_as<Alt_Medic_Constructor>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Alt_Medic_Constructor_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Alt_Medic_Constructor_ClotThink);
	
	Is_a_Medic[npc.index] = false;
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	npc.StopHealing();
}