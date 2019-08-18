/*
 *  Patlayan mermi sistemi, chinohead tarafýndan
 *
 *  Özellikler:
 *  - Bu sistem ile ateþ ettiðiniz pozisyonda patlama oluþuyor.
 *  - Patlayan mermi miktarý sað üstte bar yardýmý ile gösteriliyor.
 *  - Yardýmlarý için erorcun ve Vengeance'a teþekkürler.
*/

#include <a_samp>
#include <zcmd> 				// https://forum.sa-mp.com/showthread.php?t=91354
#include <progress2>    		// https://github.com/Southclaws/progress2

#define EXP_WEAPON		(25)    // https://wiki.sa-mp.com/wiki/Weapons
#define MAX_BULLET		(5)     // Patlayan mermi miktarý

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
    
    if (Bullet[playerid][BulletCounter] == 0)
	{
		Bullet[playerid][BulletStatus] = 1;
		
		GameTextForPlayer(playerid, "~r~patlayan mermi uretildi!", 2000, 4);
		
		for(new i; i < MAX_PLAYERS; i++)
		{
		    PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		}
		return 0;
	}
	else
	{
	    new text[7];
	    format(text, sizeof(text), "~w~%d", Bullet[playerid][BulletCounter]);

		for(new i; i < MAX_PLAYERS; i++)
		{
		    PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
		}
		GameTextForPlayer(playerid, text, 1110, 4);
	}
	SetTimer("CreateBullet", 1000, 0);
	return 0;
}

CMD:patlayanmermi(playerid)
{
	if (Bullet[playerid][BulletStatus] == 0)
	{
		if (GetPlayerWeapon(playerid) == EXP_WEAPON)
		{
			Bullet[playerid][BulletStatus] = 0;
			
			PlayerTextDrawShow(playerid, Bullet[playerid][BulletText][0]);
			PlayerTextDrawShow(playerid, Bullet[playerid][BulletText][1]);
            ShowPlayerProgressBar(playerid, Bullet[playerid][BulletBar]);

			if (Bullet[playerid][BulletCounter] == 0)
			{
            	Bullet[playerid][BulletCounter] = 11;
				SetTimer("CreateBullet", 1000, 0);
			}
		}
		else SendClientMessage(playerid, -1, "[HATA] Patlayan mermi üretebilmek için elinde Shotgun bulundurmalýsýn.");
	}
	else SendClientMessage(playerid, -1, "[HATA] Zaten patlayan mermi üretmiþsin.");
	return 1;
}
