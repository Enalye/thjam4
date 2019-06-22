module game.enemy;

import std.conv: to;
import std.stdio: writeln;
import std.algorithm.comparison;

import atelier;
import game.entity, game.shot;

alias EnemyArray = IndexedArray!(Enemy, 100u);

final class Enemy: Entity {
	private {
		Animation _currentAnim, _idleAnim;
		float _lastBarRatio = 1f, _lifeRatio = 1f;
		Timer _deathTimer;
	}

	this(int index, string name, Vec2f position) {
		_index    = index;
		_position = position;
		_idleAnim = new Animation(name ~ ".idle");
		_idleAnim.start(.5f, TimeMode.Loop);
		_currentAnim = _idleAnim;
	}

	@property {
	    bool isAlive() { return (_life > 0) || _deathTimer.isRunning(); }
	}

	override void updateMovement(float deltaTime) {
		// Logic mainly implemented in coroutines
		if(_life == 0) {
			_deathTimer.start(0.5f);
		}
	}

	override void update(float deltaTime) {
		_idleAnim.update(deltaTime);

		// Lifebar
        _lifeRatio = cast(float)(_life) / _maxLife;
        _lastBarRatio = lerp(_lastBarRatio, _lifeRatio, deltaTime * .1f);
	}

	override void draw() {
		// writeln(_position);
		_currentAnim.draw(_position);
		drawLifeBar();
	}

	private void drawLifeBar() {
        Vec2f lbPos = _position - Vec2f(0f, 50f);
        Vec2f lbSize = Vec2f(35f, 10f);
        Vec2f lbBorderSize = lbSize + Vec2f(2f, 2f);
        Vec2f lbLifeSize = Vec2f(lbSize.x * _lifeRatio, lbSize.y);
        Vec2f lbLifeSize2 = Vec2f(lbSize.x * _lastBarRatio, lbSize.y);
        drawFilledRect(lbPos - lbBorderSize / 2f, lbBorderSize, Color.white);
        drawFilledRect(lbPos - lbSize / 2f, lbSize, Color.black);
        drawFilledRect(lbPos - lbSize / 2f, lbLifeSize2, Color.white);
        drawFilledRect(lbPos - lbSize / 2f, lbLifeSize, Color.red);
    }

	override void fire() {

	}

	override void handleCollision(Shot shot) {
		if(shot.isAlive) {
        	_life = max(0, _life - shot.damage);
        }
    }
}