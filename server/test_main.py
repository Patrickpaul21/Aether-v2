from fastapi.testclient import TestClient

import main

client = TestClient(main.app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_search_returns_results_and_caches(monkeypatch):
    calls = []

    def fake_search(query, limit):
        calls.append(query)
        return [
            {
                "id": "abc12345678",
                "title": "T",
                "artist": "A",
                "duration": 200,
                "cover": "x",
            }
        ]

    monkeypatch.setattr(main.ytm, "search_songs", fake_search)
    main._cache.clear()
    first = client.get("/search", params={"q": "Test Song"})
    second = client.get("/search", params={"q": "test song"})
    assert first.status_code == 200
    assert first.json()["results"][0]["id"] == "abc12345678"
    assert second.json() == first.json()
    assert len(calls) == 1


def test_search_requires_a_query():
    assert client.get("/search").status_code == 422
