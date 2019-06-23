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
		Animation _idleAnimation, _idleToRightAnimation, _idleToLeftAnimation, _rightAnimation, _leftAnimation, _currentAnimation;
		float     _threadLength; // Max length from player
		Vec2f     _target;
        DollType  _type;

        Animation _mirrorAnim;
        Timer     _mirrorRecovery;
        Color     _color;
	}

    override void init() {
        super.init();
        _target = _player.position;
    }

    bool isLocked;

	Vec2f mousePosition  = Vec2f.zero;
	Vec2f playerPosition = Vec2f.zero;
    string description;

	this(string name, Player player, Vec2f position, Color color, DollType type, float threadLength = 250f) {
        _player               = player;

		_idleAnimation        = new Animation(name ~ ".idle");
        _idleToRightAnimation = new Animation(name ~ ".idle_to_right");
        _idleToLeftAnimation  = new Animation(name ~ ".idle_to_left");
        _rightAnimation       = new Animation(name ~ ".right");
        _leftAnimation        = new Animation(name ~ ".left");
        _currentAnimation     = _idleAnimation;
        _color                = color;

        _mirrorAnim           = new Animation("mirror", TimeMode.Stopped);
		_threadLength         = threadLength;
		_position             = position;
        _type                 = type;

        final switch(_type) with(DollType) { 
        case DollType.SHOT:
            description = "Philia [Rainbow Shot]";
            break;
        case DollType.LASER:
            description = "Eros [Laser]";
            break;
        case DollType.EXPLOSIVE:
            description = "Philautia [Explosive]";
            break;
        case DollType.LANCE:
            description = "Ludus [Lance]";
            break;
        case DollType.TELEPORT:
            description = "Agape [Teleportation]";
            break;
        case DollType.BOOMERANG:
            description = "Storge [Boomerang]";
            break;
        case DollType.SHIELD:
            description = "Pragma [Shield]";
            break;
        }

        _idleAnimation.start(.5f, TimeMode.Loop);
	}

	override void updateMovement(float deltaTime) {
        float nearDistance = 10f;

        if(!isLocked) {
            Vec2f destination = mousePosition;

            Vec2f playerToDoll = (destination - playerPosition).normalized();
            Vec2f mouseToDoll  = (destination - _position); 

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

                if(_currentAnimation == _idleAnimation) {
                    if(mouseToDoll.x > nearDistance) {
                        _idleToRightAnimation.start(0.5f, TimeMode.Once);
                        _currentAnimation = _idleToRightAnimation;
                    } else if(mouseToDoll.x < -nearDistance) {
                        _idleToLeftAnimation.start(0.5f, TimeMode.Once);
                        _currentAnimation = _idleToLeftAnimation;
                    }
                } else if(abs(mouseToDoll.x) < nearDistance) {
                    _idleAnimation.start(.5f, TimeMode.Loop);
                    _currentAnimation = _idleAnimation;
                }

                float distanceTarget = _target.distance(_position);
                if(!isNaN(distanceTarget)) {
                    float rlerpValue = 0.8f * _threadLength;
                    _acceleration = (_target - _position).normalized * rlerp(0f, rlerpValue, distanceTarget) * 2f;
                }
            }
        }

        if((_currentAnimation == _idleToRightAnimation) && (!_idleToRightAnimation.isRunning)) {
            _rightAnimation.start(.5f, TimeMode.Loop);
            _currentAnimation = _rightAnimation;
        }

        if((_currentAnimation == _idleToLeftAnimation) && (!_idleToLeftAnimation.isRunning)) {
            _leftAnimation.start(.5f, TimeMode.Loop);
            _currentAnimation = _leftAnimation;
        }

        _speed *= .9f * deltaTime;		
	}

	override void update(float deltaTime) {
        _mirrorAnim.update(deltaTime);
        _currentAnimation.update(deltaTime);
        _mirrorRecovery.update(deltaTime);
	}

	override void draw() {
        _currentAnimation.color = _color;
    	_currentAnimation.draw(_position);

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