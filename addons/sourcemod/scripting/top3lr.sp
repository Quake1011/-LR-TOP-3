#pragma newdecls required
#pragma semicolon 1

#include <lvl_ranks>
#include <csgo_colors>

Database db;
bool bStatus[8];
float fDelay;

public Plugin myinfo = 
{ 
	name = "[LR] TOP-3", 
	author = "Palonez", 
	description = "Printing random TOP-3 list of selected column in db", 
	version = "1.0", 
	url = "https://github.com/Quake1011" 
};

public void OnPluginStart()
{
	KeyValues kv = CreateKeyValues("top3lr");
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/top3lr.ini");
	if(kv.ImportFromFile(path))
	{
		bStatus[0] = !!kv.GetNum("Опыт");
		bStatus[1] = !!kv.GetNum("Ранг");
		bStatus[2] = !!kv.GetNum("Убийства");
		bStatus[3] = !!kv.GetNum("Смерти");
		bStatus[4] = !!kv.GetNum("Выстрелы");
		bStatus[5] = !!kv.GetNum("Попадания");
		bStatus[6] = !!kv.GetNum("HS");
		bStatus[7] = !!kv.GetNum("Время");
		
		fDelay = kv.GetFloat("Задержка");
	}
	
	CreateTimer(fDelay, Updater, _, TIMER_REPEAT);
	
	LoadTranslations("top3lr.phrases");
}

public Action Updater(Handle hTimer)
{
	if(bStatus[0] == bStatus[1] == bStatus[2] == bStatus[3] == bStatus[4] == bStatus[5] == bStatus[6] == bStatus[7] == false)
		return Plugin_Continue;

	int random = GetRandomInt(0, sizeof(bStatus) - 1);
	while(!bStatus[random])
		random = GetRandomInt(0, sizeof(bStatus) - 1);

	char vrnt[2][32], bf[1024], buffer[256];
	switch(random)
	{
		case 0: 
		{
			vrnt[0] = "value";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph1");
		}
		case 1:
		{
			vrnt[0] = "rank";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph2");
		}
		case 2: 
		{
			vrnt[0] = "kills";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph3");
		}
		case 3: 
		{
			vrnt[0] = "deaths";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph4");
		}
		case 4: 
		{
			vrnt[0] = "shoots";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph5");
		}
		case 5: 
		{
			vrnt[0] = "hits";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph6");
		}
		case 6: 
		{
			vrnt[0] = "headshots";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph7");
		}
		case 7: 
		{
			vrnt[0] = "playtime";
			Format(vrnt[1], sizeof(vrnt[]), "%t", "ph8");
		}
	}

	db = view_as<Database>(LR_GetDatabase());
	Format(bf, sizeof(bf), "SELECT `name`, `%s` FROM `lvl_base` ORDER BY `%s` DESC LIMIT 3", vrnt[0], vrnt[0]);
	DBResultSet result = SQL_Query(db, bf);
	
	Format(bf, sizeof(bf), "%t %s\n", "ph9", vrnt[1]);
	if(result != null && result.HasResults)
	{
		if(result.RowCount)
		{
			int i = 1;
			char name[MAX_NAME_LENGTH];
			result.FetchRow();
			do
			{
				result.FetchString(0, name, sizeof(name));
				if(random == 7) Format(buffer, sizeof(buffer), "{OLIVE}%d. {DEFAULT}%s - {GREEN}%dd%dh%dm%ds\n", i, name, result.FetchInt(1)/3600/24, result.FetchInt(1)/3600%24, result.FetchInt(1)/60%60, result.FetchInt(1)%60);
				else Format(buffer, sizeof(buffer), "{OLIVE}%d. {DEFAULT}%s - {GREEN}%d\n", i, name, result.FetchInt(1));
				StrCat(bf, sizeof(bf), buffer);
				i++;
			} while(result.FetchRow());
		}
	}
	
	delete result;
	
	TrimString(bf);
	CGOPrintToChatAll(bf);
	return Plugin_Continue;
}
