module game.doll;

import atelier;
import std.stdio: writeln;
import game.entity, game.shot, game.global;

alias DollArray = IndexedArray!(Doll, 7);

final class Doll: Entity {
	private {
		Sprite _sprite; // @TODO animations instead
		float  _threadLength; // Max length from player
		Vec2f  _target;
	}

    @property {
        void movementSpeed(Vec2f movementSpeed) { _movementSpeed = movementSpeed; }
    }

	Vec2f mousePosition = Vec2f.zero;
	Vec2f playerPosition = Vec2f.zero;

	this(Vec2f position) {
		_sprite = fetch!Sprite("doll");
		_threadLength = 250f;
		_position = position;
	}

	override void updateMovement(float deltaTime) {
        Vec2f playerToDoll = (mousePosition - playerPosition).normalized();

		float distanceToPlayer = playerPosition.distance(_position);
		float mouseToPlayer    = playerPosition.distance(mousePosition);

		// Enough thread length (for old and new position)
		if((distanceToPlayer < _threadLength) && (mouseToPlayer < _threadLength)) {
			_target = mousePosition;
		}
		// Not enough thread length
		else {
			_target = playerPosition + (playerToDoll * _threadLength);
		}

		float speed = 10 * (distanceToPlayer / _threadLength);
		_position = _position.lerp(_target, deltaTime * speed / distanceToPlayer);
	}

	// @TODO lerp it !
	override void update(float deltaTime) {

	}

	override void draw() {
    	_sprite.draw(_position);
	}

	override void fire() {
        createPlayerShot(_position,
                Vec2f.one,
                5,
                Color.red,
                mousePosition - _position,
                10f,
                5 * 60f);
	}


    override void handleCollision(Shot shot) {
        // @TODO
    }
}