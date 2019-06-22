module game.global;

import atelier;
import game.shot, game.doll, game.level;

// Owned by the scene
Level currentLevel;

// Owned by the player instance
ShotArray playerShots;
DollArray dolls;

// Owned by the enemy class
ShotArray enemyShots;

void createPlayerShot(Vec2f pos, Vec2f scale, int damage, Color color, Vec2f direction, float speed, float timeToLive) {
    Shot shot = new Shot("doll_1", color, scale);

    Vec2f normalizedDirection = direction.normalized;

    shot.position    = pos;
    shot.direction   = normalizedDirection * speed;
    shot.timeToLive  = timeToLive;
    shot.damage      = damage;
    shot.spriteAngle = normalizedDirection.angle();

    playerShots.push(shot);
    //playSound(SoundType.Shot);
}