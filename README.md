# BO1-Reimagined-Expanded
BO1 Reimagined-Expanded is a Call of Duty Black Ops 1 Zombies Mod for owners of Black Ops 1 on PC.



## Overview

Black Ops 1 Reimagined-Expanded Zombies is a mod designed to enhance gameplay features and mechanics of the classic Black Ops 1 and WaW style COD 
zombies with features such as Double Pack-a-Punch, Upgradable Perks, collision mechanics, rebalancing to the weapons and zombies and quality of life
changes. It is intentionally built on top of the excellent and well received [Black Ops 1 Reimagined Mod](https://github.com/Jbleezy/BO1-Reimagined) by Jbleezy.


## Table Of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Apocalypse Mode](#apocalypse-mode)
4. [Showcases](#showcases)
5. [Credits](#credits)
6. [Official Changelog](#official-changelog)
7. [Bugs and Feedback](#bugs-and-feedback)


## Features

### Double Pack-a-Punch

Added double Pack-a-Punch for *most* guns in Black Ops Zombies. Most of the wonder weapons and wall weapons are exceptions. Double Pack-a-Punch weapons have the following bonuses:


  - Flat 2x damage increase from their single upgraded version
  - One of four bullet effects:
      - Hellfire - Sets zombie on fire and kills it after 2 seconds, zombies killed by Hellfire drop Hellfire on the ground that can affect other zombies
      - Sheercold - Slows zombies within a close range to the player. Emits a frost effect.
      - Eletrify - Bullets shock zombies, instantly killing them and nearby enemies
      - Extra damage - An additional 20% boost to damage, or additional headshot multiplier.
   
    <details>
     <summary><b>Hellfire Weapons</b></summary>
    
    - PPSh
    - RPK
    - AK47_FT
    - Rottweil72
    
    </details>
    
    <details>
    <summary><b>Sheercold Weapons</b></summary>
    
    - Spectre
    - HK21
    - Galil
    
    </details>
    
    <details>
    <summary><b>Shock Weapons</b></summary>
    
    - AK74u
    - AUG ACOG MK
    - FAMAS
    - Balistic Knife
    
    </details>
    
    
    <details>
    <summary><b>Big Damage</b></summary>
    
    - Commando
    - Stoner63
    - FN FAL
    - M14
    - PSG1
    - L96A1
    
    </details>
    
    <details>
    <summary><b>Double PaP Blacklisted Weapons</b></summary>
    - Microwave Gun DW
    - Microwave Gun
    - Tesla Gun Power-Up
    - Tesla Gun
    - Thundergun
    - Ray Gun
    - Starburst Ray Gun
    - Freeze Gun
    - "Baby Gun"
    - Human Gun [Human Gun]
    - Scavenger (No double PaP WaW weapons)
    - M14
    - MPL
    - MP5K
    - MP40
    - AK74u
    - PM63
    - Rottweil72
    - M16 GL
    - GL M16
    - Ithaca
    - MK AUG
    - M72 LAW
    - China Lake
    - No "WaW weapons" may be double PaP
    </details>

![Pack a Punch Bullet Effects Demo](https://s3.amazonaws.com/your-bucket-name/path/to/your/gif.gif)

### Upgradable Perks - "PerkaPunch"

  _**"PerkaPunch"ed**_ perks are permament. And come with the following special effects:
  
  **Juggernog:**
  - Set pro perk
  - Player Max Health now 325
  
  **Quick Revive:**
  - Set pro perk
  - Trigger zombie blood for revived players
  - Larger revive radius for QR
  
  **Speed Cola:**
  - Set pro perk
  - Can't speed up reload or anything, those times are set
  - Magic reload
    - After 3.5 seconds, your secondary gun is reloaded for you
    - Send pulse when reloading that slows time around you (Not Implemented)
  
  **Double Tap:**
  - Set pro perk
  - Provides bullet penetration of up to 6 zombies
  
  **Stamina:**
  - Set pro perk
  - Further speed increase, look into SetPlayerMoveSpeed (Not Implemented)
  - When you sprint, go into a ghost mode for 2 seconds
    - Add zombie blood
    - Trigger zombie blood fx for 2 seconds
    - All zombies in radius, collision off for 2 seconds
  
  **Phd:**
  - Set pro perk
  - Larger splash area and damage with all explosive weapons and flop
  - Longer lasting Hellfire
  
  **Deadshot:**
  - Set pro perk
  - Base 1.5 damage increase when ADS on bullet weapons
  - Hitmarkers on hitting zombies
  - Red hitmarker on hitting zombie weak spot (Not Implemented)
  - Each successive headshot or weak point hit gives your next shot an additional 5% damage, stackable
  - HUD showcases current streak (Not Implemented)
  
  **Mule Kick:**
  - Set pro perk
  - 3rd weapon permanent - don't lose perk
  - Give player max ammo on purchase
  
  **Electric Cherry (Not Implemented):**
  - Widows effect except with electricity, when zombie hits you, 30s cooldown
  - Effect always full charge
  
  **Vulture Aid (Not Implemented):**
  - See zombies' eyes around near corners, or maybe turn it on/off
  - Increase ammo recovery
  - See which zombies will produce drops

        

![Mini Perkapunch Demo](https://s3.amazonaws.com/your-bucket-name/path/to/your/gif.gif)

### Push Mechanics - Zombie Knockdown

    You may knock zombies down with your base melee attack. For about 2 seconds, their collisions are off and you may run by them. This attack still deals some damage, but your knife is in your equipment slot if you would like to use it. See an example below.

![Zombie Knockdown and Switch to Knife](https://s3.amazonaws.com/your-bucket-name/path/to/your/gif.gif)


### BabyJugg!

  BabyJugg is a buyable "PermaPerk" in each spawn room of every map, it permanently increases your health from 100->140 so you can survive up to 3 hits from zombies instead of 2.

![BabyJugg Demo](https://s3.amazonaws.com/your-bucket-name/path/to/your/gif.gif)

### Zombie Health and Weapon Balance Changes

  You may view the expected zombie health value per round and expected number of bullets to kill by weapon class [here](https://docs.google.com/spreadsheets/d/1LdMHwtOZKg7aRkDjs8t1waXxXBAzW58_5yTC6NoLz_c/edit#gid=0). The current Max Zombie Health is **200,000** reached on round 46, subject to change


<details>
<summary><b>Particular Weapon Damage</b></summary>

- **Pistols**
  - CZ75 / CZ75 Dual Wield
    - Base: **Damage**: 400, **Headshot Multiplier**: 2
    - Upgraded: **Damage**: 1000, **Headshot Multiplier**: 3.5
    - Double Upgraded: **Damage**: 4000, **Headshot Multiplier**: 3.5
  - Python
    - Base: **Damage**: 2200, **Headshot Multiplier**: 1.5
    - Upgraded: **Damage**: 5000, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 20000, **Headshot Multiplier**: 3

- **SMGS**
  - MP40
    - Base: **Damage**: 360, **Headshot Multiplier**: 2.5
    - Upgraded: **Damage**: 1100, **Headshot Multiplier**: 3
  - MPL / MP5K / PM63
    - Base: **Damage**: 320, **Headshot Multiplier**: 2
    - Upgraded: **Damage**: 1060, **Headshot Multiplier**: 3
  - PPSh / Spectre
    - Base: **Damage**: 360, **Headshot Multiplier**: 2.25
    - Upgraded: **Damage**: 1100, **Headshot Multiplier**: 3

- **Assault Rifles**
  - M14
    - Base: **Damage**: 390, **Headshot Multiplier**: 2.5
    - Upgraded: **Damage**: 1400, **Headshot Multiplier**: 3 
  - M16 GL
    - Base: **Damage**: 400, **Headshot Multiplier**: 2.5
    - Upgraded: **Damage**: 1350, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 5400, **Headshot Multiplier**: 3
  - FAMAS
    - Base: **Damage**: 50, **Headshot Multiplier**: 2.5
    - Upgraded: **Damage**: 1450, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 5800, **Headshot Multiplier**: 3
  - AK74U
    - Base: **Damage**: 50, **Headshot Multiplier**: 2.5
    - Upgraded: **Damage**: 1100, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 4400, **Headshot Multiplier**: 3
  - AUG ACOG MK
    - Base: **Damage**: 1200, **Headshot Multiplier**: 2.25
    - Upgraded: **Damage**: 1500, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 6000, **Headshot Multiplier**: 3
  - Commando / AK47 FT
    - Base: **Damage**: 100, **Headshot Multiplier**: 2.5
    - Upgraded: **Damage**: 1600, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 6400, **Headshot Multiplier**: 3
  - Galil
    - Base: **Damage**: 100, **Headshot Multiplier**: 2.5
    - Upgraded: **Damage**: 1550, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 6200, **Headshot Multiplier**: 3
  - Spectre
    - Base: **Damage**: 50, **Headshot Multiplier**: 2.25
    - Upgraded: **Damage**: 1200, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 4800, **Headshot Multiplier**: 3

- **Machineguns**
  - RPK
    - Base: **Damage**: 4000, **Headshot Multiplier**: 2
    - Upgraded: **Damage**: 1980, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 7920, **Headshot Multiplier**: 3
  - HK21
    - Base: **Damage**: 50, **Headshot Multiplier**: 2
    - Upgraded: **Damage**: 1800, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 7200, **Headshot Multiplier**: 3
  - Stoner63
    - Base: **Damage**: 100, **Headshot Multiplier**: 2
    - Upgraded: **Damage**: 2100, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 8400, **Headshot Multiplier**: 3

- **Sniper Rifles**
  - PSG1
    - Base: **Damage**: 3600, **Headshot Multiplier**: 3
    - Upgraded: **Damage**: 8500, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 34000, **Headshot Multiplier**: 3
  - L96A1
    - Base: **Damage**: 4400, **Headshot Multiplier**: 3
    - Upgraded: **Damage**: 9000, **Headshot Multiplier**: 3
    - Double Upgraded: **Damage**: 36000, **Headshot Multiplier**: 3
   
- **WaW Weapons**

	- Kar98k
		- **Base Damage**: 700, **Headshot Multiplier**: 2
		- **Upgraded**: **Damage**: 4200, **Headshot Multiplier**: 2
		- **Double Upgraded**: **Damage**: 16800, **Headshot Multiplier**: 2
	- Gewehr 43
		- **Base Damage**: 300, **Headshot Multiplier**: 2
		- **Upgraded**: **Damage**: 2240, **Headshot Multiplier**: 3
		- **Double Upgraded**: **Damage**: 6720, **Headshot Multiplier**: 3
	- M1 Carbine
		- **Base Damage**: 300, **Headshot Multiplier**: 2
		- **Upgraded**: **Damage**: 1680, **Headshot Multiplier**: 3
		- **Double Upgraded**: **Damage**: 5040, **Headshot Multiplier**: 3
	- Type 100
		- **Base Damage**: 300, **Headshot Multiplier**: 2
		- **Upgraded**: **Damage**: 1120, **Headshot Multiplier**: 3
		- **Double Upgraded**: **Damage**: 3360, **Headshot Multiplier**: 3
	- FG42
		- **Base Damage**: 200, **Headshot Multiplier**: 1.5
		- **Upgraded**: **Damage**: 1200, **Headshot Multiplier**: 3
		- **Double Upgraded**: **Damage**: 3600, **Headshot Multiplier**: 3
	- STG44
		- **Base Damage**: 200, **Headshot Multiplier**: 1.5
		- **Upgraded**: **Damage**: 1000, **Headshot Multiplier**: 3
		- **Double Upgraded**: **Damage**: 3000, **Headshot Multiplier**: 3
	- Thompson
		- **Base Damage**: 240, **Headshot Multiplier**: 2
		- **Upgraded**: **Damage**: 960, **Headshot Multiplier**: 3
		- **Double Upgraded**: **Damage**: 2880, **Headshot Multiplier**: 3
  - 
- **Shotguns**
	- Rottweil 72 (Olympia)
		- **Base Damage**: 2000 * (damage / 180)
		- **Upgraded**: **Damage**: 12500 * (damage / 300)
		- **Double Upgraded**: **Damage**: 37500 * (damage / 300)
	- Ithaca (Stakeout)
		- **Base Damage**: 3000 * (damage / 160)
		- **Upgraded**: **Damage**: 10000 * (damage / 300)
		- **Double Upgraded**: **Damage**: 30000 * (damage / 300)
	- SPAS
		- **Base Damage**: 2600 * (damage / 160)
		- **Upgraded**: **Damage**: 18000 * (damage / 300)
		- **Double Upgraded**: **Damage**: 54000 * (damage / 300)
	- HS10
		- **Base Damage**: 4200 * (damage / 160)
		- **Upgraded**: **Damage**: 17500 * (damage / 300)
		- **Double Upgraded**: **Damage**: 70000 * (damage / 300)

</details>

(End weapon damage)
---


### Shotgun Changes

  Shotguns have much improved base damage (see above) and receive a damage bonus from "attrition". For each round you own a shotgun, you do 10% more damage with all shotguns, this stacks up to 15 rounds for a maximum of 4x base damage. Moreover, shockguns will knock zombies over if they do sufficient damage but don't kill the zombie.

  
![Shotgun Zombie Knockdown](https://s3.amazonaws.com/your-bucket-name/path/to/your/gif.gif)



### Customizable Game Settings

  Most features added in Reimagined-Expanded will be toggle-able in the settings so you can opt for a more vanilla experience if you wish.

![Reimagined Customization Options](https://s3.amazonaws.com/your-bucket-name/path/to/your/gif.gif)

## Apocalypse Mode

  Apocalypse Mode offers a serious challenge for even the most hardcore zombies players. The zombies run very early and hit you very quickly. Bonus points are reduced and most of the Reimagined-Expanded bonues (Perkapunch, Double PaP) are more expensive than on normal difficulty. Zombies spawn very quickly, super-sprinters are on every map and some zombies will run even faster. Zombie bosses will spawn more frequently and zombies that go undamaged for a period of time will despawn and spawn again at full health.

  Some other changes include: (Not Implemented with Alpha Release)
  - Zombies will spawn with special abilities and resistances designated by their eye color
  - Zombies will occaisionally spawn in mini hordes of 3-5 zombies all from the same spawn location
  - Alternative bosess will be added to each map
  - Zombie "chase" algorithm will be modified to make training more difficult.


## Credits

### Special Thanks
	Jbleezy - BO1-Reimagined scripts and Assets and base repository
	Shippuden1592 - a multitude of useful scripts and assets
	Utamia - Frequent script and game mod support on Linkermod Discord
	Treyarc

### Credits:
	TescoValueRice - BO2/3 Drops and icons, UGX-Mods Discord
	John Banana - Frequent script and game mod support on UGX-Mods Discord
	Sanchez - Fx, assets and Scripts from Rennaissance/Der Reise mod
	NikolaiLovesVodka/Partisan Executioner- Rennaissance Mod scripts
	Venom - Various fx/assets
	Samhain (Discord) - BO2/3 Perk and drop icons
	Phil81334, Shippuden1592 - Cherry, Vulture, Wine assets

   Origins Staff fx:
  - Gympie6
  - Shippuden1592
  - Salamanca21
  - Cpt_johnson1
  - Bamskater
  - Harry Bo21
  - Fusorf
  - Alaurenc9
  - ConvictioNDR
  - HitmanVere
  - Lilfria
  - Redspace200
  - StevieWonder87
  - Rollonmath
  - UGX, CCM, Treyarch and Activision

## Official Changelog
Content for the Official Changelog section...

## Bugs and Feedback
Content for the Bugs and Feedback section...


