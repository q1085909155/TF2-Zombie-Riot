#pragma semicolon 1
#pragma newdecls required

static const char MiningLevels[][] =
{
	"Wooden (0)",
	"Stone (1)",
	"Bronze (2)",
	"Iron (3)",
	"Steel (4)",
	"Diamond (5)",
	"Emerald (6)",
	"Obsidian (7)"
};

static const char FishingLevels[][] =
{
	"Leaf (0)",
	"Feather (1)",
	"Silk (2)",
	"Wire (3)",
	"IV Cable (4)",
	"Carving Tool (5)",
	"MV Cable (6)",
	"HV Cable (7)"
};


static KeyValues HashKey;

#define ITEM_XP		"Experience Points"
static int ItemXP = -1;

#define ITEM_TIER	"Elite Promotions"
static int ItemTier = -1;

enum struct StoreEnum
{
	char Tag[16];
	
	char Model[PLATFORM_MAX_PATH];
	char Intro[64];
	char Idle[64];
	float Pos[3];
	float Ang[3];
	float Scale;
	char Enter[64];
	char Talk[64];
	char Leave[64];
	
	char Wear1[PLATFORM_MAX_PATH];
	char Wear2[PLATFORM_MAX_PATH];
	char Wear3[PLATFORM_MAX_PATH];
	
	int EntRef;
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetString("tag", this.Tag, 16);
		
		kv.GetString("model", this.Model, PLATFORM_MAX_PATH);
		if(this.Model[0])
		{
			this.Scale = kv.GetFloat("scale", 1.0);
			
			kv.GetString("anim_enter", this.Intro, 64);
			kv.GetString("anim_idle", this.Idle, 64);
			
			kv.GetVector("pos", this.Pos);
			kv.GetVector("ang", this.Ang);
			
			kv.GetString("wear1", this.Wear1, PLATFORM_MAX_PATH);
			if(this.Wear1[0])
				PrecacheModel(this.Wear1);
			
			kv.GetString("wear2", this.Wear2, PLATFORM_MAX_PATH);
			if(this.Wear2[0])
				PrecacheModel(this.Wear2);
			
			kv.GetString("wear3", this.Wear3, PLATFORM_MAX_PATH);
			if(this.Wear3[0])
				PrecacheModel(this.Wear3);
		}
		
		kv.GetString("sound_enter", this.Enter, 64);
		if(this.Enter[0])
			PrecacheScriptSound(this.Enter);
		
		kv.GetString("sound_buy", this.Talk, 64);
		if(this.Talk[0])
			PrecacheScriptSound(this.Talk);
		
		kv.GetString("sound_leave", this.Leave, 64);
		if(this.Leave[0])
			PrecacheScriptSound(this.Leave);
	}
	
	void PlayEnter(int client)
	{
		if(this.Enter[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Enter, entity);
		}
	}
	
	void PlayBuy(int client)
	{
		if(this.Talk[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Talk, entity);
		}
	}
	
	void PlayLeave(int client)
	{
		if(this.Leave[0])
		{
			int entity = client;
			if(this.EntRef != INVALID_ENT_REFERENCE)
				entity = EntRefToEntIndex(this.EntRef);
			
			EmitGameSoundToClient(client, this.Leave, entity);
		}
	}
	
	void Despawn()
	{
		if(this.EntRef != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
				RemoveEntity(entity);
			
			this.EntRef = INVALID_ENT_REFERENCE;
		}
	}
	
	void Spawn()
	{
		if(this.EntRef == INVALID_ENT_REFERENCE && this.Model[0])
		{
			int entity = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "targetname", "rpg_fortress");
				DispatchKeyValue(entity, "model", this.Model);
				
				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR);
				
				DispatchSpawn(entity);
				SetEntityCollisionGroup(entity, 2);
				
				if(this.Wear1[0])
					GivePropAttachment(entity, this.Wear1);
				
				if(this.Wear2[0])
					GivePropAttachment(entity, this.Wear2);
				
				if(this.Wear3[0])
					GivePropAttachment(entity, this.Wear3);
				
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", this.Scale);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
				
				if(this.Intro[0])
				{
					SetVariantString(this.Intro);
					AcceptEntityInput(entity, "SetAnimation", entity, entity);
				}
				
				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

