module game.dollthread;

import atelier;

import game.player, game.doll;

private enum _nbPoints = 20;
final class DollThread {
    struct ThreadPoint {
        Vec2f position = Vec2f.zero, speed = Vec2f.zero, nextPosition;
    }

    private {
        ThreadPoint[_nbPoints] _points;
    }

    Player player;
    Doll doll;

    void init() {
        foreach(int i; 0.. _nbPoints) {
            _points[i].position = player.position.lerp(doll.position, lerp(.05f, .95f, cast(float)i / cast(float)_nbPoints));
        }
    }

    void update(float deltaTime) {
        if(isNaN(doll.position.x) || isNaN(doll.position.y)) {
            doll.init();
            init();
            return;
        }
        foreach(int i; 0.. _nbPoints) {
            Vec2f acceleration = Vec2f.zero;
            acceleration.y += .5f;

            if(i == 0) {
                auto targetPos = lerp(player.position, _points[1].position, .5f);
                acceleration += (targetPos - _points[0].position) * .7f;
            }
            else if(i == _nbPoints - 1) {
                auto targetPos = lerp(_points[$ - 2].position, doll.position, .5f);
                acceleration += (targetPos - _points[$ - 1].position) * .7f;
            }
            else {
                auto targetPos = lerp(_points[i - 1].position, _points[i + 1].position, .5f);
                acceleration += (targetPos - _points[i].position) * .7f;
            }

            _points[i].speed += acceleration * deltaTime;
            _points[i].speed *= .8f * deltaTime;
            _points[i].nextPosition = _points[i].position + _points[i].speed * deltaTime;
        }

        foreach(int i; 0.. _nbPoints) {
            _points[i].position = _points[i].nextPosition;
        }
    }

    void draw() {
        Color[] colors = [Color.red, Color.blue, Color.white];

        drawLine(player.position, _points[0].position, Color.red);
        foreach(int i; 0.. _nbPoints - 1) {
            Color color = colors[i % 3];
            drawLine(_points[i].position, _points[i + 1].position, color);
        }
        drawLine(_points[$ - 1].position, doll.position, Color.white);
    }
}