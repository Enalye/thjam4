module game.menu;

import atelier;

import game.scene;

void setVictory() {
    removeRootGuis();
    addRootGui(new VictoryGui);
}

final class VictoryGui: GuiElement {
    private {
        Sprite _sprite;
    }

    this() {
        _sprite = fetch!Sprite("alice.victoire");
        size = _sprite.size;
    }

    override void onEvent(Event event) {
        if(event.type == EventType.MouseDown) {
            removeRootGuis();
            addRootGui(new MenuGui);
        }
    }

    override void draw() {
        _sprite.draw(center);
    }
}

final class StartButton: Button {
    private {
        Sprite _startSprite;
    }

    this() {
        _startSprite = fetch!Sprite("start");
        size = _startSprite.size;
    }

    override void draw() {
        _startSprite.draw(center);
    }
}

final class IntroGui1: GuiElement {
    private {
        Sprite _sprite;
    }

    this() {
        _sprite = fetch!Sprite("alice.arcenciel");
        size = _sprite.size;
    }

    override void onEvent(Event event) {
        if(event.type == EventType.MouseDown) {
            removeRootGuis();
            addRootGui(new IntroGui2);
        }
    }

    override void draw() {
        _sprite.draw(center);
    }
}

final class IntroGui2: GuiElement {
    private {
        Sprite _sprite;
    }

    this() {
        _sprite = fetch!Sprite("alice.grimoire");
        size = _sprite.size;
    }

    override void onEvent(Event event) {
        if(event.type == EventType.MouseDown) {
            removeRootGuis();
            addRootGui(new IntroGui3);
        }
    }

    override void draw() {
        _sprite.draw(center);
    }
}

final class IntroGui3: GuiElement {
    private {
        Sprite _sprite;
    }

    this() {
        _sprite = fetch!Sprite("alice.dernier");
        size = _sprite.size;
    }

    override void onEvent(Event event) {
        if(event.type == EventType.MouseDown) {
            removeRootGuis();
            addRootGui(new TutoGui);
        }
    }

    override void draw() {
        _sprite.draw(center);
    }
}

final class TutoGui: GuiElement {
    private {
        Sprite _sprite;
    }

    this() {
        _sprite = fetch!Sprite("tuto");
        size = _sprite.size;
    }

    override void onEvent(Event event) {
        if(event.type == EventType.MouseDown) {
            removeRootGuis();
            addRootGui(new MenuGui);
        }
    }

    override void draw() {
        _sprite.draw(center);
    }
}

final class MenuGui: GuiElement {
    private {
        Sprite _bg;
    }

    this() {
        size = screenSize;
        _bg = fetch!Sprite("alice.menu");
        _bg.fit(size);

        {
            auto btn = new StartButton;
            btn.setAlign(GuiAlignX.Left, GuiAlignY.Bottom);
            btn.position = Vec2f(150f, 150f);
            btn.setCallback(this, "start");
            addChildGui(btn);
        }
        {
            auto btn = new TextButton(fetch!Font("VeraMono"), "tutorial");
            btn.setAlign(GuiAlignX.Left, GuiAlignY.Bottom);
            btn.position = Vec2f(150f, 50f);
            btn.setCallback(this, "tuto");
            addChildGui(btn);
        }

        {
            auto txt = new Text;
            txt.setAlign(GuiAlignX.Right, GuiAlignY.Bottom);
            txt.position = Vec2f(50f, 50f);
            txt.text = "Crédits:{n}{n}  Automn'{n}  JonathKane{n}  Enalye{n}  MrNuage";
            addChildGui(txt);
        }
    }

    override void onCallback(string id) {
        if(id == "start") {
            onSceneStart();
        }
        else if(id == "tuto") {
            removeRootGuis();
            addRootGui(new TutoGui);
        }
    }

    override void draw() {
        _bg.draw(center);
    }
}