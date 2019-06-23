module game.coroutils;

import std.math;
import std.random;
import std.stdio: writeln;
import std.conv;
import atelier;
import grimoire;
import game.global, game.entity, game.shot, game.enemy, game.hud, game.menu;

void addPrimitives() {
	auto grEnemy = grAddUserType("Enemy");
	grAddPrimitive(&grCos, "cos", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&grSin, "sin", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&grPosSin, "psin", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&grPrint, "print", ["value"], [grString]);
	grAddPrimitive(&grSetColor, "setColor", ["r", "g", "b"],  [grFloat, grFloat, grFloat]);
	grAddPrimitive(&grSpawnEnemy, "spawnEnemy", ["name", "x", "y"], [grString, grFloat, grFloat], [grEnemy]);
	grAddPrimitive(&grFireShot, "fireShot", ["enemy", "x", "y", "angle", "speed"], [grEnemy, grFloat, grFloat, grFloat, grFloat]);
	grAddPrimitive(&grGetPosition, "getPosition", ["enemy"], [grEnemy], [grFloat, grFloat]);
	grAddPrimitive(&grSetPosition, "setPosition", ["enemy", "x", "y"], [grEnemy, grFloat, grFloat]);
	grAddPrimitive(&grGetPlayerPosition, "getPlayerPosition", [], [], [grFloat, grFloat]);
	grAddPrimitive(&getDistanceToPlayer, "getDistanceToPlayer", ["enemy"], [grEnemy], [grFloat]);
	grAddPrimitive(&grSetMovementSpeed, "setMovementSpeed", ["enemy", "movX", "movY"], [grEnemy, grFloat, grFloat]);
	grAddPrimitive(&grSetTarget, "setTarget", ["enemy", "x", "y"], [grEnemy, grFloat, grFloat]);
	grAddPrimitive(&grRandom, "rand", ["min", "max"], [grFloat, grFloat], [grFloat]);
	grAddPrimitive(&grIsAlive, "isAlive", ["enemy"], [grEnemy], [grBool]);
	grAddPrimitive(&grPrintEnemyPtr, "printEnemyPtr", ["enemy"], [grEnemy]);
	grAddPrimitive(&grStartDialog, "startDialog", ["i"], [grInt]);
	grAddPrimitive(&grSetVictory, "setVictory", [], []);
}

private void grCos(GrCall call) {
	call.setFloat((cos(call.getFloat("value") * (PI / 180))));
}

private void grSin(GrCall call) {
	call.setFloat((sin(call.getFloat("value") * (PI / 180))));
}

private void grPosSin(GrCall call) {
	call.setFloat((sin(call.getFloat("value")) + 1f) * 0.5f);
}

private void grPrint(GrCall call) {
    writeln(call.getString("value"));
}

private void grPrintEnemyPtr(GrCall call) {
	Enemy enemy = call.getUserData!Enemy("enemy");
	writeln(cast(void*)enemy);
}

private void grSetColor(GrCall call) {
	float r = call.getFloat("r");
	float g = call.getFloat("g");
	float b = call.getFloat("b");

	foreach(Shot shot; playerShots) {
        shot.color(Color(r, g, b));
    }
}

private void grSpawnEnemy(GrCall call) {
	string name = to!string(call.getString("name"));
	float x     = call.getFloat("x");
	float y     = call.getFloat("y");

	Enemy enemy = new Enemy(name, Vec2f(x, y));
	call.setUserData!Enemy(enemy);
	enemies.push(enemy);
}

private void grFireShot(GrCall call) {
	Enemy enemy    = call.getUserData!Enemy("enemy");
	float x        = call.getFloat("x");
	float y        = call.getFloat("y");
	float angle    = call.getFloat("angle");
	float speed    = call.getFloat("speed");
	Vec2f spawnPos = Vec2f(x, y);

	createShot(EntityType.ENEMY,
		spawnPos,
		Vec2f.one,
		1, // damage
		Color.white,
		spawnPos - enemy.position,
		speed,
		5 * 60f);
}

