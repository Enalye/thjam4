module game.entity;

import std.algorithm.comparison;
import atelier;
import grimoire;
import game.shot, game.global;

enum EntityType { PLAYER, ENEMY };

abstract class Entity {
    protected {
        Vec2f _position = Vec2f.zero,
            _size = Vec2f.one,
            _speed = Vec2f.zero,
            _movementSpeed = Vec2f.zero,
            _acceleration = Vec2f.zero;

        bool _isFalling, _canDoubleJump, _hasGravity;

        int _index;
        int _life = 5, _maxLife = 5;

        enum Direction {
            Left, Right
        }
        Direction _direction;
    }

    @property {
        Vec2f position() { return _position; }
        void position(Vec2f position) { _position = position; }

        void movementSpeed(Vec2f movementSpeed) { _movementSpeed = movementSpeed; }
        Vec2f speed() { return _speed + _movementSpeed; }

        int life() { return _life; }
        int maxLife() { return _maxLife; }
    }

    void updatePhysic(float deltaTime) {
        _acceleration = Vec2f.zero;

        updateMovement(deltaTime);

        if(_isFalling) {
            _acceleration.y += .4f;
        }
        _speed += _acceleration * deltaTime;
        _position += (_speed + _movementSpeed) * deltaTime;
        
        if(_hasGravity) {
            float hitY = _position.y + _size.y / 2f;
            if(currentLevel.checkCollisionY(hitY, Vec2f(_position.x, _position.y + _size.y / 2f))) {
                if((_isFalling && _speed.y > 0f) || !_isFalling) {
                    _position.y = hitY - _size.y / 2f - 10f;
                    _isFalling = false;
                    _speed.y = 0f;
                    _canDoubleJump = true;
                }
            }
            else {
                _isFalling = true;
            }
        }
        
        if(_isFalling) {
            // Default
            if(position.y > (- _size.y / 2f)) {
                _position.y = - _size.y / 2f;
                _isFalling = false;
                _speed.y = 0f;
                _canDoubleJump = true;
            }
        }

        _position = _position.clamp(Vec2f(16f, -1500f), Vec2f(2486f, 200f));
    }

    abstract void updateMovement(float deltaTime);
    abstract void update(float deltaTime);
    abstract void draw();
    abstract void fire();
    abstract bool handleCollision(int damage, Shot shot = null);
}