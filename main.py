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
