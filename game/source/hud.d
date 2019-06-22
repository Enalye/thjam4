module game.hud;

import atelier;

import game.player;

final class HudGui: GuiElement {
    Player player;

    private {
        float _lifeRatio = 1f, _lastBarRatio = 0f;
    }

    override void update(float deltaTime) {
        if(!player)
            return;
        _lifeRatio = cast(float)(player.life) / player.maxLife;
        _lastBarRatio = lerp(_lastBarRatio, _lifeRatio, deltaTime * .1f);
    }

    override void draw() {
        drawLifeBar();
    }

    private void drawLifeBar() {
        Vec2f lbPos = Vec2f(50f, 50f);
        Vec2f lbSize = Vec2f(250f, 10f);
        Vec2f lbBorderSize = lbSize + Vec2f(2f, 2f);
        Vec2f lbLifeSize = Vec2f(lbSize.x * _lifeRatio, lbSize.y);
        Vec2f lbLifeSize2 = Vec2f(lbSize.x * _lastBarRatio, lbSize.y);
        drawFilledRect(lbPos - Vec2f.one, lbBorderSize, Color.white);
        drawFilledRect(lbPos, lbSize, Color.black);
        drawFilledRect(lbPos, lbLifeSize2, Color.white);
        drawFilledRect(lbPos, lbLifeSize, Color.red);
    }
}