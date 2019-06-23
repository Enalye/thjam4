module game.scene;

import std.conv: to;
import atelier;
import grimoire;

import game.global;
import game.camera;
import game.level;
import game.entity;
import game.player;
import game.enemy;
import game.shot;
import game.background;
import game.particles;
import game.coroutils;
import game.hud;

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
        Player     _player;
        Camera     _camera;
        Level      _level;
        Sparks     _sparks;
        Background _bg;
    }

    this() {
        position(Vec2f.zero);
        size(screenSize);
        setAlign(GuiAlignX.Left, GuiAlignY.Top);

        hud = new HudGui;
        hud.size = size;
        addRootGui(hud);

        currentLevel = _level = fetch!Level("level1");

        _player = new Player;
        _camera = createCamera(canvas);
        _camera.followEntity(_player);
        _camera.clip = Vec4f(0f, -1500f, _level.clampWidth, 200f);

        enemies = new EnemyArray();

        _sparks = createSparks();
        _bg = new Background;

        _modularCanvas = new Canvas(screenSize);
        _modularCanvas.setColorMod(Color.white, Blend.ModularBlending);

        playerShots = new ShotArray;
        enemyShots = new ShotArray;
        loadScripts();
    }
    
    void updateShots(float deltaTime) {
        // Update collisons of player shots
        foreach(Shot shot, uint index; playerShots) {      
            // Update movement of player shots
            shot.updateMovement(deltaTime);

            if(!shot.isAlive) {
                playerShots.markInternalForRemoval(index);
                continue;
            }

            // Handle collisions with enemies
            if(_level.checkCollision(shot.position)) {
                playerShots.markInternalForRemoval(index);
                continue;
            }

            foreach(Enemy enemy; enemies) {
                if(shot.handleCollision(enemy)) {
                    playerShots.markInternalForRemoval(index);
                    break;
                }
            }
        }
        playerShots.sweepMarkedData();

        // Update collisons of enemy shots
        foreach(Shot shot, uint index; enemyShots) {
            // Update movement of enemy shots
            shot.updateMovement(deltaTime);

            if(!shot.isAlive) {
                enemyShots.markInternalForRemoval(index);
                continue;
            }

            // Handle collisions with enemies
            if(_level.checkCollision(shot.position)) {
                enemyShots.markInternalForRemoval(index);
            } else if(shot.handleCollision(_player)) {
                enemyShots.markInternalForRemoval(index);
            } else if(shot.handleCollision(_player.currentDoll)) {
                enemyShots.markInternalForRemoval(index);
            }
        }
        enemyShots.sweepMarkedData();

        foreach(Enemy entity; enemies) {
            if(entity.position.distance(_player.position) < 40f) {
                _player.handleCollision(1);
            }
        }
    }

    void loadScripts() {
        vm = new GrEngine;
        addPrimitives();

        auto bytecode = grCompileFile("data/script/main.gr");
        //writeln(grDump(bytecode));
        vm.load(bytecode);
        vm.spawn();
    }

    /*~this() {
        destroyCamera();
    }*/

    override void update(float deltaTime) {
        updateShots(deltaTime);
        _camera.update(deltaTime);
        _player.updatePhysic(deltaTime);
        _player.update(deltaTime);
        _sparks.update(deltaTime);

        foreach(Enemy enemy, uint index; enemies) {
            enemy.updatePhysic(deltaTime);
            enemy.update(deltaTime);

            if(enemy.toDespawn) {
                enemies.markInternalForRemoval(index);
            }
        }

        foreach(Shot shot, uint index; playerShots) {
            if(!shot.isAlive) {
                playerShots.markInternalForRemoval(index);
            }
        }

        if(vm.hasCoroutines) {
            vm.process();
        }

        if(vm.isPanicking) {
            writeln("Unhandled Exception: " ~ to!string(vm.panicMessage));
        }

        enemies.sweepMarkedData();
        playerShots.sweepMarkedData();
    }

    override void onEvent(Event event) {
        switch(event.type) with(EventType) {
        case MouseUpdate:
            if(isNaN(event.position.x) || isNaN(event.position.y))
                break;
            _camera.mousePosition = event.position;
            _player.mousePosition = event.position;
            break;
        case MouseWheel:
            _player.selectNextDoll(event.position.y > 0f);
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
        _player.draw();
        foreach(Enemy enemy; enemies) {
            enemy.draw();
        }
        foreach(Shot shot; playerShots) {
            shot.draw();
        }
        foreach(Shot shot; enemyShots) {
            shot.draw();
        }
        
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