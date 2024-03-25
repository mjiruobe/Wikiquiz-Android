# Wikiquiz

Play quiz with a wikipedia page of any person. This project uses the wikipedia api to fetch articles and search on wikidata for structured information about the person.
This structured information is passed to a LLM (here chatgtp turbo 3.5) to generate a question and fake answers. Questions are stored in a MongoDB to avoid prompting the AI to often.

For now this project only works for the german language. For other languages you need to modify the prompts in the backend.

This Repository only contains the Flutter frontend. For the backend visit https://github.com/mjiruobe/Wikiquiz

https://github.com/mjiruobe/Wikiquiz-Android/assets/68758914/371138ac-e37d-474d-bb1f-6b31ec8b2a48

## Usage

- Run the backend server (see https://github.com/mjiruobe/Wikiquiz)
- copy lib/env.example.dart to lib/env.dart and fill it with your Wikiquiz API Key and the Wikiquiz API Base URL

## Disclamer

This project is not production ready. It is a proof of concept.
I don't recommend to make this project public available outside of your network without any modification e.g. an nginx tranmisson proxy for encrypted traffic to the API.