enum struct BackpackEnum
{
	int Owner;
	int Item;
	int Amount;
}

enum
{
	MENU_WEAPONS = 0,
	MENU_SPELLS = 1,
	MENU_BACKPACK = 2
}

static ArrayList Backpack;
static StringMap StoreList;
static char InStore[MAXTF2PLAYERS][16];
static int ItemIndex[MAXENTITIES];
static int ItemCount[MAXENTITIES];
static float ItemLifetime[MAXENTITIES];
static bool InMenu[MAXTF2PLAYERS];
static int MenuType[MAXTF2PLAYERS];
static float RefreshAt[MAXTF2PLAYERS];

static void HashCheck()
{
	for(int i; ; i++)
	{
		KeyValues kv = TextStore_GetItemKv(i);
		if(kv)
		{
			if(kv != HashKey)
			{
				ItemXP = -1;
				ItemTier = -1;

				delete Backpack;
				Backpack = new ArrayList(sizeof(BackpackEnum));

				Store_Reset();
				RPG_PluginEnd();

				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client))
						CancelClientMenu(client);
				}

				SPrintToChatAll("The store was reloaded, items and areas were also reloaded!");

				HashKey = kv;
			}
			break;
		}
	}
}

void TextStore_PluginStart()
{
	CreateTimer(2.0, TextStore_ItemTimer, _, TIMER_REPEAT);
}

void TextStore_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Stores"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "stores");
		kv = new KeyValues("Stores");
		kv.ImportFromFile(buffer);
	}
	
	delete StoreList;
	StoreList = new StringMap();

	StoreEnum store;
	store.EntRef = INVALID_ENT_REFERENCE;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(buffer, sizeof(buffer));
		store.SetupEnum(kv);
		StoreList.SetArray(buffer, store, sizeof(store));
	}
	while(kv.GotoNextKey());

	if(kv != map)
		delete kv;
	
	HashCheck();
	for(int client = 1; client <= MaxClients; client++)
	{
		InStore[client][0] = 0;
		if(IsClientInGame(client) && TextStore_GetClientLoad(client))
			LoadItems(client);
	}
}

public ItemResult TextStore_Item(int client, bool equipped, KeyValues item, int index, const char[] name, int &count, bool auto)
{
	HashCheck();

	if(equipped)
		return Item_Off;
	
	Store_EquipItem(client, item, index, name, auto);
	return Item_On;
}

public void TextStore_OnDescItem(int client, int item, char[] desc)
{
	static char buffer[256];
	KeyValues kv = TextStore_GetItemKv(item);
	if(kv)
	{
		kv.GetString("plugin", buffer, sizeof(buffer));
		if(StrEqual(buffer, "rpg_fortress"))
		{
			GetDisplayString(kv.GetNum("level"), buffer, sizeof(buffer));
			Format(desc, 512, "%s\n%s", desc, buffer);
			
			float val = kv.GetFloat("oredmg");
			if(val > 0)
			{
				int tier = kv.GetNum("oretier");
				if(tier < sizeof(MiningLevels))
				{
					Format(desc, 512, "%s\nMining Level: %s\nMining Efficiency: %.2f%%", desc, MiningLevels[tier], val);
				}
				else
				{
					Format(desc, 512, "%s\nMining Level: %d\nMining Efficiency: %.2f%%", desc, tier, val);
				}
			}
			
			val = kv.GetFloat("fishchance");
			if(val > 0)
			{
				int tier = kv.GetNum("fishtier", 3);
				if(tier < sizeof(FishingLevels))
				{
					Format(desc, 512, "%s\nFishing Level: %s\nFishing Efficiency: %.2f%%", desc, FishingLevels[tier], val*100.0);
				}
				else
				{
					Format(desc, 512, "%s\nFishing Level: %d\nFishing Efficiency: %.2f%%", desc, tier, val*100.0);
				}
			}

			static int attrib[16];
			static float value[16];
			static char buffers[32][16];

			kv.GetString("attributes", buffer, sizeof(buffer));
			int count = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])) / 2;
			for(int i; i < count; i++)
			{
				attrib[i] = StringToInt(buffers[i*2]);
				if(!attrib[i])
				{
					count = i;
					break;
				}
				
				value[i] = StringToFloat(buffers[i*2+1]);
			}
			
			kv.GetString("classname", buffer, sizeof(buffer));
			Config_CreateDescription(buffer, attrib, value, count, desc, 512);
		}
	}
}

