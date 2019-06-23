module game.menu;

import atelier;

import game.scene;

final class MenuGui: GuiElement {
    private {
        Sprite _bg;
    }

    this() {
        size = screenSize;
        _bg = fetch!Sprite("alice.arcenciel");
        _bg.fit(size);

        auto btn = new TextButton(fetch!Font("VeraMono"), "Start Game");
        btn.setAlign(GuiAlignX.Right, GuiAlignY.Center);
        btn.position = Vec2f(50f, 10f);
        btn.size = Vec2f(200f, 50f);
        btn.setCallback(this, "start");
        addChildGui(btn);
    }

    override void onCallback(string id) {
        if(id == "start") {
            onSceneStart();
        }
    }

    override void draw() {
        _bg.draw(center);
    }
}