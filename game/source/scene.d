module game.scene;

import std.conv: to;
import atelier;
import grimoire;
import game.player, game.camera, game.entity, game.level, game.enemy, game.background, game.particles, game.coroutils;

import std.stdio: writeln;

private {
    Canvas _modularCanvas;
}

void pushModularCanvas() {
    pushCanvas(_modularCanvas, false);
}

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
        Background _bg;
        GrEngine _vm;

        EnemyArray _enemies;
    }

    this() {
        position(Vec2f.zero);
        size(screenSize);
        setAlign(GuiAlignX.Left, GuiAlignY.Top);

        _player = new Player;
        _camera = createCamera(canvas);
        _camera.followEntity(_player);

        _enemies = new EnemyArray();
        _enemies.push(new Enemy("enemy2", Vec2f(250f, -250f)));

        _sparks = createSparks();
        _bg = new Background;

        _modularCanvas = new Canvas(screenSize);
        _modularCanvas.setColorMod(Color.white, Blend.ModularBlending);

        _level = fetch!Level("test");
        _vm    = new GrEngine;

        addPrimitives();
        auto bytecode = grCompileFile("data/script/rainbow.gr");
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

        foreach(Enemy enemy; _enemies) {
            enemy.update(deltaTime);
        }

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
        canvas.clearColor = Color(.38f, .41f, .31f);
        auto position = getCameraPosition();
        _bg.draw();
        _level.draw();
        _sparks.draw();

        // @TODO review draw order
        foreach(Enemy enemy; _enemies) {
            enemy.draw();
        }
        _player.draw();
        
        _modularCanvas.position = canvas.position;
        _modularCanvas.draw(position);
        pushCanvas(_modularCanvas, true);
        drawFilledRect(position - screenSize / 2f, screenSize, Color.white * .2f);
        auto glow = fetch!Sprite("fx.glow");
        glow.size = Vec2f.one * 800f;
        glow.draw(_player.position);
        popCanvas();
        
        //Debug ground
        //drawFilledRect(Vec2f(position.x - screenWidth / 2f, 0f), Vec2f(screenWidth, 5f), Color.white);
    }
}