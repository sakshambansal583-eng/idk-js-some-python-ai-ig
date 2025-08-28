import streamlit as st
import requests

st.set_page_config(page_title="PyHelper AI", page_icon="🐍", layout="centered")

st.title("🐍 PyHelper AI")
st.write("Your AI assistant for learning Python, debugging, and explaining code.")

provider = st.sidebar.selectbox("Provider", ["ollama", "openai_compatible"])
base_url = st.sidebar.text_input("Base URL", "http://localhost:11434/v1")
model = st.sidebar.text_input("Model", "llama3.1:8b")
api_key = st.sidebar.text_input("API Key (if needed)", type="password")

if "messages" not in st.session_state:
    st.session_state["messages"] = []

for msg in st.session_state.messages:
    st.chat_message(msg["role"]).write(msg["content"])

if prompt := st.chat_input("Ask me about Python..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    st.chat_message("user").write(prompt)

    try:
        headers = {"Authorization": f"Bearer {api_key}"} if api_key else {}
        response = requests.post(
            f"{base_url}/chat/completions",
            headers=headers,
            json={"model": model, "messages": st.session_state.messages, "stream": False},
            timeout=60,
        )
        reply = response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        reply = f"⚠️ Error: {e}"

    st.session_state.messages.append({"role": "assistant", "content": reply})
    st.chat_message("assistant").write(reply)
