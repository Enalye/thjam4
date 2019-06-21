module game.player;

import std.conv: to;
import std.stdio: writeln;
import atelier;
import game.entity;

import derelict.sdl2.sdl;

final class Player: Entity {
    private {
        bool _hasPlayerInput;
        Animation _idleAnim, _runAnim;
    }

    Vec2f mousePosition = Vec2f.zero;

    this() {
        _idleAnim = new Animation("alice.idle");
        _runAnim = new Animation("alice.run");
        _idleAnim.start(.5f, TimeMode.Loop);
        _runAnim.start(.5f, TimeMode.Loop);

        _size = to!Vec2f(_idleAnim.tileSize);
        _position = Vec2f(0f, -_size.y / 2f);
        _speed = Vec2f.zero;
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
            _hasPlayerInput = true;
        }
        if(isMovingHorizontally) {
            _movementSpeed.x *= deltaTime * _isFalling ? .999f : .8f;
            _hasPlayerInput = false;
        }

        if(!_isFalling && getKeyDown("jump")) {
            _acceleration.y += -8f;
            _isFalling = true;
        }
        if(_isFalling && _canDoubleJump && getKeyDown("jump")) {
            _canDoubleJump = false;
            _speed.y = 0f;
            _acceleration.y += -7f;
        }

        if(isButtonDown(SDL_BUTTON_LEFT)) {
            fire();
        }
    }

    override void update(float deltaTime) {
        _idleAnim.update(deltaTime);
        _runAnim.update(deltaTime);
    }

    override void draw() {
        if(_hasPlayerInput && !_isFalling)
            _runAnim.draw(_position);
        else
            _idleAnim.draw(_position);
    }

    override void fire() {
        // @TODO
    }
}