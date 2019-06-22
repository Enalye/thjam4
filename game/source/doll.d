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

    bool isLocked;

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
        if(!isLocked) {
            Vec2f destination = mousePosition;

            Vec2f playerToDoll = (destination - playerPosition).normalized();

            float distanceToPlayer = playerPosition.distance(_position);
            float mouseToPlayer    = playerPosition.distance(destination);

            // Enough thread length (for old and new position)
            if((distanceToPlayer < _threadLength) && (mouseToPlayer < _threadLength)) {
                _target = destination;
            }
            // Not enough thread length
            else {
                _target = playerPosition + (playerToDoll * _threadLength);
            }
            _acceleration = (_target - _position).normalized * rlerp(0f, 200f, _target.distance(_position)) * 2f;
        }

        _speed *= .9f * deltaTime;		
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