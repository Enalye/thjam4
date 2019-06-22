module game.doll;

import atelier;
import std.stdio: writeln;
import game.entity, game.shot, game.global;

alias DollArray = IndexedArray!(Doll, 8);

enum DollType {
    SHOT,
    LASER,
    EXPLOSIVE,
    LANCE,
    TELEPORT,
    BOOMERANG,
    SHIELD
}

final class Doll: Entity {
	private {
		Sprite   _sprite; // @TODO animations instead
		float    _threadLength; // Max length from player
		Vec2f    _target;
        DollType _type;
	}

    bool isLocked;

	Vec2f mousePosition = Vec2f.zero;
	Vec2f playerPosition = Vec2f.zero;

	this(Vec2f position, Color color, DollType type, float threadLength = 250f) {
		_sprite = fetch!Sprite("doll");
        _sprite.color = color;
		_threadLength = threadLength;
		_position = position;
        _type     = type;
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

            float distanceTarget = _target.distance(_position);
            if(!isNaN(distanceTarget)) {
                float rlerpValue = 0.8f * _threadLength;
                _acceleration = (_target - _position).normalized * rlerp(0f, rlerpValue, _target.distance(_position)) * 2f;
            }
        }

        _speed *= .9f * deltaTime;		
	}

	override void update(float deltaTime) {

	}

	override void draw() {
    	_sprite.draw(_position);
	}

	override void fire() {
        final switch(_type) with(DollType) { 
        case DollType.SHOT:
            createPlayerShot(_position,
                    Vec2f.one,
                    1,
                    Color.red,
                    mousePosition - _position,
                    10f,
                    5 * 60f);
            break;
        case DollType.LASER:
            break;
        case DollType.EXPLOSIVE:
            break;
        case DollType.LANCE:
            break;
        case DollType.TELEPORT:
            break;
        case DollType.BOOMERANG:
            break;
        case DollType.SHIELD:
            break;
        }
	}


    override void handleCollision(Shot shot) {
        // @TODO
    }
}