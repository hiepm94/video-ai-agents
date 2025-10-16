# Indexing Strategy

<cite>
**Referenced Files in This Document**
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py)
- [registry.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/registry.py)
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py)
- [functions.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/functions.py)
- [tools.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/tools.py)
- [video_search_engine.py](file://vaas-mcp/src/vaas_mcp/video/video_search_engine.py)
- [config.py](file://vaas-mcp/src/vaas_mcp/config.py)
- [constants.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/constants.py)
- [server.py](file://vaas-mcp/src/vaas_mcp/server.py)
- [tools.py](file://vaas-mcp/src/vaas_mcp/tools.py)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [System Architecture](#system-architecture)
3. [Data Model Schema](#data-model-schema)
4. [Embedding Generation Process](#embedding-generation-process)
5. [Registry Management](#registry-management)
6. [Multimodal Search Capabilities](#multimodal-search-capabilities)
7. [Sample Queries and Usage Examples](#sample-queries-and-usage-examples)
8. [Data Lifecycle Management](#data-lifecycle-management)
9. [Scaling and Optimization](#scaling-and-optimization)
10. [Schema Migrations](#schema-migrations)
11. [Troubleshooting Guide](#troubleshooting-guide)
12. [Conclusion](#conclusion)

## Introduction

The vaas-MCP Indexing Strategy provides a comprehensive framework for structuring and indexing video content using PixelTable, enabling sophisticated multimodal search capabilities across text, audio, and visual modalities. This system transforms raw video content into searchable embeddings, allowing for precise clip retrieval and intelligent content discovery.

The indexing strategy focuses on four primary modalities:
- **Keyframes**: Visual snapshots extracted from video sequences
- **Transcripts**: Audio-to-text conversion of spoken content
- **Audio Embeddings**: Semantic representations of audio content
- **Visual Embeddings**: CLIP-based embeddings of video frames

## System Architecture

The indexing system follows a layered architecture that separates concerns between ingestion, processing, storage, and retrieval:

```mermaid
graph TB
subgraph "Video Input Layer"
VI[Video Files]
VE[Video Encoder]
end
subgraph "Processing Pipeline"
VP[Video Processor]
AI[Audio Iterator]
FI[Frame Iterator]
AE[Audio Extractor]
FE[Frame Extractor]
end
subgraph "Embedding Generation"
TE[Text Embeddings]
CE[Caption Embeddings]
IE[Image Embeddings]
AE2[Audio Embeddings]
end
subgraph "Storage Layer"
PT[PixelTable]
AV[Audio Views]
FV[Frame Views]
EI[Embedding Indices]
end
subgraph "Search Engine"
VSE[Video Search Engine]
MS[Multi-modal Search]
QR[Query Results]
end
VI --> VE
VE --> VP
VP --> AI
VP --> FI
AI --> AE
FI --> FE
AE --> TE
AE --> AE2
FE --> IE
FE --> CE
TE --> PT
CE --> PT
IE --> PT
AE2 --> PT
PT --> AV
PT --> FV
PT --> EI
VSE --> PT
MS --> VSE
QR --> MS
```

**Diagram sources**
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L25-L205)
- [video_search_engine.py](file://vaas-mcp/src/vaas_mcp/video/video_search_engine.py#L12-L168)

## Data Model Schema

The system uses PixelTable as its core data storage mechanism, organizing video content through a hierarchical schema structure:

### Core Table Structure

```mermaid
erDiagram
VIDEO_TABLE {
uuid id PK
video video_file
audio_extract audio_mp3
}
AUDIO_CHUNKS_VIEW {
uuid id PK
audio_chunk audio_segment
transcription json_transcript
chunk_text string_text
start_time_sec float_start_time
end_time_sec float_end_time
pos integer_position
}
FRAMES_VIEW {
uuid id PK
frame image_frame
resized_frame image_resized
im_caption string_caption
pos_msec integer_timestamp
}
VIDEO_TABLE ||--o{ AUDIO_CHUNKS_VIEW : contains
VIDEO_TABLE ||--o{ FRAMES_VIEW : extracts
```

**Diagram sources**
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L15-L31)
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L85-L107)

### Cached Table Metadata

The system maintains registry metadata for efficient table management:

```python
class CachedTableMetadata(BaseModel):
    video_name: str = Field(..., description="Name of the video")
    video_cache: str = Field(..., description="Path to the video cache")
    video_table: str = Field(..., description="Root video table")
    frames_view: str = Field(..., description="Video frames view")
    audio_chunks_view: str = Field(..., description="Audio chunks view")
```

**Section sources**
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L15-L31)
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L33-L72)

## Embedding Generation Process

The embedding generation process creates semantic representations across multiple modalities, enabling cross-modal similarity search:

### Audio Processing Pipeline

```mermaid
sequenceDiagram
participant V as Video
participant AE as Audio Extractor
participant AS as Audio Splitter
participant TR as Transcriber
participant TE as Text Embedder
participant EI as Embedding Index
V->>AE : Extract audio stream
AE->>AS : Split into chunks
AS->>TR : Transcribe each chunk
TR->>TE : Generate text embeddings
TE->>EI : Store embeddings with metadata
Note over V,EI : Audio chunk processing<br/>10-second chunks with 1-second overlap
```

**Diagram sources**
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L109-L143)

### Visual Processing Pipeline

```mermaid
sequenceDiagram
participant V as Video
participant FI as Frame Iterator
participant RI as Resizer
participant CL as CLIP Embedder
participant VC as Vision Captioner
participant CE as Caption Embedder
participant EI as Embedding Index
V->>FI : Extract frames
FI->>RI : Resize to 1024x768
RI->>CL : Generate image embeddings
RI->>VC : Generate captions
VC->>CE : Generate caption embeddings
CL->>EI : Store image embeddings
CE->>EI : Store caption embeddings
Note over V,EI : Frame sampling<br/>45 frames per video
```

**Diagram sources**
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L145-L180)

### Model Specifications

The system employs specific models for each modality:

| Modality | Model | Dimensionality | Purpose |
|----------|-------|----------------|---------|
| Audio Transcription | OpenAI GPT-4o-mini | Whisper tiny | Speech-to-text conversion |
| Audio Embeddings | OpenAI text-embedding-3-small | 1536 | Semantic similarity |
| Image Embeddings | OpenAI CLIP-ViT-B/32 | 512 | Visual similarity |
| Caption Embeddings | OpenAI text-embedding-3-small | 1536 | Caption similarity |

**Section sources**
- [config.py](file://vaas-mcp/src/vaas_mcp/config.py#L15-L35)
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L124-L185)

## Registry Management

The registry system manages indexed tables and versioning through a sophisticated caching mechanism:

### Registry Architecture

```mermaid
classDiagram
class CachedTableMetadata {
+string video_name
+string video_cache
+string video_table
+string frames_view
+string audio_chunks_view
+model_dump_json() string
}
class CachedTable {
+string video_name
+string video_cache
+Table video_table
+Table frames_view
+Table audio_chunks_view
+from_metadata(metadata) CachedTable
+describe() string
}
class TableRegistry {
+Dict~string,CachedTableMetadata~ registry
+get_registry() Dict
+add_index_to_registry() void
+get_table(video_name) CachedTable
}
CachedTableMetadata --> CachedTable : "creates"
TableRegistry --> CachedTableMetadata : "manages"
TableRegistry --> CachedTable : "provides"
```

**Diagram sources**
- [models.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/models.py#L15-L72)
- [registry.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/registry.py#L15-L110)

### Versioning and Caching

The registry implements automatic versioning with timestamp-based file naming:

```python
def add_index_to_registry(
    video_name: str,
    video_cache: str,
    frames_view_name: str,
    audio_view_name: str,
):
    # Creates timestamped registry files
    dt = datetime.now()
    dtstr = dt.strftime("%Y-%m-%d%H:%M:%S")
    records_dir = Path(cc.DEFAULT_CACHED_TABLES_REGISTRY_DIR)
    records_dir.mkdir(parents=True, exist_ok=True)
    with open(records_dir / f"registry_{dtstr}.json", "w") as f:
        json.dump(VIDEO_INDEXES_REGISTRY, f, indent=4)
```

**Section sources**
- [registry.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/registry.py#L61-L97)

## Multimodal Search Capabilities

The VideoSearchEngine provides comprehensive search capabilities across all indexed modalities:

### Search Methods

```mermaid
flowchart TD
Q[User Query] --> SM{Search Mode}
SM --> |Speech| SS[Search by Speech]
SM --> |Image| SI[Search by Image]
SM --> |Caption| SC[Search by Caption]
SS --> AST[Audio Similarity Test]
SI --> IST[Image Similarity Test]
SC --> CST[Caption Similarity Test]
AST --> AR[Audio Results]
IST --> IR[Image Results]
CST --> CR[Caption Results]
AR --> PR[Post-process Results]
IR --> PR
CR --> PR
PR --> VR[Video Clips]
```

**Diagram sources**
- [video_search_engine.py](file://vaas-mcp/src/vaas_mcp/video/video_search_engine.py#L25-L168)

### Timestamp Synchronization

The system maintains precise temporal alignment across modalities:

```python
# Frame timestamp calculation
"start_time": entry["pos_msec"] / 1000.0 - settings.DELTA_SECONDS_FRAME_INTERVAL,
"end_time": entry["pos_msec"] / 1000.0 + settings.DELTA_SECONDS_FRAME_INTERVAL,

# Audio chunk timestamp extraction
"start_time": float(entry["start_time_sec"]),
"end_time": float(entry["end_time_sec"]),
```

**Section sources**
- [video_search_engine.py](file://vaas-mcp/src/vaas_mcp/video/video_search_engine.py#L44-L92)
- [video_search_engine.py](file://vaas-mcp/src/vaas_mcp/video/video_search_engine.py#L94-L121)

## Sample Queries and Usage Examples

### Basic Video Processing

```python
from vaas_mcp.video.ingestion.video_processor import VideoProcessor

# Initialize processor
processor = VideoProcessor()
processor.setup_table("my_video.mp4")

# Add video to index
processor.add_video("path/to/video.mp4")
```

### Multimodal Search Examples

```python
from vaas_mcp.video.video_search_engine import VideoSearchEngine

# Initialize search engine
search_engine = VideoSearchEngine("my_video.mp4")

# Search by speech
speech_results = search_engine.search_by_speech(
    "What is the main topic?", 
    top_k=5
)

# Search by image
image_results = search_engine.search_by_image(
    base64_image_data, 
    top_k=5
)

# Search by caption
caption_results = search_engine.search_by_caption(
    "a person speaking", 
    top_k=5
)
```

### Tool Integration Examples

```python
# Extract video clip based on query
from vaas_mcp.tools import get_video_clip_from_user_query

clip_path = get_video_clip_from_user_query(
    video_path="path/to/video.mp4",
    user_query="find the scene with birds"
)

# Ask questions about video content
from vaas_mcp.tools import ask_question_about_video

answer = ask_question_about_video(
    video_path="path/to/video.mp4",
    user_query="what did the character say?"
)
```

**Section sources**
- [tools.py](file://vaas-mcp/src/vaas_mcp/tools.py#L39-L103)
- [server.py](file://vaas-mcp/src/vaas_mcp/server.py#L10-L40)

## Data Lifecycle Management

### Video Processing Workflow

```mermaid
stateDiagram-v2
[*] --> VideoInput
VideoInput --> VideoValidation : Check format
VideoValidation --> VideoReencoding : Incompatible format
VideoValidation --> FrameExtraction : Compatible format
VideoReencoding --> FrameExtraction
FrameExtraction --> AudioExtraction
AudioExtraction --> Transcription
Transcription --> CaptionGeneration
CaptionGeneration --> EmbeddingGeneration
EmbeddingGeneration --> IndexCreation
IndexCreation --> RegistryUpdate
RegistryUpdate --> [*]
VideoValidation --> [*] : Invalid format
FrameExtraction --> [*] : Extraction failed
AudioExtraction --> [*] : Audio missing
```

### Retention Policies

The system implements configurable retention policies through:

- **Audio Chunk Duration**: 10 seconds per chunk with 1-second overlap
- **Frame Sampling Rate**: 45 frames per video
- **Cache Management**: Automatic cleanup of temporary processing files
- **Registry Versioning**: Historical registry snapshots for rollback capability

**Section sources**
- [config.py](file://vaas-mcp/src/vaas_mcp/config.py#L20-L25)
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L109-L143)

## Scaling and Optimization

### Approximate Nearest Neighbor Indexing

The system leverages PixelTable's built-in ANN capabilities for efficient similarity search:

```python
# Audio chunk similarity search
sims = self.video_index.audio_chunks_view.chunk_text.similarity(query)
results = self.video_index.audio_chunks_view.select(
    self.video_index.audio_chunks_view.start_time_sec,
    self.video_index.audio_chunks_view.end_time_sec,
    similarity=sims,
).order_by(sims, asc=False)
```

### Performance Optimizations

1. **Parallel Processing**: Audio and visual processing occur concurrently
2. **Batch Operations**: Multiple embeddings generated in single operations
3. **Caching Strategy**: LRU cache for registry lookups
4. **Memory Management**: Efficient image resizing and processing

### Large Collection Scaling

For large video collections, consider:

- **Distributed Processing**: Parallel video processing across multiple workers
- **Incremental Indexing**: Add new videos without reprocessing existing content
- **Resource Pooling**: Shared embedding model instances
- **Storage Optimization**: Compressed storage formats for embeddings

**Section sources**
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L145-L185)
- [video_search_engine.py](file://vaas-mcp/src/vaas_mcp/video/video_search_engine.py#L34-L62)

## Schema Migrations

### Version Control Strategy

The registry system provides version control through timestamped snapshots:

```python
# Registry files are named with timestamps
registry_2024-01-1510:30:45.json
registry_2024-01-1511:15:23.json
registry_2024-01-1512:45:10.json
```

### Migration Procedures

1. **Backup Current State**: Snapshot registry before migration
2. **Schema Validation**: Verify compatibility with new schema
3. **Incremental Updates**: Apply changes incrementally to avoid downtime
4. **Rollback Capability**: Restore from previous registry snapshot if needed

### Compatibility Guidelines

- **Backward Compatibility**: New versions support older registry formats
- **Forward Compatibility**: Registry updates require system upgrades
- **Schema Evolution**: Add new computed columns without breaking existing indices

**Section sources**
- [registry.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/registry.py#L25-L60)

## Troubleshooting Guide

### Common Issues and Solutions

#### Video Format Compatibility
**Problem**: Videos fail to process due to unsupported formats
**Solution**: The system automatically re-encodes videos using FFmpeg
```python
# Automatic re-encoding handled by tools.py
re_encoded_path = re_encode_video(original_video_path)
```

#### Memory Issues During Processing
**Problem**: Out of memory errors during frame processing
**Solution**: Adjust frame sampling rate and image dimensions
```python
# Configurable parameters in config.py
IMAGE_RESIZE_WIDTH: int = 1024
IMAGE_RESIZE_HEIGHT: int = 768
SPLIT_FRAMES_COUNT: int = 45
```

#### Embedding Index Corruption
**Problem**: Embedding indices become corrupted or outdated
**Solution**: Rebuild indices using the replace_force option
```python
# Force rebuild of embedding indices
self.frames_view.add_embedding_index(
    column=self.frames_view.resized_frame,
    image_embed=clip.using(model_id=settings.IMAGE_SIMILARITY_EMBD_MODEL),
    if_exists="replace_force",
)
```

#### Registry Access Failures
**Problem**: Cannot access video indices from registry
**Solution**: Verify registry file permissions and existence
```python
# Registry validation
registry_files = [
    f for f in os.listdir(cc.DEFAULT_CACHED_TABLES_REGISTRY_DIR)
    if f.startswith("registry_") and f.endswith(".json")
]
```

**Section sources**
- [tools.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/tools.py#L100-L155)
- [video_processor.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/video_processor.py#L169-L185)
- [registry.py](file://vaas-mcp/src/vaas_mcp/video/ingestion/registry.py#L25-L60)

## Conclusion

The vaas-MCP Indexing Strategy provides a robust foundation for multimodal video search through PixelTable. By systematically extracting and indexing audio, visual, and textual content, the system enables sophisticated search capabilities across multiple modalities.

Key strengths of the system include:

- **Comprehensive Coverage**: Multi-modal indexing ensures broad content accessibility
- **Scalable Architecture**: Designed for processing large video collections efficiently
- **Flexible Search**: Support for various query types and modalities
- **Robust Management**: Comprehensive registry and versioning system
- **Performance Optimization**: Built-in ANN indexing and caching mechanisms

The system's modular design allows for easy extension and customization, making it suitable for a wide range of video processing and search applications. Future enhancements could include support for additional modalities, distributed processing capabilities, and advanced analytics features.