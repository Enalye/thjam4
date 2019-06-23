
/**
    Test application

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

import std.stdio: writeln;

import atelier;

import game.loader, game.scene, game.menu;

void main() {
	try {
        //Initialize
		createApplication(Vec2u(1280u, 720u), "Touhou Jam 4");

        import derelict.sdl2.sdl;
        bindKey("left", SDL_SCANCODE_A);
        bindKey("right", SDL_SCANCODE_D);
        bindKey("up", SDL_SCANCODE_W);
        bindKey("down", SDL_SCANCODE_S);
        bindKey("jump", SDL_SCANCODE_SPACE);

        //Loader
        onStartupLoad(&onLoadComplete);
		runApplication();
	}
	catch(Exception e) {
		writeln(e.msg);
	}
}

void onLoadComplete() {
    onMainMenu();
}

void onMainMenu() {
    removeRootGuis();
    addRootGui(new MenuGui);
}