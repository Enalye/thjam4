module game.global;

import atelier;
import grimoire;
import game.entity, game.enemy, game.shot, game.doll, game.level, game.hud, game.scene;

// Owned by the scene
Level currentLevel;

// Virtual machine
GrEngine vm;

// Owned by the player instance
ShotArray playerShots;
DollArray dolls;

// Enemies
EnemyArray enemies;

// Owned by the enemy class
ShotArray enemyShots;

HudGui hud;

SceneGui sceneGlobal;

void createShot(EntityType ownerType, Vec2f pos, Vec2f scale, int damage, Color color, Vec2f direction, float speed, float timeToLive) {
	Shot shot = new Shot("shot", color, scale);
    Vec2f normalizedDirection = direction.normalized;

    shot.position    = pos;
    shot.direction   = normalizedDirection * speed;
    shot.timeToLive  = timeToLive;
    shot.damage      = damage;
    shot.spriteAngle = normalizedDirection.angle();

    if(ownerType == EntityType.PLAYER) {
    	shot.index = playerShots.push(shot);
    }

    if(ownerType == EntityType.ENEMY) {
    	shot.index = enemyShots.push(shot);
    }
}