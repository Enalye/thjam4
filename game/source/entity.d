module game.entity;

import atelier;
import grimoire;
import game.shot, game.global;

abstract class Entity {
    protected {
        Vec2f _position = Vec2f.zero,
            _size = Vec2f.one,
            _speed = Vec2f.zero,
            _movementSpeed = Vec2f.zero,
            _acceleration = Vec2f.zero;

        bool _isFalling, _canDoubleJump, _hasGravity;

        int _index;

        enum Direction {
            Left, Right
        }
        Direction _direction;
    }

    @property {
        Vec2f position() { return _position; }
        void position(Vec2f position) { _position = position; }
        Vec2f speed() { return _speed + _movementSpeed; }
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
            //Default
            if(position.y > (- _size.y / 2f)) {
                _position.y = - _size.y / 2f;
                _isFalling = false;
                _speed.y = 0f;
                _canDoubleJump = true;
            }
        }
    }

    abstract void updateMovement(float deltaTime);
    abstract void update(float deltaTime);
    abstract void draw();
    abstract void fire();
    abstract void handleCollision(Shot shot);

    // APIs to handle behaviour of entities in VM
    /*public void getPosition(GrCall call) {
        call.setFloat(_position.x);
        call.setFloat(_position.y);
    }

    public void setPosition(GrCall call) {
        float x = call.getFloat("x");
        float y = call.getFloat("y");

        _position = Vec2f(x, y);
    }*/
}