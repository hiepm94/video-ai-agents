**vaas** is split into three main components:

1. MCP Server — located in the [vaas-mcp](vaas-mcp) directory
2. MCP Agent + Agent API — lives in [vaas-api](vaas-api) directory
3. UI — you’ll find it in [vaas-ui](vaas-ui) directory

Each of these is its own project, and together they make up the full vaas system.

---


# 1. Clone the repository

First thing first, clone the repository.

```
git clone https://github.com/hiepm94/video-ai-agents.git
cd video-ai-agents
```

# 2. Install uv

Instead of `pip` or `poetry`, we are using `uv` as the Python package manager. 

To install uv, simply follow this [instructions](https://docs.astral.sh/uv/getting-started/installation/). 

# 3. Set Up the MCP Server

The MCP Server is where the magic happens. It stores tools, prompts, and everything the Agent needs to work.

To set it up, head to the [vaas-mcp](vaas-mcp) folder and follow the steps in the README.md.

# 4. Set Up the MCP Agent / Agent API

Next, set up the Agent and its API. This is the part that talks to the UI via FastAPI.

Head to the [vaas-api](vaas-api) directory and follow the steps in the README.md.

# 5. Start vaas

Once the MCP Server and Agent API are configured, you’re ready to launch the whole system.

From the root of the repo, just run:

```
make start-vaas
```

This kicks off a Docker Compose application with three services:

1. MCP Server at http://localhost:9090/
2. Agent API at http://localhost:8080/
3. UI at http://localhost:3000/

Open your browser and go to http://localhost:3000/ to start using vaas!

![vaas UI](./static/vaas_landing_chat.png)
