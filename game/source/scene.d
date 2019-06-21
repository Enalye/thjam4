module game.scene;

import atelier;
import game.player, game.camera, game.entity;

void onSceneStart() {
    removeRootGuis();
    addRootGui(new SceneGui);
}

final class SceneGui: GuiElementCanvas {
    private {
        Player _player;
        Camera _camera;
    }

    this() {
        position(Vec2f.zero);
        size(screenSize);
        setAlign(GuiAlignX.Left, GuiAlignY.Top);

        _player = new Player;
        _camera = createCamera(canvas);
        _camera.followEntity(_player);
    }

    /*~this() {
        destroyCamera();
    }*/

    override void update(float deltaTime) {
        _camera.update(deltaTime);
        _player.updatePhysic(deltaTime);
        _player.update(deltaTime);
    }

    override void onEvent(Event event) {
        switch(event.type) with(EventType) {
        case MouseUpdate:
            _camera.mousePosition = event.position;
            break;
        default:
            break;
        }
    }

    override void draw() {
        auto position = getCameraPosition();
        _player.draw();
        drawFilledRect(Vec2f(position.x - screenWidth / 2f, 0f), Vec2f(screenWidth, 5f), Color.white);
    }
}