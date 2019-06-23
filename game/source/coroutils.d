module game.coroutils;

import std.math;
import std.random;
import std.stdio: writeln;
import std.conv;
import atelier;
import grimoire;
import game.global, game.entity, game.shot, game.enemy;

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