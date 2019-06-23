module game.player;

import std.conv: to;
import std.stdio: writeln;
import atelier;
import game.entity, game.particles, game.shot, game.global, game.doll, game.scene, game.enemy;
import game.dollthread, game.camera;

import derelict.sdl2.sdl;

final class Player: Entity {
    private {
        bool        _hasPlayerInput;
        Animation   _currentAnim, _idleAnim, _runAnim, _fallAnim, _stopAnim, _jumpAnim, _recoverAnim;
        Timer       _shotTimer, _trailTimer, _iframesTimer, _dashTimer, _dashIdleTimer;
        bool        _wasFalling;
        Doll        _currentDoll;
        DollThread  _dollThread;
    }

    Vec2f mousePosition = Vec2f.zero;

    @property {
        Doll currentDoll() { return _currentDoll; }
    }

    this() {
        _idleAnim = new Animation("alice.idle");
        _runAnim = new Animation("alice.run");
        _fallAnim = new Animation("alice.fall");
        _stopAnim = new Animation("alice.stop");
        _jumpAnim = new Animation("alice.jump");
        _recoverAnim = new Animation("alice.recover", TimeMode.Stopped);
        _idleAnim.start(.5f, TimeMode.Loop);
        _runAnim.start(.5f, TimeMode.Loop);
        _currentAnim = _idleAnim;

        _size = to!Vec2f(_idleAnim.tileSize);
        _position = Vec2f(32f, -_size.y / 2f);
        _speed = Vec2f.zero;
        _hasGravity = true;

        dolls = new DollArray();

        dolls.push(new Doll("doll", this, _position, Color.fromRGB(0xFF4500), DollType.SHOT)); // Red
        dolls.push(new Doll("doll", this, _position, Color.fromRGB(0xFFA500), DollType.LASER)); // Orange
        dolls.push(new Doll("doll", this, _position, Color.fromRGB(0xFFFF33), DollType.EXPLOSIVE)); // Yellow
        dolls.push(new Doll("doll", this, _position, Color.fromRGB(0x32CD32), DollType.LANCE, 1000f)); // Green
        dolls.push(new Doll("doll", this, _position, Color.fromRGB(0x00BFFF), DollType.TELEPORT, 750f)); // Blue
        dolls.push(new Doll("doll", this, _position, Color.fromRGB(0x4169E1), DollType.BOOMERANG)); // Indigo
        dolls.push(new Doll("doll", this, _position, Color.fromRGB(0xBA55D3), DollType.SHIELD)); // Purple


        _currentDoll = dolls[_dollIndex];
        _currentDoll.init();
        _dollThread = new DollThread;
        _dollThread.doll = _currentDoll;
        _dollThread.player = this;
        _dollThread.init();

        hud.player = this;
        hud.changeDoll();
    }

    private int _dashDirection;
    private bool _dashIdle;
    bool dash(int dir) {
        if(_dashTimer.isRunning) {
            return true;
        }
        else if(dir == 2) {
            if(!_dashIdleTimer.isRunning && !_dashIdle) {
                _dashIdleTimer.start(.1f);
                _dashIdle = true;
            }
        }
        else if(_dashIdleTimer.isRunning && _dashDirection == dir) {
            _dashTimer.start(.2f);
            _dashIdle = false;
            return true;
        }
        else {
            _dashDirection = dir;
            _dashIdle = false;
        }
        return false;
    }

    private {
        Timer _dollSelectTimer;
        int _dollIndex;
    }
    void selectNextDoll(bool forward) {
        if(_dollSelectTimer.isRunning)
            return;

        _dollIndex = forward ? _dollIndex + 1 : _dollIndex - 1;
        if(_dollIndex >= cast(int)dolls.length) 
            _dollIndex = 0;
        if(_dollIndex < 0)
            _dollIndex = (cast(int)dolls.length) - 1;
        
        _currentDoll = dolls[_dollIndex];
        _currentDoll.position = _position;
        _dollThread.doll = _currentDoll;
        _dollThread.init();

        hud.changeDoll();
        
        _dollSelectTimer.start(.5f);
    }

