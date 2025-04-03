import random
import time

from locust import HttpUser, between, task


class ChatUser(HttpUser):
    wait_time = between(5, 20)

    @task
    def ask_question(self):
        self.client.get(
            "/",
            name="home",
        )
        time.sleep(self.wait_time())
        first_question = random.choice(
            [
                "How is Heineken using AI to optimize global operations and supply chain logistics?",
                "What AI technologies has Heineken adopted for enhancing customer engagement and brand marketing?",
                "How can AI be used to improve the quality and consistency of Heineken’s beer during the brewing process?",
                "How does Heineken leverage AI to forecast retail demand and boost product placement in stores?",
            ]
        )

        response = self.client.post(
            "/chat",
            name="initial chat",
            json={
                "messages": [
                    {
                        "content": first_question,
                        "role": "user",
                    },
                ],
                "context": {
                    "overrides": {
                        "retrieval_mode": "hybrid",
                        "semantic_ranker": True,
                        "semantic_captions": False,
                        "top": 3,
                        "suggest_followup_questions": True,
                    },
                },
            },
        )
        time.sleep(self.wait_time())
        # use one of the follow up questions.
        follow_up_question = random.choice(response.json()["context"]["followup_questions"])
        result_message = response.json()["message"]["content"]

        self.client.post(
            "/chat",
            name="follow up chat",
            json={
                "messages": [
                    {"content": first_question, "role": "user"},
                    {
                        "content": result_message,
                        "role": "assistant",
                    },
                    {"content": follow_up_question, "role": "user"},
                ],
                "context": {
                    "overrides": {
                        "retrieval_mode": "hybrid",
                        "semantic_ranker": True,
                        "semantic_captions": False,
                        "top": 3,
                        "suggest_followup_questions": False,
                    },
                },
            },
        )


class ChatVisionUser(HttpUser):
    wait_time = between(5, 20)

    @task
    def ask_question(self):
        self.client.get("/")
        time.sleep(self.wait_time())
        self.client.post(
            "/chat/stream",
            json={
                "messages": [
                    {
                        "content": "Can you identify any correlation between oil prices and stock market trends?",
                        "role": "user",
                    }
                ],
                "context": {
                    "overrides": {
                        "top": 3,
                        "temperature": 0.3,
                        "minimum_reranker_score": 0,
                        "minimum_search_score": 0,
                        "retrieval_mode": "hybrid",
                        "semantic_ranker": True,
                        "semantic_captions": False,
                        "suggest_followup_questions": False,
                        "use_oid_security_filter": False,
                        "use_groups_security_filter": False,
                        "vector_fields": ["embedding", "imageEmbedding"],
                        "use_gpt4v": True,
                        "gpt4v_input": "textAndImages",
                    }
                },
                "session_state": None,
            },
        )
        time.sleep(self.wait_time())
        self.client.post(
            "/chat/stream",
            json={
                "messages": [
                    {"content": "Compare the impact of interest rates and GDP in financial markets.", "role": "user"}
                ],
                "context": {
                    "overrides": {
                        "top": 3,
                        "temperature": 0.3,
                        "minimum_reranker_score": 0,
                        "minimum_search_score": 0,
                        "retrieval_mode": "hybrid",
                        "semantic_ranker": True,
                        "semantic_captions": False,
                        "suggest_followup_questions": False,
                        "use_oid_security_filter": False,
                        "use_groups_security_filter": False,
                        "vector_fields": ["embedding", "imageEmbedding"],
                        "use_gpt4v": True,
                        "gpt4v_input": "textAndImages",
                    }
                },
                "session_state": None,
            },
        )
