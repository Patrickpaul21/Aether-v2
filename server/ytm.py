import re

from ytmusicapi import YTMusic

_NOISE = re.compile(
    r"\b(karaoke|instrumental|nightcore|8d|slowed|sped up|vocals only|tribute)\b|[|(\[]\s*cover\b",
    re.I,
)


def _big(url):
    return re.sub(r"=w\d+-h\d+", "=w544-h544", url)


_client = None


def _ytm():
    global _client
    if _client is None:
        _client = YTMusic()
    return _client


def _seconds(item):
    value = item.get("duration_seconds")
    if value:
        return int(value)
    text = item.get("duration")
    if not text:
        return None
    try:
        total = 0
        for part in text.split(":"):
            total = total * 60 + int(part)
        return total
    except ValueError:
        return None


def search_songs(query, limit):
    results = _ytm().search(query, filter="songs", limit=limit)
    out = []
    for r in results[:limit]:
        video_id = r.get("videoId")
        if not video_id:
            continue
        artists = r.get("artists") or []
        artist = ", ".join(a["name"] for a in artists if a.get("name")) or "Unknown"
        thumbs = r.get("thumbnails") or []
        cover = (
            _big(thumbs[-1]["url"])
            if thumbs
            else f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg"
        )
        out.append(
            {
                "id": video_id,
                "title": r.get("title"),
                "artist": artist,
                "duration": _seconds(r),
                "cover": cover,
            }
        )
    if not _NOISE.search(query):
        out.sort(key=lambda x: bool(_NOISE.search(x["title"] or "")))
    return out
