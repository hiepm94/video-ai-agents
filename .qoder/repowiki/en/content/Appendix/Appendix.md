# Appendix

<cite>
**Referenced Files in This Document**   
- [models.py](file://vaas-api/src/vaas_api/models.py)
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py)
- [pyproject.toml](file://vaas-api/pyproject.toml)
- [pyproject.toml](file://vaas-mcp/pyproject.toml)
- [package.json](file://vaas-ui/package.json)
- [config.py](file://vaas-api/src/vaas_api/config.py)
- [config.py](file://vaas-mcp/src/vaas_mcp/config.py)
- [prompts.py](file://vaas-mcp/src/vaas_mcp/prompts.py)
- [tools.py](file://vaas-mcp/src/vaas_mcp/tools.py)
- [server.py](file://vaas-mcp/src/vaas_mcp/server.py)
</cite>

## Table of Contents
1. [Data Models](#data-models)
2. [Third-Party Dependencies](#third-party-dependencies)
3. [Glossary of Terms](#glossary-of-terms)
4. [Configuration Options](#configuration-options)
5. [API Status Codes and Error Messages](#api-status-codes-and-error-messages)
6. [External Documentation Links](#external-documentation-links)

## Data Models

This section documents the core data models used across the multimodal agents system, categorized by their purpose and service boundaries.

### API Request/Response Models

The following models define the API contract between the frontend and vaas-api service.

#### UserMessageRequest
Represents a user message with optional multimedia context.

**Fields:**
- `message`: string - The text message from the user
- `video_path`: string | null - Optional path to a video file for context
- `image_base64`: string | null - Optional base64-encoded image for visual context

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L15-L20)

#### AssistantMessageResponse
Represents the assistant's response to a user message.

**Fields:**
- `message`: string - The text response from the assistant
- `clip_path`: string | null - Optional path to a video clip generated as part of the response

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L22-L26)

#### ProcessVideoRequest
Request model for initiating video processing.

**Fields:**
- `video_path`: string - Path to the video file that needs processing

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L5-L8)

#### VideoUploadResponse
Response model for video upload operations.

**Fields:**
- `message`: string - Status message about the upload operation
- `video_path`: string | null - Path to the uploaded video file
- `task_id`: string | null - Identifier for the background processing task

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L28-L33)

### LLM Structured Output Models

These models define the structured output format expected from LLM calls.

#### RoutingResponseModel
Determines whether a user query requires tool usage.

**Fields:**
- `tool_use`: boolean - Indicates if the query requires a tool call

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L36-L40)

#### GeneralResponseModel
Structure for general conversational responses.

**Fields:**
- `message`: string - Response to the user following vaas's personality

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L42-L46)

#### VideoClipResponseModel
Structure for responses that include video clips.

**Fields:**
- `message`: string - Engaging message asking user to watch the clip
- `clip_path`: string - Path to the generated video clip

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L48-L53)

### Video Ingestion System Models

Internal models used in the video processing pipeline.

#### CachedTableMetadata
Metadata structure for cached video tables in PixelTable.

**Fields:**
- `video_name`: string - Name of the video
- `video_cache`: string - Path to the video cache directory
- `video_table`: string - Root video table identifier
- `frames_view`: string - View containing video frames
- `audio_chunks_view`: string - View containing audio chunks with transcripts

**Section sources**
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L10-L24)

#### Base64Image
Model for handling base64-encoded images.

**Fields:**
- `image`: string - Base64 encoded image data

**Methods:**
- `to_pil()`: Converts base64 string to PIL Image object
- `encode_image()`: Class method to encode PIL Image or file path to base64

**Section sources**
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L68-L84)

#### UserContent
Structured content model for user messages with multimodal inputs.

**Fields:**
- `role`: literal "user" - Message role identifier
- `content`: array of TextContent or ImageUrlContent objects

**Methods:**
- `from_pair()`: Class method to create content from image and prompt

**Section sources**
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L101-L118)

## Third-Party Dependencies

This section documents the third-party dependencies used across the different services in the system.

### API Service Dependencies (vaas-api)

Core dependencies for the API service that handles user requests and agent coordination.

**Core Dependencies:**
- fastapi[standard] >= 0.115.13 - Web framework for API endpoints
- fastmcp >= 2.9.0 - MCP (Model Control Protocol) implementation
- groq >= 0.28.0 - LLM API client for Groq models
- instructor >= 1.9.0 - Structured LLM output parsing
- opik >= 1.7.36 - Observability and tracing platform
- pixeltable >= 0.4.1 - Multimodal data indexing and search
- pydantic-settings >= 2.10.0 - Configuration management

**Development Dependencies:**
- ruff >= 0.12.0 - Code formatting and linting
- ipykernel >= 6.29.5 - Jupyter notebook kernel

**Section sources**
- [pyproject.toml](file://vaas-api/pyproject.toml#L5-L18)

### MCP Service Dependencies (vaas-mcp)

Dependencies for the MCP service that handles video processing and search.

**Core Dependencies:**
- fastmcp >= 2.5.2 - MCP server implementation
- pixeltable >= 0.4.1 - Video data indexing and search engine
- anthropic >= 0.55.0 - Alternative LLM provider
- openai >= 1.91.0 - OpenAI API client for embeddings and transcription
- moviepy >= 2.2.1 - Video processing library
- sentence-transformers >= 4.1.0 - Sentence embedding models
- transformers >= 4.52.4 - Hugging Face transformer models

**Development Dependencies:**
- ruff >= 0.12.0 - Code formatting and linting
- ipykernel >= 6.29.5 - Jupyter notebook kernel
- loguru >= 0.7.3 - Logging framework

**Section sources**
- [pyproject.toml](file://vaas-mcp/pyproject.toml#L5-L22)

### UI Service Dependencies (vaas-ui)

Dependencies for the frontend user interface.

**Core Dependencies:**
- react >= 18.3.1 - Frontend framework
- vite >= 5.4.1 - Build tool
- tailwindcss >= 3.4.11 - CSS framework
- @radix-ui/react-* - Accessible UI components
- @tanstack/react-query >= 5.56.2 - Data fetching and state management
- zod >= 3.23.8 - Schema validation
- lucide-react >= 0.462.0 - Icon library
- sonner >= 1.5.0 - Toast notifications

**Development Dependencies:**
- typescript >= 5.5.3 - Type checking
- eslint >= 9.9.0 - Code linting
- postcss >= 8.4.47 - CSS processing
- tailwindcss-animate >= 1.0.7 - Animation utilities

**Section sources**
- [package.json](file://vaas-ui/package.json#L10-L83)

## Glossary of Terms

This section defines key terminology used throughout the multimodal agents system.

### MCP (Model Control Protocol)
A protocol and framework for exposing AI models and tools through standardized interfaces. In this system, the vaas-mcp service implements an MCP server that exposes video processing capabilities as discoverable tools.

**Section sources**
- [server.py](file://vaas-mcp/src/vaas_mcp/server.py#L1-L40)
- [base_agent.py](file://vaas-api/src/vaas_api/agent/base_agent.py#L1-L36)

### Agent
An AI-powered component that processes user requests and coordinates tool usage. The system uses a Groq-based agent that determines whether to use tools or provide direct responses based on user queries.

**Section sources**
- [base_agent.py](file://vaas-api/src/vaas_api/agent/base_agent.py#L1-L36)
- [groq_agent.py](file://vaas-api/src/vaas_api/agent/groq/groq_agent.py)

### Tool
A function exposed through the MCP server that performs specific operations. Tools in this system include video processing functions like `process_video`, `get_video_clip_from_user_query`, and `ask_question_about_video`.

**Section sources**
- [tools.py](file://vaas-mcp/src/vaas_mcp/tools.py#L1-L104)
- [server.py](file://vaas-mcp/src/vaas_mcp/server.py#L1-L40)

### Prompt
A template or function that generates system messages for LLMs. The system uses three main prompt types: routing, tool use, and general conversation prompts, which are managed through the Opik platform.

**Section sources**
- [prompts.py](file://vaas-mcp/src/vaas_mcp/prompts.py#L1-L108)
- [base_agent.py](file://vaas-api/src/vaas_api/agent/base_agent.py#L38-L73)

### Resource
A data endpoint exposed by the MCP server. In this system, resources include data about available video indexes and their metadata.

**Section sources**
- [resources.py](file://vaas-mcp/src/vaas_mcp/resources.py)
- [server.py](file://vaas-mcp/src/vaas_mcp/server.py#L43-L95)

### Multimodal
Refers to the system's ability to process and understand multiple types of data, including text, video, and images. The architecture is designed to handle queries that combine these modalities.

**Section sources**
- [models.py](file://vaas-api/src/vaas_api/models.py#L15-L20)
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L68-L118)

## Configuration Options

This section documents the configurable parameters for the system, organized by service.

### API Service Configuration

Configuration options for the vaas-api service.

**GROQ Configuration:**
- `GROQ_API_KEY`: Authentication key for Groq API
- `GROQ_ROUTING_MODEL`: Model used for routing decisions (default: meta-llama/llama-4-scout-17b-16e-instruct)
- `GROQ_TOOL_USE_MODEL`: Model used for tool usage (default: meta-llama/llama-4-maverick-17b-128e-instruct)
- `GROQ_IMAGE_MODEL`: Model used for image-related tasks (default: meta-llama/llama-4-maverick-17b-128e-instruct)
- `GROQ_GENERAL_MODEL`: Model used for general conversation (default: meta-llama/llama-4-maverick-17b-128e-instruct)

**Memory Configuration:**
- `AGENT_MEMORY_SIZE`: Number of conversation turns to maintain in context (default: 20)

**MCP Configuration:**
- `MCP_SERVER`: URL of the MCP server (default: http://vaas-mcp:9090/mcp)

**Section sources**
- [config.py](file://vaas-api/src/vaas_api/config.py#L1-L42)

### MCP Service Configuration

Configuration options for the vaas-mcp service.

**Video Ingestion Configuration:**
- `SPLIT_FRAMES_COUNT`: Number of frames to extract per second (default: 45)
- `AUDIO_CHUNK_LENGTH`: Duration of audio chunks in seconds (default: 10)
- `AUDIO_OVERLAP_SECONDS`: Overlap between audio chunks (default: 1)
- `AUDIO_MIN_CHUNK_DURATION_SECONDS`: Minimum duration for audio chunks (default: 1)
- `IMAGE_RESIZE_WIDTH`: Width for resized frames (default: 1024)
- `IMAGE_RESIZE_HEIGHT`: Height for resized frames (default: 768)

**Model Configuration:**
- `AUDIO_TRANSCRIPT_MODEL`: Model for audio transcription (default: gpt-4o-mini-transcribe)
- `IMAGE_CAPTION_MODEL`: Model for image captioning (default: gpt-4o-mini)
- `IMAGE_SIMILARITY_EMBD_MODEL`: Model for image similarity search (default: openai/clip-vit-base-patch32)
- `TRANSCRIPT_SIMILARITY_EMBD_MODEL`: Model for transcript similarity search (default: text-embedding-3-small)
- `CAPTION_SIMILARITY_EMBD_MODEL`: Model for caption similarity search (default: text-embedding-3-small)

**Search Configuration:**
- `VIDEO_CLIP_SPEECH_SEARCH_TOP_K`: Number of top speech matches for clip extraction (default: 1)
- `VIDEO_CLIP_CAPTION_SEARCH_TOP_K`: Number of top caption matches for clip extraction (default: 1)
- `VIDEO_CLIP_IMAGE_SEARCH_TOP_K`: Number of top image matches for clip extraction (default: 1)
- `QUESTION_ANSWER_TOP_K`: Number of top captions for question answering (default: 3)

**Section sources**
- [config.py](file://vaas-mcp/src/vaas_mcp/config.py#L1-L55)

## API Status Codes and Error Messages

This section documents the API response status codes and common error messages.

### HTTP Status Codes

| Status Code | Meaning | Usage |
|-----------|-------|------|
| 200 | OK | Successful GET, PUT, PATCH, or DELETE requests |
| 201 | Created | Successful POST requests that create a resource |
| 202 | Accepted | Request accepted for processing, but not completed |
| 400 | Bad Request | Client sent invalid request data |
| 401 | Unauthorized | Authentication required or failed |
| 403 | Forbidden | Client authenticated but lacks required permissions |
| 404 | Not Found | Requested resource does not exist |
| 422 | Unprocessable Entity | Request validation failed |
| 500 | Internal Server Error | Server encountered an unexpected condition |
| 502 | Bad Gateway | Invalid response from upstream server |
| 503 | Service Unavailable | Server temporarily unable to handle request |

**Section sources**
- [api.py](file://vaas-api/src/vaas_api/api.py#L100-L132)

### Common Error Messages

**Video Processing Errors:**
- "Failed to connect to MCP server" - Unable to communicate with the MCP service
- "Error processing video {path}: {error}" - Generic video processing failure
- "Video file not found at {path}" - Specified video file does not exist
- "Failed to extract video clip: {error}" - FFmpeg clip extraction failed

**Authentication Errors:**
- "OPIK_API_KEY not configured" - Missing Opik observability credentials
- "GROQ_API_KEY not configured" - Missing Groq API credentials
- "OPENAI_API_KEY not configured" - Missing OpenAI API credentials

**Validation Errors:**
- "start_time must be less than end_time" - Invalid clip extraction parameters
- "Failed to process image: {error}" - Image encoding/decoding failure
- "Input must be a PIL Image" - Invalid image type provided

**Section sources**
- [api.py](file://vaas-api/src/vaas_api/api.py#L100-L132)
- [tools.py](file://vaas-mcp/src/vaas_mcp/tools.py#L1-L104)
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L1-L204)

## External Documentation Links

This section provides links to external documentation for key dependencies.

### FastMCP
- **Documentation**: [https://github.com/assafelovic/gpt-researcher/tree/master/fastmcp](https://github.com/assafelovic/gpt-researcher/tree/master/fastmcp)
- **Purpose**: Model Control Protocol implementation used for tool and resource exposure
- **Key Features**: Standardized tool discovery, prompt management, resource endpoints

### PixelTable
- **Documentation**: [https://docs.pixeltable.ai/](https://docs.pixeltable.ai/)
- **Purpose**: Multimodal data indexing and search engine for video content
- **Key Features**: Video frame extraction, audio transcription, embedding indexes, similarity search

### Groq API
- **Documentation**: [https://console.groq.com/docs](https://console.groq.com/docs)
- **Purpose**: High-speed LLM inference for agent responses
- **Key Features**: Low-latency model serving, Llama 4 models, structured output support

### Opik
- **Documentation**: [https://docs.comet.ml/opik/](https://docs.comet.ml/opik/)
- **Purpose**: Observability and tracing platform for AI applications
- **Key Features**: Prompt management, experiment tracking, LLM monitoring

**Section sources**
- [pyproject.toml](file://vaas-api/pyproject.toml#L5-L18)
- [pyproject.toml](file://vaas-mcp/pyproject.toml#L5-L22)
- [prompts.py](file://vaas-mcp/src/vaas_mcp/prompts.py#L1-L108)