Tomasz Błądkowski   0:04
 During this session I will exlain the battle scale.
 So the buckle scape is looks like in roads like which is 2 dimensional map with only one floor invisible top down and so it's not isometric and maps are flat.
 are flat. Every tile either has a floor, something that you can walk on, or there is a there is a wall. Wall is like anything that can block movement.
 OK, remember that there might be a water which is still flat, like it's considered to be floor, but you need to fly over it, not you can't walk over it. So there are just two elements, either it's a floor or a wall.
 So battle tile doesn't have two objects, floor and a wall if the if the if the wall is destroyed.
 Then it will be changed to another type of floor. Sorry, if the wall will be destroyed and it will be converted to another type of wall and then to debris and the debris will be considered a floor. So either it's one or the other.
 The second element we have on the bubble dial is unit which can be always one. The next thing are objects like throwable items, grenades and so on. The next one is smoke, the next one is fire. And finally we have fog of war. The fog of war works like in RTS game.
 Not like in XCOM, which means there there is no light, there is no source of light. Everything is considered to be source of revealing the map like in RTS.
 For the either battle is during the date or during the night, and there's nothing in between. All units have something called site which is arranged in.
 Range of how much tiles they can uncover from fog of war in direction they are looking at. So units have four directions up, down, left, right and they can take uncover the 90 degree clone.
 In the direction they're looking at and the range is site separated for night, separated for day. It may be improved by equipment, it can be improved by by unit skills.
 But for human it's 20 and then 20 for day, 10 for night. The second parameter is sense. Sense is the same as sight, but it's only directional, which means it's it works in all direction and the range is usually like just a few tiles like 2-3.
 And in most cases it doesn't, doesn't rely on the day or night. So it's like two or three tiles in all the election every time. Both are calculated together to see what's the.
 Total sight of sight and sense range of the unit. Cover is another start that is used to reduce the enemy sense or sight. So if you have cover tool, which means you will not be detected and two tiles.
 Even if you are two tiles in range of site O that site and sense is a.
 I mean it can be blocked by terrain, so battle ties may block site line of sight partially or completely. And this is calculated by cost of sight. Cost of sight is a concept that every tile has a cost by default is 1.
 Which means if you have a range of 20 then and the cost of tile in open space is one, you will have exactly 20. Now every other element may impact it, like smoke. Smoke has a cost of three and the fire has a cost of four.
 Which means it will reduce your effective the range of sight because you need to pay more for for the tile with the smoke. Some terrains like windows, fences, bushes also may reduce it.
 By some factor by just adding a cost of site. OK, so this is how how it works. So this is cumulative with cover, which means that cover of the unit, which means you may have you may have.
 A unit that is within your range of site, but because it has cover you will see the tile but you will not see the unit.
 OK, Battlescape has four teams, 4 battle sites, which is player, which is ally to player, which is enemy to player and neutral. Neutral tries to survive, just to run away.
 Ali to player is is is not is is here to protect the the player and fight with the enemy. Enemy is to fight with everyone.
 So Ally is not designed to protect the neutral. It's on player and four sites. So there are no you can't have two enemies that will fight with each other. OK, there are just four, four sites and now the scoring system.
 And mission has an objective. My objective is to find someone, rescue someone, destroy something, I mean capture the flag, domination, whatever. And this defines how we can get points during the battle.
 To actually win it.
 So once the mission objective is set, then different actions, different aspects of what you're doing will give specific team points. So don't confuse points with score. Score is on a goscape and it's related to funding.
 Countries and points are during the battle to fulfill the mission objectives. So if it's just about.
 You know, fight with everyone and an enemy has 20 units and the goal is always to get 1000 points. So if you have 20 units then you will have 50 for every unit and that's all.
 If you if your goal is to survive 20 turns, then for every turn you will get 50 points. If you get to 1000, you win. If you will not or other side will get whoever team will get to 1000.
 Wins. Doesn't matter if it's ally, if it's an enemy, if it's neutral. By the way, neutral cannot score points.
 So now imagine capture the flag, now imagine domination, now imagine assault, now imagine just key level or detect 3 enemy units. So if you're gonna detect 3 enemy units, you need to randomly select 3 units and only these will give you 300 points per each.
 OK, in this case, killing other things doesn't really matter. If you fulfill the the mission objectives, you will be point. There might be many objectives and the same system will be also applied for AI.
 Whoever team gets the 1000 point wins and mission. Sorry battle battle is ends with the result if if it's player and then the next part is salvage.
 Which means we convert entire bottlescape into what you can get out of that.
 If you lose, you get nothing here. You might lose actually units and you have no salvage. You have no.
 So now regarding preparation, not in preparation. So first of all, if you have, if you have a mission, mission has a function.
 It will also have an objective like objective is to rescue pilot.
 Now this also define complexity of the of the mission. This is like it's not complexity, it's.
 Our of how strong is the enemy, so we need to have some stats that would define.
 Mission difficulty. So let's say 2000 point. Sorry, not not not points 2000. I need to name this variable somehow, so 2000 something.
 OK, 2000 experience points. This 2000 experience points will be used to auto build an enemy squad. How it works? You need to have few variables at the beginning, so you need to spend 2000 experience. You need to have size of the squad like from 6:00 to 9:00.
 And you need to know what kind of function it is and function defines what kind of starting unit can be used. So let's let's imagine you have 7 units and you have 2000 experience points, so you spend them on auto promote them.
 Using the standard promotion mechanism like in Battle of Westnut.
 Basically the level 1 cost 100, level 2 cost 300, level cost level 3 cost 601 thousand 1500, 2100 and so on. So this is the cost of level you you upgrade.
 You promote the units and you do it until you fulfill, until you spend all experience points and you fulfill number of units to be created. So as an output you will have a list of units that were.
 Upgraded. So remember every unit can be promoted to a few other units like Sniper 2, Sniper 2 and so on.
 And you spend experience points until everything is spent, you will have your squad. Now every every class has a default inventory and this default inventory can be also variable like you might have a weight.
 20% you will have pistol and so on. Once you have your squad, you need to apply a default inventory. So we'll have the squad and the equipment and this is all done.
 Using this mechanism of experience points, pool plus number of units, spend them, promote them and then assign them in the employer. OK, so if you have it, you need to check your you need to generate the map. So map generation will be a separate recording.
 Once you have the the the map, you need to place the units on the map. So you need to check what is the mission objective and then use something called battle grid. Sorry, it's called actually map grid.
 Which is a 2D map of map blocks. So we are not talking about tiles at the moment, we're talking about map blocks, map blocks, grid and every map block grid would have a value for for each team, kind of kind of priority for each team.
 Few map blocks would be assigned as landing zone, so for a small mission 4 by 4 it would be one, for medium 5 by 5 it would be 2, for a large 6 by 6 it would be 3.
 And for huge 7 by 7 it would be 4. So landing zones are map block grid that are dedicated for human player to deploy its units. OK, you can deploy it in in one or in in a few and everything else is considered to be.
 A sandbox for for other teams to deploy their units. So here we need to think how which units to deploy where. So if you have a map grid block that hey has higher priority for enemy ally or neutral, we will put.
 Specific number of units there in a random place. OK, so it's it's it's this work like like this. If there's things like a UFO of something like this, a base, these map map grids would have higher priority, which means it will contain more units.
 There might be a chance that there are within my same up grid. There are two within same map grid there are two.
 Units from two teams, but in general I want to have a clear, let's say, situation at the beginning about on each map block and inside the map grid.
 Has a arity for a specific team. There are four teams and when the units are deployed.
 In most cases, only units of a specific team are deployed within a single map block. So you may have those 4 units will be in this map block and once this part is done, this is called deployment. We deploy the units on the map and we can actually build build them up and then.
 Put in a random place all all those units within single map grid. So map grid is also is always 15 by 15 bottle types and then and you may have let's say 4 units in this in this area you just deploy them in random area.
 So this is how the deployment works. So first you need to do the squad, how to promote them with given number of experience points and size of the squad. Then you need to.
 Decide decide which map grid will be used to deploy them like 4 units here, 4 units then there are players doing this manually based on the landing zone. This has to include mission objectives somehow somehow.
 So once this face is done.
 This is called the deployment.
 And the next step is to just create those units in on a specific battle times and start the start the game.
 Anything come?
 Tomasz Błądkowski stopped transcrip
 
 
 
 Transcript
 October 10, 2025, 6:17AM
 Tomasz Błądkowski started transcription
 Tomasz Błądkowski   0:07
 OK, so in this I will try to explain the basic elements of Alien Fall. So we have a chaoscape, we have a base scape, we have a battle scape and we have inter interception screen.
 So again, Escape is built like we have a world map. We can switch. There are up to four worlds.
 You can switch the worlds from left to right, and each world is presented represented by a graph of provinces. So let's imagine on Earth we have like 150 provinces.
 So it more or less looks like a risk. Risk again. Provinces are connected to each other, so it builds a graph. Province has a biome which is like hills, forests and so on.
 It can be land or water.
 Biome province. So the biome is basically either water or land and the the world itself has also featured called world dial.
 World style which is not visible for user because the world image is just a background like background of Earth or something, but the tiles are used to calculate the path between the provinces, so although the.
 The services are somehow connected. They are not connected by a line, they are connected by a path and this path is calculated based on the world tiles, so path funding is used. So in general either.
 A world tile is water or land. For water cost is always one and for land either is 1-2 or three, which depends on roughness of the terrain. So now we imagine you have a craft in a province.
 And you have a base there, you know you want to travel to another province and this craft is a ship, so which means that it will be able to travel by sea. So he will calculate and the craft has a range and it will calculate all.
 By using the whole tile system in the background, it will calculate the range.
 Which provinces he may get? Now imagine you have a craft aircraft and it can fly, which means it basically ignore the cost of terrain. Now we have a land vehicle and this land vehicle will be travelling by land.
 And it will take into consideration cost, how hard to get there. So all provinces are snapped to grid and the and the the grid world grid is for Airflag 80 by 40, which means that.
 One tile is approximately 500 kilometers and for other walls it can be different. Yeah, so wall tiles are not visible.
 And the map is just this mechanic is used to calculate the distance between the provinces, not in a straight line. So now the second thing is you have a base in the province, you can build a base.
 And the base, there are regions in in province, so every single province is assigned to region like Europe, North Africa, West Africa and so on, also oceans.
 On other words, it could be the same and words are used to spawn missions in regions and also to manage scoring, fame, reputation within regions, yeah.
 So it's more like file analytics. Regions are not normally visible for the player unless he will switch them up.
 OK, so now about the countries. So country is another layer like kind of province may be owner of the country. So the country may be it's actually the opposite.
 In the country may be owner of the province. Some provinces may be without the owner. The owner is the country and country. The main purpose of country is we need to keep the country satisfaction, protect them from different threats.
 And they will provide us funding. So scoring system is is for that. So score is a mechanism of you get higher score for doing things that protect the country and you lose score for things that can damage the country.
 You you you don't get a score for.
 Doing internal research is something that is not impacting directly the country. Yeah, so scoring in the game is just only for this purpose. So the higher the score, the the better the relation of the country and the better.
 Funding from the country. Now how much country can fund? The funding mechanism is based on the relation and based on the economic power of the country. Economic power of the country is sum of all economies from all provinces.
 So the provinces might have economy like or something like this, and this is used to calculate the total.
 Ability for for country to fund. Now if you have a base and you if you're going to build new base, it will cost you. Depends on region, depends on the country. Country may disallow you to build a base if you have a better relation for example.
 At the internal, if you build a base, there might be only one base in the in the province and you cannot build a base if there are any enemy emissions in the in the province. You need to clean the clean the vap first. Bases are under under underwater.
 Or underground. I mean, basically there's an assumption it's under, it's not the visible, it's under, it's not in a building, it's underground or under underwater. And when I'm saying underwater, it means that it's not underground, underwater, it's just underwater.
 Which means we will. You don't have to dip underwater to get to the underground underwater base. OK, so it's just underwater, under either underground, either underwater.
 So now if you have a craft and if the craft is in the base, you can click it and then select to send on a mission and it will use the water piles and pathfinding.
 And range of the craft to find if there are any rovinces which are in range and then you can move the craft.
 There are two important mechanics here. The first mechanic is the fuel in the range. So every craft has a fuel, what kind of item is used as a fuel. Fuel consumption is used, how much item it use per single travel.
 And the range is in in kilometres, yeah. So this depends on the world tile and the craft type. Yeah. If it's a shipped, it will allow you to travel by sea and so on and so forth, yeah.
 So now imagine you have a fuel in the base and you have a crowd that consumed the standard fuel and the range is 5 and the consumption is 2, which means you can travel up to five tiles to another province and then it will just consume during the travel directed number.
 On the base, there is no concept of refueling the craft. If you don't have the fuel in the base, you won't be able to travel, period. That's all. This is very simple model. Now how many travels you can do per per day? One day is one turn. Yeah, you can do.
 Exactly the same amount of travels as is your speed craft start. Yeah, so craft has a speed and speed defines how many travels you can do per turn every time you need to refuel. It refuels automatically and you just consume the fuel from the base. So now if you get to the province.
 And the first thing you get is you scan your radar. So every craft has an inbuilt radar which can be improved by equipment and it performs a scan, which means the the detection mechanism on the ghost base works like.
 There are missions which are by default hidden in provinces created by mission campaign, campaign generator and by default they are hidden. They have a start called cover and cover change.
 If the stat is positive, it means that it's undercover, player cannot see it, player cannot interact with it, and if it's still fully functional, it can move, it can score negative points versus player, but player cannot.
 Intercepted. So once this is so if if the cover is above 0 then it's not visible. OK, so now every craft has a radar and radar power number and radar range.
 And when it moves to the province, it will scan surrounding Korea in in the range of the radar and it will reduce from all missions which are there. It will reduce the recover stat by the number of.
 Cover cover power.
 So radar power. So you deduct from cover the number of radar power you have. If it reaches 0 or below, the mission goes detected. So you can see it and then you can interact with it. You cannot interact with a mission that is invisible. It's it's not detected.
 So let's imagine that you detected something and then you move another craft and you get another craft. So you have a free craft in the province and then you can start the interception. So the interception is completely separate screen and this separate screen.
 Is uh looks like.
 The card name on the left you have player, on the right you have enemy and left and right are also divided by three sections. So the upper part is air, the the middle part is land or water depends on biome.
 The province and the bottom part is either underground, either underwater, depends on the progress biome. So now this screen is used to perform all the interactions, so.
 If you have a a flying craft, it will be left upper because it's air. If on the other side there would be a cross side, it would be middle left, middle right because it would be on land. If you will have a submarine or something you it will have it will be on the left.
 Bottom part because it's underwater and so on. So this screen is used to handle everything from base defence, base defence, base assault, terror site, interception, crash site. I mean all possible cases are on the screen.
 And this has to be described later on. OK. And once this screen is resolved, I mean all active objects are either destroyed or something, we can move back to the Gale Scape or we can move to the next phase, which is battle scape.
 OK.
 Which will be described later.
 Now regarding different relations.
 So the first you need to explain any different concepts. What is a country? What is a supplier and what is a?
 Function. So a function is usually an.
 Like a lower element, a store element, single group of of enemies like.
 Um.
 One type of alien could be a faction. Yeah, factions are used to to control the missions. Yeah, so the country is owner of the province. You protect them, you get score, they give you funding.
 That's all. You may have a relation with them that controls if you can, for example, fly into the provinces, if you can build the provinces in them, what is the funding? Actually, you may have an enemy from the country, which means that they will be to attack you in the province if you enter the the craft there.
 And the last thing is supplier relation with suppliers is to control what kind of items or crafts you can buy. So marketplace or sell. So a supplier can provide you with heavy armor. If you have a better relation of supplier, the price will go up.
 The amount of available items per month would go down. If you have a bad, very bad relation, it means that you won't be able to buy them at all. If you have a good relation, you will have a discount.
 And you have a very good relation. You can buy and sell at the same rice because usually the selling price is half of the buying rice.
 So that's when it comes to relation. Now let's explain organization. So the the the idea is that the the project is scaling both vertical and horizontal, which means that you get better stuff, but also you get you get bigger in terms of quality and quantity.
 Organisation is the way how we can control this because organisation level is kind of milestone. You start a very small kind of private company, then you become a para para para military organisation.
 Or maybe part of the title would be the third level, the second level would be more like.
 Police organization kind of.
 Basically we just have some kind of medium stuff. Then you have a paramilitary and then you have a fully military and this fully military also may have different tech layers like standard warfare, laser warfare, plasma warfare.
 Which means that in total you may have 456 levels of organization and unlocking organization level is done by research, which means you need to get to some.
 A progress in technology tree to get to the organization level. Once you get there, it's considered to be kind of milestone and this can unlock further options, which means everything in the project can rely on organization level.
 So that's basically kind of promotional level in Open X compiles equivalent. The the the other thing is if you get bigger you get one point of advisor.
 Per your level, which means that if you have 4-5 levels total, you will have 4-5 points of advisors. What is an advisor? Advisor if it's a very expensive person who is hired.
 You need to maintain them, so you need to pay high salary, but it will give you a global boost in one of the area like 10% to research, 10% to manufacturing, 10% damage of your units, 10% to get getting your units faster experience.
 10% to range of your craft and so on. So there might be many advisors who can be hired. Number of them is defining by level of your organization and the price is if you can, if you can.
 Uh, manage them. I I mean, if you can hire them, if you can afford them, you can get them.
 Now let's explain the movement, actions and energy. So there are three core elements, which is action points, movement points and energy points. So by standard both units and crafts using the same mechanism, although they are.
 Imlemented differently because of the different screens they are used O action oints is by default you have four and this define.
 Do during the mission. So by default it's four. If you have, if you're damaged, if you're low moral, if you are low sanity, you you may lose your action points up to 0, which means you cannot do anything.
 But in general it's it's for.
 So let's say a.
 Using a pistol costs one action point, using a rifle costs 2 action points, using a grenade calls 2 action points and so on.
 Firing a sniper rifle would cost 3 action points. Then the second element is energy. Energy is considered to be a kind of battle of the unit. It it it's both ammunition and fatigue.
 And it's being consumed every time you use weapon, use an item, which means that a pistol may consume one energy, a rifle can consume 2 energy per shot, a grenade may consume one, but there's another mechanism called cooldown.
 Which limit how how much often you can use it. You need to wait this time this number of turns before next use. So energy is being the energy is a unique start and it's variable and for human it starts with six.
 And it ends at maximum 12.
 For a very senior unit and the typical energy regeneration is 2 per turn, which means if you have 6.
 And you have two regeneration. You need to free turns to to to fully regenerate and with 12 maximum energy you will have four regeneration. Most items and armors expand either your energy.
 Pool or your energy recognition. So for example, pistol will give you additional six points.
 But no regeneration. Yeah, you may have a special equipment which is called ammo pack will give you let's say 50 energy pool and free energy regeneration, which gives you much better flexibility during the mission about using the the.
 Energy assimilation. So energy is used for units and craft exactly the same way. Some units may have high IP cost, low energy cost and vice versa. Another thing mechanism is movement point. So unit has a start, it's called speed.
 And units and only units can move during the mission. They consume the.
 And and energy the the movement points for that. How to calculate movement points? Movement point is your available action point multiplied by your speed. So the typical speed is from range from 6 to 12 and action points are fixed for which means you have.
 From 24 to 48 movement points, rotating by 90 degrees cost you one movement point. Rotating moving one tile on a standard terrain is 2. Moving on standard tile diagonal is free. Moving on rough terrain is.
 Four and six and and on a very rough terrain is 6 and 9. If you consume movement points, you will also lose at the same time action points depends on your speed. Yeah, so moving by 4.
 Piles will do to also reduce your action points. If you are using action points, you don't lose. You also move movement points because you have less action points available. So this is some some some things like using items using.
 Only action points. Some elements like moving consume only movement points, but they are always linked in terms of how many movement or action points you have available.
 Or for craft you have only action points. I don't plan any movement at the moment.
 OK. So thank you.
 Tomasz Błądkowski stopped transcription
 
 
 Transcript
 October 10, 2025, 8:25AM
 Tomasz Błądkowski started transcription
 Tomasz Błądkowski   0:09
 Yeah, this session will be about units, about its stats and Mahanik's write it to unit.
 So first of all.
 The unit stats are.
 Speed that defines how many dials, how many movement points it will have based on speed multiplied by action points, then it's health.
 Typical hit points from 6 to 12 for typical.
 A unit. Then we have aim again from 6 to 12, which defines throwing and firing accuracy.
 And one point is equal to 10% of chance.
 Then we have strength, which is both hand to hand, right? And how many items it can carry capacity.
 Then we have site sense and the cover which was already described again 6 to 12.
 I'm sorry, site and sense and cover doesn't work like that. 20 and 10 is for site, three and three is for sense and cover is 0 by default unless equipment helps with that and that's the default values.
 Then we have bravery.
 Which is used again 6 to 12 which is used to test.
 Or maybe from 2:00 to 12:00 depends.
 Which defines tests that are when morale gets hit. You need to test bravery. If you fail, you lose morale every time. Sanity is from 6:00 to 12:00 and again.
 This is long term.
 Endurance. You lose morale. These are your sanity after a mission, like either zero, either one, either two, either three for a very heavy mission. So not per turn on the battle, but after the battle.
 And then you need to recover it and it takes one week to recover one sanity point unless you have some buildings, some facilities in the base.
 And then you have the reaction which works both as a reaction fire and also dodging ability.
 I don't know if I want to have a marry as a separate skill. There's C psionic which is capacity to put capacity to perform psionic action or is energy like everything else which is.
 Which was already explained how an energy system works and panic is actually in the skill.
 And it's again from 6 to 12, but to use actually skills which are usually on the items, you need to have a specific class, so it will be a specific class to allow the option to use it.
 Now the difference between morale and sanity is that you start with morale at 10 every time and you have every time you go to morale test. You need to test your bravery. If it's failed, you lose 1 morale if you have.
 Four more other or higher. Basically nothing happens. If you have 321 or zero, you lose one action point for each level.
 Yeah, for free you have. So for four modality you have 4 action points, for three modality you have three action points, for two modality you have two action points and so on. And the same works with sanity. Sanity is changed between the battles. There is no playable test for that. The sanity is considered to be a capacity.
 And and which means if you find a very difficult battle, you will lose 2 sanity points which has to be recovered in tweaks and if you have low sanity you will have again.
 You will lose 80 action points in the battle the same way like Moda. Now when it comes to wounds injuries, normally every one, every hit point you go during the battle has to be recovered.
 And by default.
 If he has, let's say, or injuries.
 Four points. If you lose 4 points, it will take you by default four weeks to recover, which is long. That's why you have different kind of hospitals we can treat and to increase the speed, but basically one.
 Health point of the battle is it has to be heal killed in hospital with one week, one week per one per one per one point of health. There might be a chance to have wound.
 Like injury and this injury.
 Is like a heavy wand, like I need to decide when you when you can have a wand, but if you have one wand.
 You will lose one health every turn.
 Which means you can bleed very fast.
 Which means if you have one, want you already have entered OK.
 It's not like in Xcom when 111 was just small bleeding.
 It's really serious. It's really serious here. I it's more like in the road, like when you have a perma perma dev, perma dev.
 And when it comes to capacity and and congerence, how many inventory you can have?
 And.
 I'm thinking how to explain.
 So normally you you may have three items. Our weapons one is our mode.
 Weapons can be anything and you can you can have whatever you want in in your inventory. There are no limits unless a specific inventory required a specific class to use like Medicaid, like something about botanics and so on. You may have two knives.
 An armor.
 OK, so that's all you you can have. And most items use action points or energy points to be used. Depends.
 And uh.
 There, there are no clips. There is energy pool instead. There are there are no clips maybe.
 If you just you consume energy and consuming consuming energy is being restored.
 Slowly the energy recognition, slowly recognize during the battle.
 All items and armours can boost your stats, including health, including energy, energy regeneration, including sight.
 And what can I have that I'm more like that will do it like plus 10 to energy.
 Tomasz Błądkowski stopped transcription
 