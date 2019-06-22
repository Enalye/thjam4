module dollthread;

import atelier;

import game.player, game.doll;

final class DollThread {
    struct ThreadPoint {
        Vec2f position, speed;
    }

    private {
        ThreadPoint[5] _points;
    }

    Player _player;
    Doll _doll;

    this() {


    }

    void update(float deltaTime) {

    }

    void draw() {

        foreach(int i; 0.. 4) {
            drawLine(_points[i].position, _points[i + 1].position, Color.white);
        }
    }
}