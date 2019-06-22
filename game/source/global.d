module game.global;

import atelier;
import grimoire;
import game.enemy, game.shot, game.doll, game.level, game.hud;

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

void createPlayerShot(Vec2f pos, Vec2f scale, int damage, Color color, Vec2f direction, float speed, float timeToLive) {
    Shot shot = new Shot("shot", color, scale);

    Vec2f normalizedDirection = direction.normalized;

    shot.position    = pos;
    shot.direction   = normalizedDirection * speed;
    shot.timeToLive  = timeToLive;
    shot.damage      = damage;
    shot.spriteAngle = normalizedDirection.angle();

    playerShots.push(shot);
    //playSound(SoundType.Shot);
}