public Action TextStore_OnClientLoad(int client, char file[PLATFORM_MAX_PATH])
{
	RequestFrame(TextStore_LoadFrame, GetClientUserId(client));
	return Plugin_Continue;
}

public void TextStore_LoadFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		if(TextStore_GetClientLoad(client))
		{
			HashCheck();
			LoadItems(client);
		}
		else
		{
			RequestFrame(TextStore_LoadFrame, userid);
		}
	}
}

static void LoadItems(int client)
{
	char buffer[48];
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		TextStore_GetItemName(i, buffer, sizeof(buffer));
		if(StrEqual(buffer, ITEM_XP, false))
		{
			TextStore_GetInv(client, i, XP[client]);
			ItemXP = i;
		}
		else if(StrEqual(buffer, ITEM_TIER, false))
		{
			TextStore_GetInv(client, i, Tier[client]);
			ItemTier = i;
		}
	}

	Level[client] = XpToLevel(XP[client]);
	int cap = GetLevelCap(Tier[client]);
	if(Level[client] > cap)
		Level[client] = cap;
}

void TextStore_AddXP(int client, int xp)
{
	HashCheck();
	if(ItemXP != -1)
	{
		TextStore_GetInv(client, ItemXP, XP[client]);
		XP[client] += xp;
		TextStore_SetInv(client, ItemXP, XP[client]);
	}
}

stock void TextStore_AddTier(int client)
{
	HashCheck();
	if(ItemTier != -1)
	{
		TextStore_GetInv(client, ItemTier, Tier[client]);
		Tier[client]++;
		TextStore_SetInv(client, ItemTier, Tier[client]);
	}
}

void TextStore_ZoneEnter(int client, const char[] name)
{
	static StoreEnum store;
	if(StoreList.GetArray(name, store, sizeof(store)))
	{
		if(store.EntRef == INVALID_ENT_REFERENCE)
		{
			store.Spawn();
			StoreList.SetArray(name, store, sizeof(store));
		}
		
		store.PlayEnter(client);
		strcopy(InStore[client], sizeof(InStore[]), name);
		FakeClientCommand(client, "sm_buy");
	}
}

void TextStore_ZoneLeave(int client, const char[] name)
{
	if(InStore[client][0] && StrEqual(name, InStore[client]))
	{
		InStore[client][0] = 0;
		CancelClientMenu(client);
	}
}

void TextStore_ZoneAllLeave(const char[] name)
{
	static StoreEnum store;
	if(StoreList.GetArray(name, store, sizeof(store)))
	{
		store.Despawn();
		StoreList.SetArray(name, store, sizeof(store));
	}
}

public Action TextStore_OnSellItem(int client, int item, int cash, int &count, int &sell)
{
	if(InStore[client][0])
		return Plugin_Continue;
	
	SPrintToChat(client, "You must sell this in a shop!");
	return Plugin_Handled;
}

public Action TextStore_OnMainMenu(int client, Menu menu)
{
	if(!InStore[client][0])
		menu.RemoveItem(0);
	
	return Plugin_Continue;
}

