module game.coroutils;

import std.math;
import std.stdio: writeln;
import std.conv;
import atelier;
import grimoire;
import game.global, game.entity, game.shot, game.enemy;

void addPrimitives() {
	grAddPrimitive(&grPosSin, "psin", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&prints, "print", ["value"], [grString]);
	grAddPrimitive(&setColor, "setColor", ["r", "g", "b"],  [grFloat, grFloat, grFloat]);
	grAddPrimitive(&spawnEnemy, "spawnEnemy", ["index", "name", "x", "y"], [grInt, grString, grFloat, grFloat]);
}

private void grPosSin(GrCall call) {
	call.setFloat((sin(call.getFloat("value")) + 1f) * 0.5f);
}

private void prints(GrCall call) {
    writeln(call.getString("value"));
}

private void setColor(GrCall call) {
	float r = call.getFloat("r");
	float g = call.getFloat("g");
	float b = call.getFloat("b");

	foreach(Shot shot; playerShots) {
        shot.color(Color(r, g, b));
    }
}

private void spawnEnemy(GrCall call) {
	int index   = call.getInt("index");
	string name = to!string(call.getString("name"));
	float x     = call.getFloat("x");
	float y     = call.getFloat("y");

	Enemy enemy = new Enemy(index, name, Vec2f(x, y));
	enemies.push(enemy);
}