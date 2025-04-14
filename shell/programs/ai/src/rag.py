import os
from llama_index.core.ingestion import IngestionPipeline, IngestionCache
from llama_index.core.query_pipeline import QueryPipeline
from llama_index.core.storage.docstore import SimpleDocumentStore
from llama_index.cli.rag import RagCLI


# optional, set any API keys your script may need (perhaps using python-dotenv library instead)
os.environ["OPENAI_API_KEY"] = "sk-xxx"

docstore = SimpleDocumentStore()

vec_store = ...  # your vector store instance
llm = ...  # your LLM instance - optional, will default to OpenAI gpt-3.5-turbo

custom_ingestion_pipeline = IngestionPipeline(
    transformations=[...],
    vector_store=vec_store,
    docstore=docstore,
    cache=IngestionCache(),
)

# Setting up the custom QueryPipeline is optional!
# You can still customize the vector store, LLM, and ingestion transformations without
# having to customize the QueryPipeline
custom_query_pipeline = QueryPipeline()
custom_query_pipeline.add_modules(...)
custom_query_pipeline.add_link(...)

# you can optionally specify your own custom readers to support additional file types.
file_extractor = {".html": ...}

rag_cli_instance = RagCLI(
    ingestion_pipeline=custom_ingestion_pipeline,
    llm=llm,  # optional
    query_pipeline=custom_query_pipeline,  # optional
    file_extractor=file_extractor,  # optional
)

if __name__ == "__main__":
    rag_cli_instance.cli()