private void grGetPosition(GrCall call) {
	Enemy enemy    = call.getUserData!Enemy("enemy");
	Vec2f position = enemy.position; 
	call.setFloat(position.x);
	call.setFloat(position.y);
}

private void grSetPosition(GrCall call) {
	Enemy enemy    = call.getUserData!Enemy("enemy");
	float x        = call.getFloat("x");
	float y        = call.getFloat("y");
	enemy.position = Vec2f(x, y);
}

private void grGetPlayerPosition(GrCall call) {
	call.setFloat(player.position.x);
	call.setFloat(player.position.y);
}

private void getDistanceToPlayer(GrCall call) {
	Enemy enemy = call.getUserData!Enemy("enemy");
	call.setFloat(player.position.distance(enemy.position));
}

private void grSetTarget(GrCall call) {
	Enemy enemy    = call.getUserData!Enemy("enemy");
	float x        = call.getFloat("x");
	float y        = call.getFloat("y");

	Vec2f target   = Vec2f(x, y); 
	Vec2f toTarget = (target - enemy.position).normalized;
	enemy.movementSpeed = toTarget * 5f;
}


private void grSetMovementSpeed(GrCall call) {
	Enemy enemy = call.getUserData!Enemy("enemy");
	float movX  = call.getFloat("movX");
	float movY  = call.getFloat("movY");
	enemy.movementSpeed = Vec2f(movX, movY);
}

private void grRandom(GrCall call) {
	float min   = call.getFloat("min");
	float max   = call.getFloat("max");
	call.setFloat(uniform(min, max));
}

private void grIsAlive(GrCall call) {
	Enemy enemy = call.getUserData!Enemy("enemy");
	call.setBool(enemy.isAlive());
}

private void grStartDialog(GrCall call) {
	int i = call.getInt("i");

	if(i == 0) {
		hud.setDialog("   ... Medecine?{n}   Why are you here,{n}   and what with that look{n}   on your face?", 1, 1, false);
	} 

	if(i == 1) {
		hud.setDialog("   So you've finaly come!{n}   You weren't eager to find me,{n}   right?", 1, 2, true);
	}

	if(i == 2) {
		hud.setDialog("   Uh.. Well.. It's not..{n}", 2, 1, false);
	}

	if(i == 3) {
		hud.setDialog("   Hehe, I see.{n}   You're afraid of Mania!{n}   The eigth form of love,{n}   the strongest one,{n}   the one that time cannot affect,{n}   which drove so many to madness..", 1, 1, true);
	}

	if(i == 4) {
		hud.setDialog(" You're nothing more than{n} an obsession!{n} Why did you possess{n} that little doll?{n}", 1, 1, false);
	}

	if(i == 5) {
		hud.setDialog(" Because obsession{n} had already taken her,{n} it was easy as pie", 1, 2, true);
	}

	if(i == 6) {
		hud.setDialog(" I see...", 2, 1, false);
	}

	if(i == 7) {
		hud.setDialog(" This little adventure made me{n} realize love's true strength.", 1, 1, false);
	}

	if(i == 8) {
		hud.setDialog(" It's beyond a witch's magic{n} Beyond words on a paper..{n}", 1, 1, false);
	}

	if(i == 9) {
		hud.setDialog(" It's in the blood that{n} runs through my veins.{n} and I can feel it{n} burning in my chest!", 1, 1, false);
	}

	if(i == 10) {
		hud.setDialog("   Out of all,{n}   you're the one that{n}   deserves to be sealed!", 1, 1, false);
	}

	if(i == 11) {
		hud.setDialog("   Now feel the warmth of love{n}   and go back to being that pesky{n}   little doll we love!", 1, 1, false);
	}
}

private void grSetVictory(GrCall call) {
	setVictory();
}