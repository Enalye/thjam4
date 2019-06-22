module game.coroutils;

import std.math;
import std.stdio: writeln;
import atelier;
import grimoire;
import game.global, game.shot;

void addPrimitives() {
	grAddPrimitive(&grPosSin, "psin", ["value"], [grFloat], [grFloat]);
	grAddPrimitive(&prints, "print", ["value"], [grString]);
	grAddPrimitive(&setColor, "setColor", ["r", "g", "b"],  [grFloat, grFloat, grFloat]);
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