from deep_translator import GoogleTranslator
import json
import re
import numpy as np
from django.conf import settings
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from pathlib import Path

# Load dataset
with open(settings.BASE_DIR / "chatbot_data.json", "r", encoding="utf-8") as file:
    dataset = json.load(file)

# Extract questions and answers
questions = [item["question"] for item in dataset]
answers = {item["question"]: item["answer"] for item in dataset}

# File to store unanswered questions
UNANSWERED_FILE = settings.BASE_DIR / "unanswered_questions.json"

# Text preprocessing function
def preprocess(text):
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)  # Remove punctuation
    return text

preprocessed_questions = [preprocess(q) for q in questions]

# TF-IDF Vectorization
vectorizer = TfidfVectorizer()
tfidf_matrix = vectorizer.fit_transform(preprocessed_questions)

# Function to detect language
def detect_language(text):
    try:
        translated_text = GoogleTranslator(source='auto', target='en').translate(text)
        if text == translated_text:
            return "en"
        else:
            return "ml"
    except Exception:
        return "en"  # Default to English if detection fails

# Function to translate text
def translate_text(text, target_language="ml"):
    try:
        return GoogleTranslator(source="auto", target=target_language).translate(text)
    except Exception:
        return text  # Return original text if translation fails

# Function to log unanswered questions
def log_unanswered_question(question):
    unanswered_data = []
    
    # Check if file exists, load existing data
    if Path(UNANSWERED_FILE).exists():
        with open(UNANSWERED_FILE, "r", encoding="utf-8") as file:
            try:
                unanswered_data = json.load(file)
            except json.JSONDecodeError:
                unanswered_data = []

    # Avoid duplicates
    if question not in unanswered_data:
        unanswered_data.append(question)
        with open(UNANSWERED_FILE, "w", encoding="utf-8") as file:
            json.dump(unanswered_data, file, indent=4)

# Function to get chatbot response
def get_chatbot_response(user_query, preferred_language="en"):
    # Detect language
    detected_lang = detect_language(user_query)
    
    # If question is in Malayalam, translate to English for matching
    if detected_lang == "ml":
        user_query = translate_text(user_query, "en")

    # Preprocess the translated question
    user_query = preprocess(user_query)
    user_vector = vectorizer.transform([user_query])
    similarities = cosine_similarity(user_vector, tfidf_matrix).flatten()

    best_match_index = np.argmax(similarities)
    best_match_score = similarities[best_match_index]

    if best_match_score > 0.6:
        best_question = questions[best_match_index]
        answer_english = answers[best_question]+"Consult your doctor for more details."
        answer_malayalam = translate_text(answer_english, "ml")  # Translate to Malayalam

        # Return the response in the user's preferred language
        return {
            "answer": answer_malayalam if preferred_language == "ml" else answer_english,
            "match_score": best_match_score
        }
    else:
        log_unanswered_question(user_query)  # Log unanswered question
        no_answer_english = "No answer available right now."
        no_answer_malayalam = translate_text(no_answer_english, "ml")

        return {
            "answer": no_answer_malayalam if preferred_language == "ml" else no_answer_english,
            "match_score": best_match_score
        }
