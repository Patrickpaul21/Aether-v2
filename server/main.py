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
def search(q: str, limit: int = 15):
    limit = max(1, min(limit, 25))
    opts = {"quiet": True, "extract_flat": True, "skip_download": True}
    try:
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(f"ytsearch{limit}:{q}", download=False)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))
    results = []
    for entry in info.get("entries") or []:
        if not entry or not entry.get("id"):
            continue
        results.append({
            "id": entry["id"],
            "title": entry.get("title"),
            "artist": entry.get("channel") or entry.get("uploader") or "Unknown",
            "duration": entry.get("duration"),
            "cover": f"https://i.ytimg.com/vi/{entry['id']}/hqdefault.jpg",
        })
    return {"results": results}
