module game.particles;

import atelier;

private {
    Sparks _sparks;
}

Sparks createSparks() {
    return _sparks = new Sparks;
}

void spawnSpark(Spark spark) {
    if(!_sparks)
        return;
    _sparks.add(spark);
}

class Spark {
    Vec2f position = Vec2f.zero, velocity = Vec2f.zero;
    float speed = 0f, scale = 1f, time = 0f, timeToLive = 1f;
    Sprite sprite;
    bool isAlive = true;

    abstract void update(float deltaTime);
}

alias SparkArray = IndexedArray!(Spark, 1000u);
final class Sparks {
    SparkArray _sparks;
    
    this() {
        _sparks = new SparkArray;
    }

    void update(float deltaTime) {
        foreach(Spark spark, uint index; _sparks) {
            spark.position += spark.velocity * deltaTime;
            spark.time += (deltaTime / 60f);
            spark.update(deltaTime);
            const float t = spark.time / spark.timeToLive;
            if(t > 1f || !spark.isAlive)
               _sparks.markInternalForRemoval(index);
        }
        _sparks.sweepMarkedData();
    }

    void add(Spark spark) {
        _sparks.push(spark);
    }

    void draw() {
        foreach(Spark spark, uint index; _sparks) {
            spark.sprite.draw(spark.position);
        }
    }
}