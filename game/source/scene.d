module game.scene;

import std.conv: to;
import atelier;
import grimoire;
import game.player, game.camera, game.entity, game.level, game.enemy, game.particles, game.coroutils;

import std.stdio: writeln;

void onSceneStart() {
    removeRootGuis();
    addRootGui(new SceneGui);
}

final class SceneGui: GuiElementCanvas {
    private {
        Player _player;
        Camera _camera;
        Level _level;
        Sparks _sparks;
        GrEngine _vm;

        IndexedArray!(Enemy, 100u) _enemies;
    }

    this() {
        position(Vec2f.zero);
        size(screenSize);
        setAlign(GuiAlignX.Left, GuiAlignY.Top);

        _player = new Player;
        _camera = createCamera(canvas);
        _camera.followEntity(_player);

        _sparks = createSparks();

        _level = fetch!Level("test");
        _vm    = new GrEngine;

        addPrimitives();
        auto bytecode = grCompileFile("data/script/fib.gr");
        _vm.load(bytecode);
        _vm.spawn();
    }

    /*~this() {
        destroyCamera();
    }*/

    override void update(float deltaTime) {
        _camera.update(deltaTime);
        _player.updatePhysic(deltaTime);
        _player.update(deltaTime);
        _sparks.update(deltaTime);

        if(_vm.hasCoroutines) {
            _vm.process();
        }

        if(_vm.isPanicking) {
            writeln("Unhandled Exception: " ~ to!string(_vm.panicMessage));
        }
    }

    override void onEvent(Event event) {
        switch(event.type) with(EventType) {
        case MouseUpdate:
            if(isNaN(event.position.x) || isNaN(event.position.y))
                break;
            _camera.mousePosition = event.position;
            _player.mousePosition = event.position;
            break;
        default:
            break;
        }
    }

    override void draw() {
        auto position = getCameraPosition();
        _level.draw();
        _sparks.draw();
        _player.draw();
        drawFilledRect(Vec2f(position.x - screenWidth / 2f, 0f), Vec2f(screenWidth, 5f), Color.white);
    }
}