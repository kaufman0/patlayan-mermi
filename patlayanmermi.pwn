/*

    Patlayan Mermi Sistemi, chinohead tarafindan

    Özellikler:
     - Bu sistem ile ateş ettiğiniz pozisyonda patlama oluşuyor.
     - Patlayan mermi miktarı sağ üstte bar yardımı ile gösteriliyor.
     - Yardımları için erorcun'a teşekkür ederim.

*/

#include <a_samp>
#include <zcmd> 			// https://forum.sa-mp.com/showthread.php?t=91354
#include <progress2>    		// https://github.com/Southclaws/progress2

#define EXP_WEAPON		(25)    // https://wiki.sa-mp.com/wiki/Weapons
#define MAX_BULLET		(5)     // verilecek patlayan mermi miktarı

enum e_BulletData
{
	BulletCounter,
	BulletLimit[MAX_PLAYERS],
	BulletStatus[MAX_PLAYERS],
	PlayerText: BulletText[2],
	PlayerBar: BulletBar[MAX_PLAYERS]
};

new Bullet[MAX_PLAYERS][e_BulletData];
public OnPlayerConnect(playerid)
{
	Bullet[playerid][BulletBar] = CreatePlayerProgressBar(playerid, 500.000000, 17.000000, 43.000000, 3.200000, 16711935, 5.0000, 0);
	Bullet[playerid][BulletStatus] = 0;
	Bullet[playerid][BulletCounter] = 0;
	Bullet[playerid][BulletText][0] = CreatePlayerTextDraw(playerid,500.000000, 7.000000, "PATLAYAN MERMI");
	PlayerTextDrawBackgroundColor(playerid, Bullet[playerid][BulletText][0], 100);
	PlayerTextDrawFont(playerid, Bullet[playerid][BulletText][0], 1);
	PlayerTextDrawLetterSize(playerid, Bullet[playerid][BulletText][0], 0.140000, 0.799999);
	PlayerTextDrawColor(playerid, Bullet[playerid][BulletText][0], -1);
	PlayerTextDrawSetOutline(playerid, Bullet[playerid][BulletText][0], 1);
	PlayerTextDrawSetProportional(playerid, Bullet[playerid][BulletText][0], 1);
	PlayerTextDrawSetSelectable(playerid, Bullet[playerid][BulletText][0], 0);
	Bullet[playerid][BulletText][1] = CreatePlayerTextDraw(playerid,488.000000, 4.000000, "ld_grav:flwr");
	PlayerTextDrawBackgroundColor(playerid, Bullet[playerid][BulletText][1], 100);
	PlayerTextDrawFont(playerid, Bullet[playerid][BulletText][1], 4);
	PlayerTextDrawLetterSize(playerid, Bullet[playerid][BulletText][1], -0.479999, -11.199999);
	PlayerTextDrawColor(playerid, Bullet[playerid][BulletText][1], -1);
	PlayerTextDrawSetOutline(playerid, Bullet[playerid][BulletText][1], 1);
	PlayerTextDrawSetProportional(playerid, Bullet[playerid][BulletText][1], 1);
	PlayerTextDrawUseBox(playerid, Bullet[playerid][BulletText][1], 1);
	PlayerTextDrawBoxColor(playerid, Bullet[playerid][BulletText][1], 255);
	PlayerTextDrawTextSize(playerid, Bullet[playerid][BulletText][1], 12.000000, 13.000000);
	PlayerTextDrawSetSelectable(playerid, Bullet[playerid][BulletText][1], 0);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Bullet[playerid][BulletStatus] = 0;
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if (Bullet[playerid][BulletStatus] == 1 && GetPlayerWeapon(playerid) == EXP_WEAPON)
	{
		if (Bullet[playerid][BulletLimit] <= MAX_BULLET)
		{
			Bullet[playerid][BulletLimit]++;
			CreateExplosion(fX, fY, fZ, 12, 10.0);
			SetPlayerProgressBarValue(playerid, Bullet[playerid][BulletBar], Bullet[playerid][BulletLimit]);
		}
		if (Bullet[playerid][BulletLimit] == MAX_BULLET)
		{
			Bullet[playerid][BulletStatus] = 0;
			Bullet[playerid][BulletLimit] = 0;
			PlayerTextDrawHide(playerid, Bullet[playerid][BulletText][0]);
			PlayerTextDrawHide(playerid, Bullet[playerid][BulletText][1]);
			HidePlayerProgressBar(playerid, Bullet[playerid][BulletBar]);
			SetPlayerProgressBarValue(playerid, Bullet[playerid][BulletBar], 0);
			GameTextForPlayer(playerid, "~r~mermi bitti!", 2000, 4);
		}
	}
	return 1;
}

forward CreateBullet(playerid);
public CreateBullet(playerid)
{
	Bullet[playerid][BulletCounter]--;
	if(Bullet[playerid][BulletCounter] == 0)
	{
		Bullet[playerid][BulletStatus] = 1;
		GameTextForPlayer(playerid, "~r~patlayan mermi uretildi!", 2000, 4);
		for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
		{
			if(!IsPlayerConnected(i)) continue;
			PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
		}
		return 1;
	}else
	{
		new text[7];
		format(text, sizeof(text), "~w~%d", Bullet[playerid][BulletCounter]);
		for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
		{
			if(!IsPlayerConnected(i)) continue;
			PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
		}
		GameTextForPlayer(playerid, text, 1110, 4);
	}
	SetTimerEx("CreateBullet", 1000, false, "i", playerid);
	return 1;
}

CMD:patlayanmermi(playerid)
{
	if(Bullet[playerid][BulletStatus] == 0)
	{
		if(GetPlayerWeapon(playerid) == EXP_WEAPON)
		{
			Bullet[playerid][BulletStatus] = 0;
			PlayerTextDrawShow(playerid, Bullet[playerid][BulletText][0]);
			PlayerTextDrawShow(playerid, Bullet[playerid][BulletText][1]);
			ShowPlayerProgressBar(playerid, Bullet[playerid][BulletBar]);
			if (Bullet[playerid][BulletCounter] == 0)
			{
				Bullet[playerid][BulletCounter] = 11;
				SetTimerEx("CreateBullet", 1000, false, "i", playerid);
			}
		}
		else SendClientMessage(playerid, -1, "[HATA] Patlayan mermi üretebilmek için elinde Shotgun bulundurmalisin.");
	}
	else SendClientMessage(playerid, -1, "[HATA] Zaten patlayan mermi üretmişsin.");
	return 1;
}
