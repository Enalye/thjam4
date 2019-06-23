module game.doll;

import atelier;
import std.stdio: writeln;
import game.entity, game.shot, game.global, game.player, game.level;

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
        Player    _player;
		Sprite    _sprite; // @TODO animations instead
		float     _threadLength; // Max length from player
		Vec2f     _target;
        DollType  _type;

        Animation _mirrorAnim;
        Timer     _mirrorRecovery;
	}

    override void init() {
        super.init();
        _target = _player.position;
    }

    bool isLocked;

	Vec2f mousePosition = Vec2f.zero;
	Vec2f playerPosition = Vec2f.zero;
    string name;

	this(Player player, Vec2f position, Color color, DollType type, float threadLength = 250f) {
        _player = player;
		_sprite = fetch!Sprite("doll");
        _mirrorAnim = new Animation("mirror", TimeMode.Stopped);
        _sprite.color = color;
		_threadLength = threadLength;
		_position = position;
        _type     = type;

        final switch(_type) with(DollType) { 
        case DollType.SHOT:
            name = "Philia [Rainbow Shot]";
            break;
        case DollType.LASER:
            name = "Eros [Laser]";
            break;
        case DollType.EXPLOSIVE:
            name = "Philautia [Explosive]";
            break;
        case DollType.LANCE:
            name = "Ludus [Lance]";
            break;
        case DollType.TELEPORT:
            name = "Agape [Teleportation]";
            break;
        case DollType.BOOMERANG:
            name = "Storge [Boomerang]";
            break;
        case DollType.SHIELD:
            name = "Pragma [Shield]";
            break;
        }
	}

	override void updateMovement(float deltaTime) {
        if(!isLocked) {
            Vec2f destination = mousePosition;

            Vec2f playerToDoll = (destination - playerPosition).normalized();

            float distanceToPlayer = playerPosition.distance(_position);
            float mouseToPlayer    = playerPosition.distance(destination);

            if(!isNaN(distanceToPlayer) && !isNaN(mouseToPlayer)) {
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
        }

        _speed *= .9f * deltaTime;		
	}

	override void update(float deltaTime) {
        _mirrorAnim.update(deltaTime);
        _mirrorRecovery.update(deltaTime);
	}

	override void draw() {
    	_sprite.draw(_position);
        if(_mirrorAnim.isRunning()) {
            Vec2f distanceToPlayer = _position - _player.position;
            float offset = (distanceToPlayer.x > 0) ? 25f : -25f;
            _mirrorAnim.draw(Vec2f(_position.x + offset, _position.y));
        }
	}

	override void fire() {
        final switch(_type) with(DollType) { 
        case DollType.SHOT:
            createShot(EntityType.PLAYER,
                    _position,
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
            checkCollision(currentLevel);
            break;
        case DollType.TELEPORT:
            Vec2f oldPosition = _player.position;
            _player.position   = _position;
            _position         = oldPosition;
            break;
        case DollType.BOOMERANG:
            break;
        case DollType.SHIELD:
            if(!_mirrorRecovery.isRunning()) {
                _mirrorAnim.start(0.8f, TimeMode.Once);
                _mirrorRecovery.start(1.2f);
            }
            break;
        }
	}


    override bool handleCollision(int damage, Shot shot) {
        if((_type == DollType.SHIELD) && _mirrorAnim.isRunning()) {
            Vec2f oldDirection = shot.direction();
            Vec2f newDirection = Vec2f(-oldDirection.x, -oldDirection.y);
            shot.direction = newDirection;
            shot.spriteAngle = shot.spriteAngle + 180;

            // Swap arrays
            int index = playerShots.push(shot);
            shot.index = index;
            shot.isAlive = true;
            return true;
        }

        return false;
    }

    bool checkCollision(Level level) {
        if((_type == DollType.LANCE) && (level.checkCollision(_position))) {
            _player.lanceJump(_position);
        }

        return false;
    }
}