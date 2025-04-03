from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .chatbot_logic import get_chatbot_response  # Import chatbot logic

@csrf_exempt
def chatbot_api(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            user_query = data.get("question", "")
            preferred_language = data.get("language", "en")  # Default to English

            if not user_query:
                return JsonResponse({"error": "No question provided"}, status=400)

            # Get chatbot response
            response_data = get_chatbot_response(user_query, preferred_language)

            return JsonResponse({
                "answer": response_data["answer"],
                "similarity_score": response_data["match_score"]
            })

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format"}, status=400)
    
    return JsonResponse({"error": "Invalid request method"}, status=405)