public void TextStore_OnCatalog(int client)
{
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		KeyValues kv = TextStore_GetItemKv(i);
		if(kv)
		{
			static char buffer[128];
			kv.GetString("storetags", buffer, sizeof(buffer));
			if(buffer[0])
				kv.SetNum("hidden", StrContains(buffer, InStore[client], false) == -1 ? 1 : 0);
		}
	}
}

void TextStore_EntityCreated(int entity)
{
	ItemCount[entity] = 0;
	StoreWeapon[entity][0] = 0;
}

void TextStore_DropCash(float pos[3], int amount)
{
	DropItem(-1, pos, amount);
}

void TextStore_DropNamedItem(const char[] name, float pos[3], int amount)
{
	int length = TextStore_GetItems();
	for(int i; i < length; i++)
	{
		static char buffer[48];
		if(TextStore_GetItemName(i, buffer, sizeof(buffer)) && StrEqual(buffer, name, false))
		{
			DropItem(i, pos, amount);
		}
	}
}

static void DropItem(int index, float pos[3], int amount)
{
	KeyValues kv = index == -1 ? null : TextStore_GetItemKv(index);
	if(kv || index == -1)
	{
		float ang[3];
		static char buffer[PLATFORM_MAX_PATH];

		int entity = MaxClients + 1;
		while((entity = FindEntityByClassname(entity, "prop_physics_multiplayer")) != -1)
		{
			if(ItemCount[entity] && ItemIndex[entity] == index)
			{
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", ang);
				if(GetVectorDistance(pos, ang, true) < 100000.0)
				{
					ItemCount[entity] += amount;
					UpdateItemText(entity, index, kv);
					return;
				}
			}
		}

		if(GetEntityCount() > 1850)
			return;

		if(index == -1)
		{
			strcopy(buffer, sizeof(buffer), "models/items/currencypack_small.mdl");
		}
		else
		{
			kv.GetString("model", buffer, sizeof(buffer), "models/items/currencypack_small.mdl");
		}

		if(buffer[0])
		{
			PrecacheModel(buffer);

			entity = CreateEntityByName("prop_physics_multiplayer");
			if(entity != -1)
			{
				DispatchKeyValue(entity, "model", buffer);
				DispatchKeyValue(entity, "physicsmode", "2");
				DispatchKeyValue(entity, "massScale", "1.0");
				DispatchKeyValue(entity, "spawnflags", "2");
				DispatchKeyValue(entity, "targetname", "rpg_item");

				if(index != -1)
				{
					ang[0] = GetRandomFloat(0.0, 360.0);
					ang[2] = GetRandomFloat(0.0, 360.0);
				}

				ang[1] = GetRandomFloat(0.0, 360.0);

				static float vel[3];
				vel[0] = GetRandomFloat(-160.0, 160.0);
				vel[1] = GetRandomFloat(-160.0, 160.0);
				vel[2] = GetRandomFloat(0.0, 160.0);

				pos[2] += 20.0;
				TeleportEntity(entity, pos, NULL_VECTOR, vel);

				DispatchSpawn(entity);
				SetEntityCollisionGroup(entity, 2);

				int color[4] = {255, 255, 255, 255};
				if(index != -1)
				{
					int alpha = 255;
					kv.GetColor("color", color[0], color[1], color[2], alpha);
					SetEntityRenderColor(entity, color[0], color[1], color[2], alpha);

					for(int i; i < sizeof(color); i++)
					{
						color[i] = 128 + color[i] / 2;
					}
				}

				ItemIndex[entity] = index;
				ItemCount[entity] = amount;
				ItemLifetime[entity] = GetGameTime() + 30.0;

				if(index == -1)
				{
					strcopy(buffer, sizeof(buffer), "Credits");
				}
				else
				{
					TextStore_GetItemName(index, buffer, sizeof(buffer));
				}
				
				if(amount != 1)
					Format(buffer, sizeof(buffer), "%s x%d", buffer, amount);
				
				i_TextEntity[entity][0] = EntIndexToEntRef(SpawnFormattedWorldText(buffer, {0.0, 0.0, 30.0}, amount == 1 ? 5 : 6, color, entity,_,true));
			}
		}
	}
}

