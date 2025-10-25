import base64
from typing import List, Dict, Any
import httpx

from ..config import get_settings

GEMINI_MODEL = "gemini-1.5-flash"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"


def _api_key() -> str:
    settings = get_settings()
    if not settings.google_api_key:
        raise RuntimeError("FC_GOOGLE_API_KEY not set")
    return settings.google_api_key


def suggest_tags_from_text(text: str, max_tags: int = 8) -> List[str]:
    """Call Gemini text model to suggest short, lowercase tags from description."""
    prompt = (
        "Suggest concise, lowercase tags (1-2 words) for the following food listing. "
        "Return only a JSON array of strings with at most %d items.\n\nText:\n%s" % (max_tags, text)
    )
    payload = {
        "contents": [{"parts": [{"text": prompt}]}]
    }
    params = {"key": _api_key()}
    with httpx.Client(timeout=30) as client:
        r = client.post(GEMINI_URL, params=params, json=payload)
        r.raise_for_status()
        data = r.json()
    # Extract text
    candidates = data.get("candidates", [])
    if not candidates:
        return []
    text_resp = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "[]")
    # Try to parse as JSON array
    try:
        import json
        arr = json.loads(text_resp)
        if isinstance(arr, list):
            # Normalize
            return [str(x).strip().lower() for x in arr if str(x).strip()]
    except Exception:
        pass
    # Fallback: split by commas/newlines
    parts = [p.strip().lower() for p in text_resp.replace("\n", ",").split(",")]
    return [p for p in parts if p][:max_tags]


def recipe_from_pantry(images_base64: List[str], pantry_items: List[str]) -> Dict[str, Any]:
    """Call Gemini with images + pantry list to propose a recipe. Returns dict with title, ingredients, steps."""
    parts: List[Dict[str, Any]] = []
    # Add instruction
    instruction = (
        "Given these pantry images and list of items, extract recognizable ingredients and propose a simple, "
        "cookable recipe (title, ingredients, steps). Respond strictly as JSON with keys: title (string), "
        "ingredients (array of strings), steps (array of strings)."
    )
    parts.append({"text": instruction})
    if pantry_items:
        parts.append({"text": "Pantry items (user provided): " + ", ".join(pantry_items)})
    # Add images as inline_data
    for b64 in images_base64[:6]:
        parts.append({
            "inline_data": {
                "mime_type": "image/jpeg",
                "data": b64,
            }
        })
    payload = {
        "contents": [{"parts": parts}]
    }
    params = {"key": _api_key()}
    with httpx.Client(timeout=60) as client:
        r = client.post(GEMINI_URL, params=params, json=payload)
        r.raise_for_status()
        data = r.json()
    candidates = data.get("candidates", [])
    text_resp = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "{}") if candidates else "{}"
    import json
    try:
        obj = json.loads(text_resp)
        title = str(obj.get("title", "AI Recipe")).strip() or "AI Recipe"
        ings = [str(x).strip() for x in obj.get("ingredients", []) if str(x).strip()]
        steps = [str(x).strip() for x in obj.get("steps", []) if str(x).strip()]
        return {"title": title, "ingredients": ings, "steps": steps}
    except Exception:
        # Fallback into a naive extraction
        return {"title": "AI Recipe", "ingredients": pantry_items or [], "steps": [text_resp]}
