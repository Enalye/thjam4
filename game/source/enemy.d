module game.enemy;

import std.conv: to;
import std.stdio: writeln;

import atelier;
import game.entity, game.shot;

alias EnemyArray = IndexedArray!(Enemy, 100u);

final class Enemy: Entity {
	private {
		Animation _currentAnim, _idleAnim;
	}

	this(string name, Vec2f position) {
		_position = position;
		_idleAnim = new Animation(name ~ ".idle");
		_idleAnim.start(.5f, TimeMode.Loop);
		_currentAnim = _idleAnim;
	}

	override void updateMovement(float deltaTime) {
		// @TODO implement logic in coroutines (to drive movementSpeed)
	}

	override void update(float deltaTime) {
		_idleAnim.update(deltaTime);
	}

	override void draw() {
		_currentAnim.draw(_position);
	}

	override void fire() {

	}

	override void handleCollision(Shot shot) {
        // @TODO
    }
}