static void UpdateItemText(int entity, int index, KeyValues kv)
{
	ItemLifetime[entity] = GetGameTime() + 30.0;
	
	int text = EntRefToEntIndex(i_TextEntity[entity][0]);
	if(text != INVALID_ENT_REFERENCE)
		RemoveEntity(text);
	
	static char buffer[64];			
	if(index == -1)
	{
		strcopy(buffer, sizeof(buffer), "Credits");
	}
	else
	{
		TextStore_GetItemName(index, buffer, sizeof(buffer));
	}
	
	Format(buffer, sizeof(buffer), "%s x%d", buffer, ItemCount[entity]);

	int color[4] = {255, 255, 255, 255};
	if(index != -1)
	{
		kv.GetColor("color", color[0], color[1], color[2], text);
		
		for(int i; i < sizeof(color); i++)
		{
			color[i] = 128 + color[i] / 2;
		}
	}

	i_TextEntity[entity][0] = EntIndexToEntRef(SpawnFormattedWorldText(buffer, {0.0, 0.0, 30.0}, 6, color, entity, ItemCount[entity] > 99,true));
}

static int GetBackpackSize(int client)
{
	int amount;

	static BackpackEnum pack;
	int length = Backpack.Length;
	for(int i; i < length; i++)
	{
		Backpack.GetArray(i, pack);
		if(pack.Owner == client && pack.Item != -1)
			amount += pack.Amount;
	}

	return amount;
}

void TextStore_DespoitBackpack(int client, bool death)
{
	float pos[3];
	int amount;
	int cash;

	if(death)
		GetClientAbsOrigin(client, pos);
	
	for(int i = Backpack.Length - 1; i >= 0; i--)
	{
		static BackpackEnum pack;
		Backpack.GetArray(i, pack);
		if(pack.Owner == client)
		{
			if(death)
			{
				DropItem(pack.Item, pos, pack.Amount);

				if(pack.Item == -1)
				{
					cash = pack.Amount;
				}
				else
				{
					amount += pack.Amount;
				}
			}
			else if(pack.Item == -1)
			{
				TextStore_Cash(client, pack.Amount);
			}
			else
			{
				TextStore_GetInv(client, pack.Item, amount);
				TextStore_SetInv(client, pack.Item, pack.Amount + amount);
			}

			Backpack.Erase(i);
		}
	}

	if(cash && amount)
	{
		SPrintToChat(client, "You have dropped %d credits and %d items", cash, amount);
	}
	else if(cash)
	{
		SPrintToChat(client, "You have dropped %d credits", cash);
	}
	else if(amount)
	{
		SPrintToChat(client, "You have dropped %d items", amount);
	}
}

