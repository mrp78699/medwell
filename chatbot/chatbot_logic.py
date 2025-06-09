from deep_translator import GoogleTranslator
import json
import re
import numpy as np
import os
from pathlib import Path
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Base directory where this file (and manage.py) is located
BASE_DIR = Path(__file__).resolve().parent.parent

# Load dataset
chatbot_data_path = BASE_DIR / "chatbot_data.json"
with open(chatbot_data_path, "r", encoding="utf-8") as file:
    dataset = json.load(file)

# Extract questions and answers
questions = [item["question"] for item in dataset]
answers = {item["question"]: item["answer"] for item in dataset}

# File to store unanswered questions
UNANSWERED_FILE = BASE_DIR / "unanswered_questions.json"

# Text preprocessing function
def preprocess(text):
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    return text

preprocessed_questions = [preprocess(q) for q in questions]

# TF-IDF Vectorization
vectorizer = TfidfVectorizer()
tfidf_matrix = vectorizer.fit_transform(preprocessed_questions)

# Function to detect language
def detect_language(text):
    try:
        translated_text = GoogleTranslator(source='auto', target='en').translate(text)
        return "ml" if text != translated_text else "en"
    except Exception:
        return "en"

# Function to translate text
def translate_text(text, target_language="ml"):
    try:
        return GoogleTranslator(source="auto", target=target_language).translate(text)
    except Exception:
        return text

# Function to log unanswered questions
def log_unanswered_question(question):
    unanswered_data = []

    if UNANSWERED_FILE.exists():
        try:
            with open(UNANSWERED_FILE, "r", encoding="utf-8") as file:
                unanswered_data = json.load(file)
        except json.JSONDecodeError:
            unanswered_data = []

    if question not in unanswered_data:
        unanswered_data.append(question)
        with open(UNANSWERED_FILE, "w", encoding="utf-8") as file:
            json.dump(unanswered_data, file, indent=4)

# Function to get chatbot response
def get_chatbot_response(user_query, preferred_language="en"):
    detected_lang = detect_language(user_query)

    if detected_lang == "ml":
        user_query = translate_text(user_query, "en")

    user_query_processed = preprocess(user_query)
    user_vector = vectorizer.transform([user_query_processed])
    similarities = cosine_similarity(user_vector, tfidf_matrix).flatten()

    greeting_words = ["hi", "hello"]

    if user_query_processed in greeting_words:
        answer_english = "Hello, I am a chronic disease chatbot. How can I help you?"
        answer_malayalam = translate_text(answer_english, "ml")
        return {
            "answer": answer_malayalam if preferred_language == "ml" else answer_english,
            "match_score": 1.0
        }

    best_match_index = np.argmax(similarities)
    best_match_score = similarities[best_match_index]

    if best_match_score > 0.4:
        best_question = questions[best_match_index]
        answer_english = answers[best_question] + " Consult your doctor for more details."
        answer_malayalam = translate_text(answer_english, "ml")
        return {
            "answer": answer_malayalam if preferred_language == "ml" else answer_english,
            "match_score": best_match_score
        }
    else:
        log_unanswered_question(user_query)
        no_answer_english = "No answer available right now."
        no_answer_malayalam = translate_text(no_answer_english, "ml")
        return {
            "answer": no_answer_malayalam if preferred_language == "ml" else no_answer_english,
            "match_score": best_match_score
        }
