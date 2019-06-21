module game.level;

import atelier;

private struct Layer {
    int[] ids;
    int tileWidth, tileHeight;
    Tileset tileset;

    void load(JSONValue json) {
        ids = getJsonArrayInt(json, "data");
        tileset = fetch!Tileset("level");
    }

    void draw() {
        auto size = tileWidth * tileHeight;
        Vec2f pos = Vec2f(16f, -tileHeight * 32f + 16f);
        for(int i; i < size; i ++) {
            if(ids[i] == 0)
                continue;
            const int x = i % tileWidth, y = i / tileWidth;
            tileset.draw(ids[i] - 1, pos + Vec2f(x, y) * 32f);
        }
    }
}

final class Level {
    private {
        Layer[] _layers;
        int _tileWidth, _tileHeight;
    }

    this(Level level) {
        _layers = level._layers;
    }

    this(JSONValue json) {
        _tileWidth = getJsonInt(json, "width");
        _tileHeight = getJsonInt(json, "height");

        foreach(layerNode; getJsonArray(json, "layers")) {
            Layer layer;
            layer.tileWidth = _tileWidth;
            layer.tileHeight = _tileHeight;
            layer.load(layerNode);
            _layers ~= layer;
        }
    }

    void draw() {
        foreach(ref layer; _layers) {
            layer.draw();
        }
    }
}