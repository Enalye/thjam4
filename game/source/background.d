module game.background;

import atelier;

import game.camera, game.level, game.global;

final class Background {
    private {
        Sprite _bg;
    }

    this() {
        _bg = fetch!Sprite("level.foret");
        _bg.scale = Vec2f.one * 2f;
    }

    void draw() {
        auto camPos = getCameraPosition();
        float t1 = rlerp(0f, currentLevel.clampWidth, camPos.x);
        float t2 = rlerp(-1500f, 0f, camPos.y);
        Vec2f pos = Vec2f(
            lerp(_bg.size.x / 2f, currentLevel.clampWidth - _bg.size.x / 2f, t1),
            lerp(-1500f + _bg.size.y / 2f, 0f, t2)
        );
        _bg.draw(pos);
    }
}