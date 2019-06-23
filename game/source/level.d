module game.level;

import std.conv: to;
import atelier;

private struct Layer {
    int[] ids;
    int tileWidth, tileHeight;
    Tileset tileset;

    void load(JSONValue json) {
        ids = getJsonArrayInt(json, "data");
        tileset = fetch!Tileset("level");
    }

    bool checkCollision(Vec2f pos) {
        const auto size = tileWidth * tileHeight;
        Vec2i coords = to!Vec2i(((pos - Vec2f.one * 16f) / 32f).round()) + Vec2i(0, tileHeight);
        if(!coords.isBetween(Vec2i.zero, Vec2i(tileWidth, tileHeight)))
            return false;
        int id = coords.y * tileWidth + coords.x;
        //Just to be sure
        if(id < 0 || id >= size)
            return false;
        if(ids[id] == 0)
            return false;
        return true;
    }

    bool checkCollisionY(ref float hitY, Vec2f pos, bool isRecursive = false) {
        const auto size = tileWidth * tileHeight;
        Vec2f origin = Vec2f(16f, -tileHeight * 32f + 16f);
        Vec2i coords = to!Vec2i(((pos - Vec2f.one * 16f) / 32f).round()) + Vec2i(0, tileHeight);
        if(!coords.isBetween(Vec2i.zero, Vec2i(tileWidth, tileHeight)))
            return false;
        int id = coords.y * tileWidth + coords.x;
        //Just to be sure
        if(id < 0 || id >= size)
            return false;
        if(ids[id] == 0)
            return false;

        if(isRecursive) {
            int nId = (coords.y - 1) * tileWidth + coords.x;
            if(nId > 0 && nId < size) {
                if(ids[nId] > 0) {
                    if(checkCollisionY(hitY, pos - Vec2f(0f, 8f))) {
                        return true;
                    }
                }
            }
        }
        
        const float step = (pos.x % 32f) / 32f;
        if(ids[id] == 1 || ids[id] == 3)
            hitY = origin.y + coords.y * 32f;
        else if(ids[id] == 2)
            hitY = origin.y + coords.y * 32f + lerp(32f, 0f, step);
        else if(ids[id] == 4)
            hitY = origin.y + coords.y * 32f + lerp(0f, 32f, step);
        else
           return false;
        return true;
    }

    void draw() {
        const auto size = tileWidth * tileHeight;
        Vec2f pos = Vec2f(16f, -tileHeight * 32f + 16f);
        for(int i; i < size; i ++) {
            if(ids[i] == 0)
                continue;
            const int x = i % tileWidth, y = i / tileWidth;
            tileset.draw(ids[i] - 1, pos + Vec2f(x, y) * 32f);
        }
    }
}

private struct ObjLayer {
    void load(JSONValue json) {
        auto objects = getJsonArray(json, "objects");
    }

    void draw() {

    }
}

final class Level {
    private {
        Layer[] _layers;
        ObjLayer[] _objLayers;
        int _tileWidth, _tileHeight;
    }

    @property {
        float clampWidth() { return (_tileWidth * 32f) - 16f; }
    }

    this(Level level) {
        _layers = level._layers;
        _objLayers = level._objLayers;
        _tileWidth = level._tileWidth;
        _tileHeight = level._tileHeight;
    }

    this(JSONValue json) {
        _tileWidth = getJsonInt(json, "width");
        _tileHeight = getJsonInt(json, "height");

        foreach(layerNode; getJsonArray(json, "layers")) {
            auto type = getJsonStr(layerNode, "type");
            if(type == "tilelayer") {
                Layer layer;
                layer.tileWidth = _tileWidth;
                layer.tileHeight = _tileHeight;
                layer.load(layerNode);
                _layers ~= layer;
            }
            else if(type == "objectgroup") {
                ObjLayer layer;
                layer.load(layerNode);
                _objLayers ~= layer;
            }
        }
    }

    bool checkCollision(Vec2f pos) {
        foreach(ref layer; _layers) {
            if(layer.checkCollision(pos))
                return true;
        }
        return false;
    }

    bool checkCollisionY(ref float hitY, Vec2f pos) {
        foreach(ref layer; _layers) {
            if(layer.checkCollisionY(hitY, pos, true))
                return true;
        }
        return false;
    }

    void draw() {
        foreach(ref layer; _layers) {
            layer.draw();
        }
        foreach(ref layer; _objLayers) {
            layer.draw();
        }
    }
}