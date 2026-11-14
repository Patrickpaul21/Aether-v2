from fastapi import FastAPI, HTTPException
import yt_dlp

app = FastAPI()


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
    opts = {"quiet": True, "extract_flat": True, "skip_download": True}
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(f"ytsearch{limit * 3}:{q}", download=False)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))
    results = []
    for entry in info.get("entries") or []:
        if not entry or not entry.get("id"):
            continue
        duration = entry.get("duration")
        if entry.get('live_status') in ('is_live', 'is_upcoming'):
            continue
        if duration is not None and (duration < 45 or duration > max_duration):
            continue
        results.append({
            "id": entry["id"],
            "title": entry.get("title"),
            "artist": entry.get("channel") or entry.get("uploader") or "Unknown",
            "duration": duration,
            "cover": f"https://i.ytimg.com/vi/{entry['id']}/hqdefault.jpg",
        })
        if len(results) >= limit:
            break
    return {"results": results}