    override void updateMovement(float deltaTime) {
        bool isMovingHorizontally;
        if(isKeyDown("left")) {
            isMovingHorizontally = true;
            _movementSpeed.x = _movementSpeed.x > -5f ?
                _movementSpeed.x - deltaTime * (_isFalling ? .3f : .8f) :
                -5f;
            if(dash(0)) {
                _movementSpeed.x = -15f;
            }

            _direction = Direction.Left;
            _idleAnim.flip = Flip.HorizontalFlip;
            _runAnim.flip = Flip.HorizontalFlip;
            _fallAnim.flip = Flip.HorizontalFlip;
            _stopAnim.flip = Flip.HorizontalFlip;
            _jumpAnim.flip = Flip.HorizontalFlip;
            _recoverAnim.flip = Flip.HorizontalFlip;
            _hasPlayerInput = true;
        }
        if(isKeyDown("right")) {
            isMovingHorizontally = true;
            _movementSpeed.x = _movementSpeed.x < 5f ?
                _movementSpeed.x + deltaTime * (_isFalling ? .3f : .8f) :
                5f;

            if(dash(1)) {
                _movementSpeed.x = 15f;
            }

            _direction = Direction.Right;
            _idleAnim.flip = Flip.NoFlip;
            _runAnim.flip = Flip.NoFlip;
            _fallAnim.flip = Flip.NoFlip;
            _stopAnim.flip = Flip.NoFlip;
            _jumpAnim.flip = Flip.NoFlip;
            _recoverAnim.flip = Flip.NoFlip;
            _hasPlayerInput = true;
        }
        if(!isMovingHorizontally) {
            dash(2);
            _movementSpeed.x *= deltaTime * _isFalling ? .999f : .8f;
            _hasPlayerInput = false;
        }

        if(!_isFalling && getKeyDown("jump")) {
            _jumpAnim.start(.5f, TimeMode.Once);
            _currentAnim = _jumpAnim;
            _acceleration.y += -8f;
            _isFalling = true;
        }
        if(_isFalling && _canDoubleJump && getKeyDown("jump")) {
            _canDoubleJump = false;
            _speed.x = 0f;
            _speed.y = 0f;
            _acceleration.y += -7f;
        }

        // Animation selection

        // Recover phase
        if(_recoverAnim.isRunning) {
            _speed.x = 0f;
            _currentAnim = _recoverAnim;
        }
        else if(_wasFalling && !_isFalling) {
            if(_currentAnim != _recoverAnim) {
                _recoverAnim.start(.15f);
            }
            _currentAnim = _recoverAnim;
        }
        else if(_isFalling) {
            if(_speed.y > .1f) {
                if(_currentAnim != _fallAnim) {
                    _fallAnim.start(.5f);
                }
                _currentAnim = _fallAnim;
            }
            else {
                _currentAnim = _jumpAnim;
            }
        }
        else if(_hasPlayerInput && !_isFalling) {
            _currentAnim = _runAnim;
        }
        else if(_movementSpeed.x > .1f || _movementSpeed.x < -.1f) {
            if(_currentAnim != _stopAnim) {
                _stopAnim.start(.5f);
            }
            _currentAnim = _stopAnim;
        }
        else {
            _currentAnim = _idleAnim;
        }

        mousePosition += speed();

        //Shoot
        if(isButtonDown(SDL_BUTTON_LEFT)) {
            fire();
        }
        _currentDoll.isLocked = isButtonDown(SDL_BUTTON_RIGHT);

        //Castlevania trail effect
        _trailTimer.update(deltaTime);
        if(!_trailTimer.isRunning) {
            final class TrailParticle: Spark {
                override void update(float deltaTime) {
                    float t = easeInOutSine(time / timeToLive);
                    sprite.color = Color(
                        lerp(.8f, .0f, t),
                        lerp(.8f, .5f, t),
                        lerp(1f, .8f, t),
                        lerp(.8f, 0f, t));
                }
            }

            Spark spark = new TrailParticle;
            spark.sprite = _currentAnim.getCurrentSprite();
            spark.position = _position;
            spark.timeToLive = 2f;
            spawnSpark(spark);

            final class OutlineParticle: Spark {
                Player player;

                override void update(float deltaTime) {
                    position = player.position + Vec2f(0f, lerp(0f, 20f, time / timeToLive));
                    sprite = player._currentAnim.getCurrentSprite();
                    sprite.color = Color(.15f, .3f, .6f);
                    sprite.scale = Vec2f.one * 1.25f * lerp(1f, .3f, time / timeToLive);
                    sprite.blend = Blend.AdditiveBlending;
                }
            }

            auto outline = new OutlineParticle;
            outline.player = this;
            outline.sprite = _currentAnim.getCurrentSprite();
            outline.position = _position;
            outline.timeToLive = 2f;
            spawnSpark(outline);
            _trailTimer.start(.1f);
        }

        _shotTimer.update(deltaTime);
        _wasFalling = _isFalling;
    }

