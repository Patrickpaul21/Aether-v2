import time

from fastapi import FastAPI, HTTPException
import yt_dlp
from yt_dlp.version import __version__ as YTDLP_VERSION

app = FastAPI()

CACHE_TTL = 30 * 60
CACHE_MAX = 200
_cache: dict[tuple, tuple[float, dict]] = {}


def _cache_get(key):
    hit = _cache.get(key)
    if hit and time.time() - hit[0] < CACHE_TTL:
        return hit[1]
    return None


def _cache_set(key, value):
    _cache[key] = (time.time(), value)
    if len(_cache) > CACHE_MAX:
        oldest = min(_cache, key=lambda k: _cache[k][0])
        del _cache[oldest]


@app.get("/stream/{video_id}")
def get_stream(video_id: str):
    opts = {"format": "bestaudio/best", "quiet": True, "noplaylist": True}
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(
                f"https://www.youtube.com/watch?v={video_id}", download=False
            )
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))
    return {"title": info.get("title"), "url": info["url"]}


@app.get("/search")
def search(q: str, limit: int = 15, max_duration: int = 900):
    limit = max(1, min(limit, 25))
    key = (q.strip().lower(), limit, max_duration)
    cached = _cache_get(key)
    if cached is not None:
        return cached

    opts = {"quiet": True, "extract_flat": True, "skip_download": True}
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(f"ytsearch{limit * 2}:{q}", download=False)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))

    song_length, other = [], []
    for entry in info.get("entries") or []:
        if not entry or not entry.get("id"):
            continue
        if entry.get("live_status") in ("is_live", "is_upcoming"):
            continue
        duration = entry.get("duration")
        item = {
            "id": entry["id"],
            "title": entry.get("title"),
            "artist": entry.get("channel") or entry.get("uploader") or "Unknown",
            "duration": duration,
            "cover": f"https://i.ytimg.com/vi/{entry['id']}/hqdefault.jpg",
        }
        if duration is None or 45 <= duration <= max_duration:
            song_length.append(item)
        else:
            other.append(item)

    result = {"results": (song_length + other)[:limit]}
    _cache_set(key, result)
    return result


@app.get("/health")
def health():
    return {
        "status": "ok",
        "yt_dlp": YTDLP_VERSION,
        "cached_searches": len(_cache),
    }
