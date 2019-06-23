module game.hud;

import atelier;

import game.player, game.global;

class DialogGui: GuiElement {
    private {
        Sprite _dialogSprite;
        Text _text;
    }

    this() {
        setAlign(GuiAlignX.Center, GuiAlignY.Bottom);
        _dialogSprite = fetch!Sprite("dialogue");
        size = _dialogSprite.size;
        _text = new Text(80);
        _text.setAlign(GuiAlignX.Center, GuiAlignY.Center);
        addChildGui(_text);



        GuiState hiddenState = {
            offset: Vec2f(0f, -size.y),
            color: Color.clear
        };
        addState("hidden", hiddenState);

        GuiState defaultState = {
            time: .5f,
            easingFunction: getEasingFunction("sine-out")
        };
        addState("default", defaultState);

        setState("hidden");
    }

    void setText(string t) {
        _text.text = t;
    }

    override void draw() {
        _dialogSprite.draw(center);
    }
}

class AlicePortrait: GuiElement {
    private {
        Sprite _alice1Sprite, _alice2Sprite, _currentSprite;
    }

    this() {
        setAlign(GuiAlignX.Left, GuiAlignY.Bottom);
        _alice1Sprite = fetch!Sprite("portrait.alice1");
        _alice2Sprite = fetch!Sprite("portrait.alice2");
        _currentSprite = _alice1Sprite;
        size = _alice1Sprite.size;

        GuiState hiddenState = {
            offset: Vec2f(-size.x, 0f),
            color: Color.clear
        };
        addState("hidden", hiddenState);

        GuiState defaultState = {
            time: .5f,
            easingFunction: getEasingFunction("sine-out")
        };
        addState("default", defaultState);

        setState("hidden");
    }

    void setPortrait(int id, bool hasFocus) {
        _currentSprite = id == 1 ? _alice1Sprite : _alice2Sprite;
        _currentSprite.color = hasFocus ? Color.white : Color(.5f, .5f, .6f);
    }

    override void draw() {
        _currentSprite.draw(center);
    }
}

class MediPortrait: GuiElement {
    private {
        Sprite _medi1Sprite, _medi2Sprite, _currentSprite;
    }

    this() {
        setAlign(GuiAlignX.Right, GuiAlignY.Bottom);
        _medi1Sprite = fetch!Sprite("portrait.medi1");
        _medi2Sprite = fetch!Sprite("portrait.medi2");
        _currentSprite = _medi1Sprite;
        size = _medi1Sprite.size;

        GuiState hiddenState = {
            offset: Vec2f(-size.x, 0f),
            color: Color.clear
        };
        addState("hidden", hiddenState);

        GuiState defaultState = {
            time: .5f,
            easingFunction: getEasingFunction("sine-out")
        };
        addState("default", defaultState);

        setState("hidden");
    }

    void setPortrait(int id, bool hasFocus) {
        _currentSprite = id == 1 ? _medi1Sprite : _medi2Sprite;
        _currentSprite.color = hasFocus ? Color.white : Color(.5f, .5f, .6f);
    }

    override void draw() {
        _currentSprite.draw(center);
    }
}

final class HudGui: GuiElement {
    Player player;

    bool showDialog;

    private {
        Label _dollLabel;
        float _lifeRatio = 1f, _lastBarRatio = 0f;
        DialogGui _dialogGui;
        AlicePortrait _alicePortrait;
        MediPortrait _mediPortrait;
    }

    this() {
        _dollLabel = new Label(fetch!Font("VeraMono"), "");
        _dollLabel.position = Vec2f(50f, 70f);
        _dollLabel.anchor = Vec2f.zero;
        addChildGui(_dollLabel);

        addChildGui(_dialogGui = new DialogGui);
        addChildGui(_alicePortrait = new AlicePortrait);
        addChildGui(_mediPortrait = new MediPortrait);
    }

    void changeDoll() {
        if(!player)
            return;
        _dollLabel.text = player.currentDoll.name;
    }

    override void update(float deltaTime) {
        if(!player)
            return;
        _lifeRatio = cast(float)(player.life) / player.maxLife;
        _lastBarRatio = lerp(_lastBarRatio, _lifeRatio, deltaTime * .1f);
    }

    override void draw() {
        drawLifeBar();

        if(sceneGlobal) {
            sceneGlobal.isLocked = showDialog;

            if(showDialog) {
                import derelict.sdl2.sdl;
                if(getButtonDown(SDL_BUTTON_LEFT)) {
                    showDialog = false;
                    sceneGlobal.isLocked = false;
                    _dialogGui.doTransitionState("hidden");
                    _alicePortrait.doTransitionState("hidden");
                    _mediPortrait.doTransitionState("hidden");
                }              
            }
        }
    }

    void setDialog(string text, int ali, int medi, bool who) {
        showDialog = true;
        _dialogGui.setText(text);
        _dialogGui.doTransitionState("default");
        if(ali > 0) {
            _alicePortrait.setPortrait(ali, !who);
            _alicePortrait.doTransitionState("default");
        }
        if(medi > 0) {
            _mediPortrait.setPortrait(medi, who);
            _mediPortrait.doTransitionState("default");
        }
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