bool TextStore_Interact(int client, int entity, bool reload)
{
	if(ItemCount[entity])
	{
		if(reload)
		{
			int weight = GetBackpackSize(client) - 1 - Tier[client];

			int i, strength;
			while(TF2_GetItem(client, strength, i))
			{
				weight += 1 + Tier[client];
			}

			strength = Stats_BaseCarry(client);
			if(weight > strength)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client, "ico_notify_highfive", 0, "You can't carry any more items (%d / %d)", weight, strength);

				if(Level[client] < 6)
				{
					SPrintToChat(client, "TIP: Head over to a shop to deposit your backpack");
				}
				else if((Level[client] == 10 && Tier[client] == 0) || (Level[client] == 30 && Tier[client] == 1))
				{
					SPrintToChat(client, "TIP: You can carry 10 more items for each elite level up");
				}
				else if(Level[client] < 30)
				{
					SPrintToChat(client, "TIP: Switch to your backpack to drop items you don't need");
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/gift_pickup.wav");
				
				int amount = strength - weight;
				if(ItemIndex[entity] == -1)
					amount *= 1000;
				
				if(amount > ItemCount[entity])
					amount = ItemCount[entity];
				
				bool found;
				static BackpackEnum pack;
				int length = Backpack.Length;
				for(i = 0; i < length; i++)
				{
					Backpack.GetArray(i, pack);
					if(pack.Owner == client && pack.Item == ItemIndex[entity])
					{
						pack.Amount += amount;
						Backpack.SetArray(i, pack);

						found = true;
						break;
					}
				}

				if(!found)
				{
					pack.Owner = client;
					pack.Item = ItemIndex[entity];
					pack.Amount = amount;
					Backpack.PushArray(pack);
				}
				
				if(amount == ItemCount[entity])
				{
					int text = EntRefToEntIndex(i_TextEntity[entity][0]);
					if(text != INVALID_ENT_REFERENCE)
						RemoveEntity(text);
					
					i_TextEntity[entity][0] = INVALID_ENT_REFERENCE;
					ItemCount[entity] = 0;
					RemoveEntity(entity);
				}
				else
				{
					UpdateItemText(entity, ItemIndex[entity], ItemIndex[entity] == -1 ? null : TextStore_GetItemKv(ItemIndex[entity]));
				}
			}
			return true;
		}
		else if(Level[client] < 8)
		{
			SPrintToChat(client, "TIP: Press RELOAD (R) to pick up an item");
			return true;
		}
	}
	return false;
}

public Action TextStore_ItemTimer(Handle timer)
{
	float gameTime = GetGameTime();

	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "prop_physics_multiplayer")) != -1)
	{
		if(ItemCount[entity] && ItemLifetime[entity] < gameTime)
		{
			int text = EntRefToEntIndex(i_TextEntity[entity][0]);
			if(text != INVALID_ENT_REFERENCE)
				RemoveEntity(text);
			
			i_TextEntity[entity][0] = INVALID_ENT_REFERENCE;
			ItemCount[entity] = 0;
			RemoveEntity(entity);
		}
	}

	return Plugin_Continue;
}

void TextStore_WeaponSwitch(int client, int weapon)
{
	if(weapon != -1 && StrEqual(StoreWeapon[weapon], "Backpack"))
	{
		MenuType[client] = MENU_BACKPACK;
		RefreshAt[client] = 1.0;
	}
	else if(MenuType[client] == MENU_BACKPACK)
	{
		MenuType[client] = MENU_WEAPONS;
	}

	if(MenuType[client] == MENU_WEAPONS)
		RefreshAt[client] = 1.0;
}

void TextStore_PlayerRunCmd(int client)
{
	if((InMenu[client] || GetClientMenu(client) == MenuSource_None) && IsPlayerAlive(client))
	{
		if(InMenu[client])
		{
			switch(MenuType[client])
			{
				case MENU_SPELLS:
				{
					float gameTime = GetGameTime();
					if(RefreshAt[client] < gameTime)
					{
						gameTime += 1.0;
						if(RefreshAt[client] < gameTime)
						{
							RefreshAt[client] = gameTime;
						}
						else
						{
							RefreshAt[client] += 1.0;
						}
					}
				}
				default:
				{
					if(!RefreshAt[client])
						return;
					
					RefreshAt[client] = 0.0;
				}
			}
		}
		
		ShowMenu(client);
	}
}

