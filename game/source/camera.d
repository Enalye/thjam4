module game.camera;

import std.conv: to;
import std.random: uniform01;
import std.algorithm.comparison: clamp;

import atelier;
import game.entity;

private {
	Camera _camera;
}

Camera createCamera(Canvas canvas) {
	return _camera = new Camera(canvas);
}

void destroyCamera() {
	_camera = null;
}

Vec2f getCameraPosition() {
	return _camera.canvasPosition;
}

void shakeCamera(Vec2f intensity, float duration) {
	if(!_camera)
		return;
	_camera.shake(intensity, duration);
}

void moveCameraTo(Vec2f position, float duration = 0f) {
	if(!_camera)
		return;
	_camera.moveTo(position, duration);
}

final package class Camera {
	private {
		Vec2f _position = Vec2f.zero,
            _shakeIntensity = Vec2f.zero,
            _size = Vec2f.one,
            _speed = Vec2f.zero;
		Vec4f _clip = Vec4f.zero;
		Timer _shakeTimer, _translationTimer;
		Vec2f _translationOrigin, _translationDestination;
        bool _isFollowingEntity;
        Entity _followedEntity;
        Canvas _canvas;
	}

    Vec2f mousePosition = Vec2f.zero;

	@property {
		Vec2f canvasPosition() { return _canvas.position; }
		Vec2f canvasPosition(Vec2f newPosition) {
			_canvas.position = newPosition;
			return _position = newPosition;
		}

		Vec4f clip() { return _clip; }
		Vec4f clip(Vec4f newClip) {
			return _clip = newClip;
		}
	}

	float zoom = 1f;

	this(Canvas canvas) {
        _canvas = canvas;
		_position = _canvas.position;
	}
	
	void update(float deltaTime) {
		//Translation
		if(_translationTimer.isRunning) {
			_translationTimer.update(deltaTime);			
			_position = _translationOrigin.lerp(_translationDestination, easeOutSine(_translationTimer.time));
		}
        else if(_isFollowingEntity) {
            const Vec2f targetPosition = _followedEntity.position.lerp(mousePosition, .2f);
            _speed = _followedEntity.speed + (targetPosition - _position) * deltaTime * 0.3f;
            mousePosition += _speed;
        }
        _position += _speed * deltaTime;
writeln(_position, ", ", _speed, ", ", mousePosition);
		//clamp
		if(_clip.z > _clip.x) {
			if(_canvas.size.x > (_clip.z - _clip.x))
				_position.x = 0f;
			else
				_position.x = clamp(_position.x, _clip.x + _canvas.size.x / 2f, _clip.z - _canvas.size.x / 2f);
		}
		if(_clip.w > _clip.y) {
			if(_canvas.size.y > (_clip.w - _clip.y))
				_position.y = 0f;
			else
				_position.y = clamp(_position.y, _clip.y + _canvas.size.y / 2f, _clip.w - _canvas.size.y / 2f);
		}

		//Apply post effects
		if(_shakeTimer.isRunning) {
			Vec2f currentShake = -_shakeIntensity + 2f * _shakeIntensity * Vec2f(uniform01(), uniform01());
			_shakeTimer.update(deltaTime);
			_canvas.position = _position + currentShake.lerp(Vec2f.zero, _shakeTimer.time);
		}
		else
			_canvas.position = _position;
	}

	void shake(Vec2f intensity, float duration) {
		_shakeIntensity = intensity;
		_shakeTimer.start(duration);
	}

	void moveTo(Vec2f center, float duration) {
        _isFollowingEntity = false;
		_translationOrigin = _canvas.position;
		_translationDestination = center;
		_translationTimer.start(duration);
	}

    void followEntity(Entity entity) {
        _isFollowingEntity = true;
        _followedEntity = entity;
    }
}