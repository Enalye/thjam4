module game.shot;

import atelier;
import game.entity;

alias ShotArray = IndexedArray!(Shot, 2000);

class Shot {
    protected {
        Vec2f   _position, _direction;
        Sprite  _sprite;
        float   _spriteAngle;
        float   _radius = 25f;
        float   _time = 0f, _timeToLive = 1f;
        bool    _isAlive = true;
        int     _damage = 1;
    }

    @property {
        bool isAlive() const { return _isAlive; }
        int damage() const { return _damage; }

        Vec2f position(Vec2f newPosition) { return _position = newPosition; }
        Vec2f direction(Vec2f newDirection) { return _direction = newDirection; }
        float timeToLive(float newTTL) { return _timeToLive = newTTL; }
        int damage(int damage) { return _damage = damage; }
        float spriteAngle(float spriteAngle) { return _spriteAngle = spriteAngle; }

        void color(Color color) { _sprite.color = color; }
    }

    this(string fileName, Color color = Color.white, Vec2f scale = Vec2f.one) {
        _sprite = fetch!Sprite(fileName);
        _sprite.color = color;
        _sprite.scale = scale;
    }

    void update(float deltaTime) {
        _position += _direction * deltaTime;
        _time += deltaTime;
        if(_time > _timeToLive) {
            _isAlive = false;
        }
    }

    void draw() {
        _sprite.angle = _spriteAngle;
        _sprite.draw(_position);
    }

    bool handleCollision(Entity entity) {
        if(entity.position.distance(_position) < _radius) {
            entity.handleCollision(this);
            _isAlive = false;
            return true;
        }
        return false;
    }
}