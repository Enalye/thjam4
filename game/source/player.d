module game.player;

import std.conv: to;
import std.stdio: writeln;
import atelier;
import game.entity, game.particles, game.shot, game.global, game.doll, game.scene;

import derelict.sdl2.sdl;

final class Player: Entity {
    private {
        bool        _hasPlayerInput;
        Animation   _currentAnim, _idleAnim, _runAnim, _fallAnim, _stopAnim, _jumpAnim, _recoverAnim;
        Timer       _shotTimer, _trailTimer;
        bool        _wasFalling;
        Doll        _currentDoll;
    }

    Vec2f mousePosition = Vec2f.zero;

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

        playerShots = new ShotArray();
        dolls = new DollArray();

        dolls.push(new Doll(_position));
        _currentDoll = dolls[0];
    }

    override void updateMovement(float deltaTime) {
        bool isMovingHorizontally;
        if(isKeyDown("left")) {
            isMovingHorizontally = true;
            _movementSpeed.x = _movementSpeed.x > -5f ?
                _movementSpeed.x - deltaTime * (_isFalling ? .3f : .8f) :
                -5f;

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
            _speed.y = 0f;
            _acceleration.y += -7f;
        }

        //Animation selection

        //Recover phase
        if(_recoverAnim.isRunning) {
            _currentAnim = _recoverAnim;
        }
        else if(_wasFalling && !_isFalling) {
            if(_currentAnim != _recoverAnim)
                _recoverAnim.start(.15f);
            _currentAnim = _recoverAnim;
        }
        else if(_isFalling) {
            if(_speed.y > .1f) {
                if(_currentAnim != _fallAnim)
                    _fallAnim.start(.5f);
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
            if(_currentAnim != _stopAnim)
                _stopAnim.start(.5f);
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
        _idleAnim.update(deltaTime);
        _runAnim.update(deltaTime);
        _fallAnim.update(deltaTime);
        _stopAnim.update(deltaTime);
        _recoverAnim.update(deltaTime);

        foreach(Shot shot; playerShots) {
            shot.update(deltaTime);
        }

        _currentDoll.playerPosition = _position;
        _currentDoll.movementSpeed  = _movementSpeed;
        _currentDoll.mousePosition  = mousePosition;
        _currentDoll.update(deltaTime);
    }

    override void draw() {
        _currentAnim.draw(_position);
        _currentDoll.draw();
        foreach(Shot shot; playerShots) {
            shot.draw();
        }
    }

    override void fire() {
        if(!_shotTimer.isRunning) {
            _currentDoll.fire();
            _shotTimer.start(.2f);
        }
    }

    override void handleCollision(Shot shot) {
        // @TODO
    }
}