    override void updatePhysic(float deltaTime) {
        _currentDoll.updatePhysic(deltaTime);
        Entity.updatePhysic(deltaTime);
    }

    override void update(float deltaTime) {
        _dashIdleTimer.update(deltaTime);
        _dashTimer.update(deltaTime);
        _iframesTimer.update(deltaTime);
        _dollSelectTimer.update(deltaTime);

        _dollThread.doll   = _currentDoll;
        _dollThread.player = this;
        _dollThread.update(deltaTime);

        _idleAnim.update(deltaTime);
        _runAnim.update(deltaTime);
        _fallAnim.update(deltaTime);
        _stopAnim.update(deltaTime);
        _recoverAnim.update(deltaTime);

        _currentDoll.playerPosition = _position;
        if(_currentDoll.isLocked) {
            _currentDoll.movementSpeed = Vec2f.zero;
        }
        else {
            _currentDoll.movementSpeed = _movementSpeed;
        }
        _currentDoll.mousePosition  = mousePosition;
        _currentDoll.update(deltaTime);

        if(isNaN(_currentDoll.position.x) || isNaN(_currentDoll.position.y)) {
            _currentDoll.init();
            _dollThread.init();
        }
    }

    override void draw() {
        _dollThread.draw();
        if(_iframesTimer.isRunning) {
            _currentAnim.tileset.blend = Blend.AdditiveBlending;
        } else {
            _currentAnim.tileset.blend = Blend.AlphaBlending;
        }

        _currentAnim.draw(_position);
        _currentDoll.draw();
    }

    override void fire() {
        if(!_shotTimer.isRunning) {
            _currentDoll.fire();
            _shotTimer.start(.2f);
        }
    }

    override bool handleCollision(int damage, Shot shot = null) {
        if(_iframesTimer.isRunning) {
            return false;
        }

        _life = _life - damage;
        if(_life < 0) {
            _life = 0;
            shakeCamera(Vec2f(30f, 15f), 1f);
            respawn();
            return true;
        }

        _isFalling = true;
        _canDoubleJump = false;
        
        final switch(_direction) with(Direction) {
        case Right:
            _movementSpeed.x = -5f;
            _speed.y = -3f;
            break;
        case Left:
            _movementSpeed.x = 5f;
            _speed.y = -3f;
            break;
        }

        shakeCamera(Vec2f(15f, 5f), 1f);
        _iframesTimer.start(1f);
        return true;
    }

    void respawn() {
        _position = Vec2f(32f, -_size.y / 2f);
        _speed = Vec2f.zero;
        _movementSpeed = Vec2f.zero;
        _isFalling = true;
        _canDoubleJump = false;
        _acceleration = Vec2f.zero;
        _life = _maxLife;
        _currentDoll.init();
        _dollThread.init();
    }

    void lanceJump(Vec2f target) {
        Vec2f jumpMovement = (target - _position).normalized();

        _jumpAnim.start(.5f, TimeMode.Once);
        _currentAnim = _jumpAnim;
        _acceleration.x += 8f  * jumpMovement.x;
        _acceleration.y += 16f * jumpMovement.y;
        _isFalling = true;
    }
}