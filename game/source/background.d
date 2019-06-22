module game.background;

import atelier;

final class Background {
    private {
        Sprite _bg;
    }

    this() {
        _bg = fetch!Sprite("level.foret");
        _bg.scale = Vec2f.one * 2f;
        _bg.anchor = Vec2f(0f, 1f);
    }

    void draw() {
        _bg.draw(Vec2f.zero);
    }
}