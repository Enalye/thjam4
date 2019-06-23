module game.coroutils;

import std.math;
import std.stdio: writeln;
import std.conv;
import atelier;
import grimoire;
import game.global, game.entity, game.shot, game.enemy;

void addPrimitives() {
	grAddPrimitive(&grCos, "cos", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&grSin, "sin", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&grPosSin, "psin", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&grPrint, "print", ["value"], [grString]);
	grAddPrimitive(&grSetColor, "setColor", ["r", "g", "b"],  [grFloat, grFloat, grFloat]);
	grAddPrimitive(&grSpawnEnemy, "spawnEnemy", ["index", "name", "x", "y"], [grInt, grString, grFloat, grFloat]);
	grAddPrimitive(&grFireShot, "fireShot", ["index", "x", "y", "angle", "speed"], [grInt, grFloat, grFloat, grFloat, grFloat]);
	grAddPrimitive(&grGetPosition, "getPosition", ["index"], [grInt], [grFloat, grFloat]);
	grAddPrimitive(&grSetPosition, "setPosition", ["index", "x", "y"], [grInt, grFloat, grFloat]);
	grAddPrimitive(&grSetMovementSpeed, "setMovementSpeed", ["index", "movX", "movY"], [grInt, grFloat, grFloat]);
	grAddPrimitive(&grIsAlive, "isAlive", ["index"], [grInt], [grBool]);
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

private void grSetColor(GrCall call) {
	float r = call.getFloat("r");
	float g = call.getFloat("g");
	float b = call.getFloat("b");

	foreach(Shot shot; playerShots) {
        shot.color(Color(r, g, b));
    }
}

private void grSpawnEnemy(GrCall call) {
	int index   = call.getInt("index");
	string name = to!string(call.getString("name"));
	float x     = call.getFloat("x");
	float y     = call.getFloat("y");

	Enemy enemy = new Enemy(index, name, Vec2f(x, y));
	enemies.push(enemy);
}

private void grFireShot(GrCall call) {
	int index = call.getInt("index");
	float x   = call.getFloat("x");
	float y   = call.getFloat("y");
	float angle = call.getFloat("angle");
	float speed = call.getFloat("speed");

	Enemy enemy    = enemies[index];
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
	Enemy enemy    = enemies[call.getInt("index")];
	Vec2f position = enemy.position; 
	call.setFloat(position.x);
	call.setFloat(position.y);
}

private void grSetPosition(GrCall call) {
	int index = call.getInt("index");
	float x = call.getFloat("x");
	float y = call.getFloat("y");
	Enemy enemy = enemies[index];
	enemy.position = Vec2f(x, y);
}

private void grSetMovementSpeed(GrCall call) {
	int index = call.getInt("index");
	float movX = call.getFloat("movX");
	float movY = call.getFloat("movY");
	Enemy enemy = enemies[index];
	enemy.movementSpeed = Vec2f(movX, movY);
}

private void grIsAlive(GrCall call) {
	int index = call.getInt("index");
	Enemy enemy = enemies[index];
	call.setBool(enemy.isAlive());
}