static void ShowMenu(int client)
{
	switch(MenuType[client])
	{
		case MENU_WEAPONS:
		{
			Menu menu = new Menu(TextStore_BackpackMenu);

			menu.SetTitle("RPG Fortress\n \nItems:");
			
			int backpack = -1;
			int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			int amount;
			char index[16];

			int i, entity;
			while(TF2_GetItem(client, entity, i))
			{
				if(StrEqual(StoreWeapon[entity], "Backpack"))
				{
					backpack = entity;
				}
				else
				{
					IntToString(EntIndexToEntRef(entity), index, sizeof(index));
					menu.AddItem(index, StoreWeapon[entity], entity == active ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
					amount++;
				}
			}

			while(amount < 8)
			{
				menu.AddItem("-1", "");
				amount++;
			}

			if(backpack == -1)
			{
				menu.AddItem("-1", "Backpack", ITEMDRAW_DISABLED);
			}
			else
			{
				IntToString(EntIndexToEntRef(backpack), index, sizeof(index));
				menu.AddItem(index, "Backpack", backpack == active ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}

			//menu.AddItem("-1", "Spells");

			menu.Pagination = 0;
			InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
		}
		case MENU_SPELLS:
		{
			InMenu[client] = false;
		}
		case MENU_BACKPACK:
		{
			Menu menu = new Menu(TextStore_BackpackMenu);

			int amount;
			bool found;
			int length = Backpack.Length;
			for(int i; i < length; i++)
			{
				static BackpackEnum pack;
				Backpack.GetArray(i, pack);
				if(pack.Owner == client)
				{
					static char index[16], name[64];
					IntToString(pack.Item, index, sizeof(index));

					if(pack.Item == -1)
					{
						strcopy(name, sizeof(name), "Credits");
					}
					else
					{
						TextStore_GetItemName(pack.Item, name, sizeof(name));
					}
					
					if(pack.Amount != 1)
						Format(name, sizeof(name), "%s x%d", name, pack.Amount);
					
					if(pack.Item == -1)
					{
						if(amount)
						{
							menu.InsertItem(0, index, name);
						}
						else
						{
							menu.AddItem(index, name);
						}
					}
					else
					{
						menu.AddItem(index, name);
						amount += pack.Amount;
					}

					found = true;
				}
			}

			if(!found)
				menu.AddItem(NULL_STRING, "Empty", ITEMDRAW_DISABLED);

			amount -= 1 + Tier[client];
			
			int i;
			while(TF2_GetItem(client, length, i))
			{
				amount += 1 + Tier[client];
			}

			menu.SetTitle("RPG Fortress\n \nBackpack (%d / %d):", amount, Stats_BaseCarry(client));

			InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
		}
		default:
		{
			InMenu[client] = false;
		}
	}
}

public int TextStore_WeaponMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;
		}
		case MenuAction_Select:
		{
			if(choice == 9)
			{
				MenuType[client] = MENU_SPELLS;
			}
			else if(IsPlayerAlive(client))
			{
				char num[16];
				menu.GetItem(choice, num, sizeof(num));

				int entity = EntRefToEntIndex(StringToInt(num));
				if(entity != INVALID_ENT_REFERENCE)
					Store_SwapToItem(client, entity);
			}

			ShowMenu(client);
		}
	}
	return 0;
}

public int TextStore_BackpackMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			InMenu[client] = false;

			switch(choice)
			{
				case MenuCancel_ExitBack:
				{
					FakeClientCommandEx(client, "sm_inv");
				}
				case MenuCancel_Exit:
				{
					ClientCommand(client, "lastinv");
				}
			}
		}
		case MenuAction_Select:
		{
			if(IsPlayerAlive(client))
			{
				char num[16];
				menu.GetItem(choice, num, sizeof(num));

				int index = StringToInt(num);

				int length = Backpack.Length;
				for(int i; i < length; i++)
				{
					static BackpackEnum pack;
					Backpack.GetArray(i, pack);
					if(pack.Owner == client && pack.Item == index)
					{
						float pos[3];
						GetClientEyePosition(client, pos);
						if(pack.Item == -1)
						{
							length = pack.Amount % 1000;
							if(!length)
								length = 1000;
							
							DropItem(index, pos, length);
							pack.Amount -= length;
						}
						else
						{
							DropItem(index, pos, 1);
							pack.Amount--;
						}

						if(pack.Amount)
						{
							Backpack.SetArray(i, pack);
						}
						else
						{
							Backpack.Erase(i);
						}
						break;
					}
				}
			}

			ShowMenu(client);
		}
	}
	return 0;
}