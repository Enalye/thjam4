module game.enemy;

import std.conv: to;
import std.stdio: writeln;

import atelier;
import game.entity, game.shot;

final class Enemy: Entity {
	private {
		Animation _idleAnim, _runAnim;
	}

	this() {

	}

	override void updateMovement(float deltaTime) {

	}

	override void handleCollision(Shot shot) {
        // @TODO
    }
}