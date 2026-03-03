
# Product Requirements Document (PRD) v2.0
## Underwater - Offline AI Coding Companion for macOS

## 1. Product Overview

**Product Name:** Underwater

**Product Type:** Native macOS Application (Fully Offline AI Coding Assistant)

**Tagline:** "Your intelligent coding companion that works completely offline"

**Platform:** macOS (Apple Silicon M1/M2/M3/m4/m5 required)

**Development Tools:** 
- Anti-Gravity (AI coding assistant for building the app)
- Xcode 15+
- Swift 5.9+
- SwiftUI

**Target Users:** 
- Professional developers needing offline AI
- Privacy-conscious developers
- Developers in secure/offline environments
- Students learning to code
- Indie developers

**Core Differentiator:** ONLY truly offline AI coding assistant with bundled model

---

## 2. Problem Statement

### Current Pain Points:
1. **Internet Dependency:** Cursor, GitHub Copilot, Claude require constant connectivity
2. **Privacy Concerns:** Code sent to cloud servers
3. **API Costs:** $10-20/month subscriptions
4. **Latency:** Slow with poor internet
5. **Access Restrictions:** Can't work on flights, secure networks, remote locations

### Solution:
Underwater = **Zero internet requirement. Ever.**

---

## 3. Core Value Proposition

**"Install once, code intelligently forever—no internet, no subscriptions, no compromises."**

### What Makes Underwater Unique:
✅ 100% offline (no API keys, no internet checks)
✅ AI model bundled inside app (~8-10GB)
✅ Native macOS performance
✅ Complete privacy (code never leaves your Mac)
✅ One-time purchase (no subscriptions)

---

## 4. Technical Architecture - CORRECTED

### 4.1 Technology Stack (FIXED)

**UI Layer:**
- Swift 5.9+
- SwiftUI (native macOS)
- AppKit (for advanced features)

**AI/ML Layer:** 
- **MLX Framework** (Apple's ML framework - PRIMARY CHOICE)
- **NOT llama.cpp** (too complex for v1.0)
- Swift-native MLX bindings

**Model:**
- **DeepSeek-Coder-V2-Lite** (coding-specialized)
- Format: **MLX-compatible format** (NOT GGUF)
- Size: 8-10GB (quantized for Apple Silicon)
- Location: Bundled in `.app/Contents/Resources/`

**Why MLX (Not llama.cpp):**
✅ Native Apple framework
✅ Optimized for Apple Silicon
✅ Swift-friendly APIs
✅ Better performance on M-series chips
✅ Simpler integration
✅ Official Apple support

---

### 4.2 Four-Layer Architecture (CLARIFIED)

```
┌─────────────────────────────────────────┐
│   Layer 1: macOS Native UI (SwiftUI)   │
│   - Code editor                          │
│   - File browser                         │
│   - AI chat panel                        │
│   - Syntax highlighting                  │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   Layer 2: Code Intelligence Engine     │
│   - Language detection                   │
│   - Context extraction                   │
│   - Error parsing                        │
│   - Prompt engineering                   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   Layer 3: MLX Inference Engine         │
│   - Model loading (MLX)                 │
│   - Token generation                     │
│   - Response streaming                   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   Layer 4: Bundled AI Model             │
│   - DeepSeek-Coder-V2-Lite              │
│   - 8-10GB (MLX format)                 │
│   - Embedded in app bundle              │
└─────────────────────────────────────────┘
```

---

## 5. Feature Scope - REALISTIC

### 5.1 MVP (Version 1.0) - REVISED

**Timeline:** 2-3 months (with Anti-Gravity)

**Core Features:**
1. ✅ **File Browser**
   - Navigate local project folders
   - Support 10+ file types (Swift, Kotlin, JS, Python, etc.)
   - File tree view

2. ✅ **Code Editor**
   - Syntax highlighting (15+ languages)
   - Line numbers
   - Basic editing (copy/paste/find)

3. ✅ **AI Chat Panel**
   - "Ask Underwater" interface
   - Code analysis
   - Error explanations
   - Improvement suggestions

4. ✅ **Offline AI Model**
   - DeepSeek-Coder-V2-Lite bundled
   - MLX inference
   - Response time: 2-5 seconds
   - Context window: 4K tokens

5. ✅ **Context Awareness**
   - Single file context
   - Selected code context
   - Language detection

**What's NOT in v1.0:**
❌ Multi-file context
❌ Auto-completion (inline suggestions)
❌ IDE integration
❌ Git integration
❌ Debugging tools

---

### 5.2 Version 2.0 (Future) - 6 months later

**Enhanced Features:**
- Multi-file context understanding
- Inline code suggestions
- Error auto-detection
- Code refactoring
- Project-wide analysis

---

## 6. Implementation Plan - DETAILED

### Phase A: Foundation (Week 1-2)
**Goal:** Basic app structure

**Tasks:**
1. Create Xcode project (macOS app)
2. Set up SwiftUI views:
   - Main window
   - File browser panel
   - Code editor panel
   - AI chat panel
3. Implement file system access
4. Add syntax highlighting library

**Deliverable:** App opens, can browse files, displays code

---

### Phase B: UI & File Handling (Week 3-4)
**Goal:** Working file browser + editor

**Tasks:**
1. File tree navigation
2. File type detection
3. Syntax highlighting for:
   - Swift, Kotlin, Java
   - JavaScript, TypeScript
   - Python, HTML, CSS
4. Line numbers
5. Basic text editing

**Deliverable:** Can open and edit code files

---

### Phase C: AI Chat Interface (Week 5-6)
**Goal:** Chat UI ready (without real AI yet)

**Tasks:**
1. Chat panel UI
2. Message bubbles
3. Input field
4. Mock AI responses (placeholder)
5. Context extraction:
   - Get current file content
   - Get selected code
   - Detect language

**Deliverable:** Can "chat" with mock AI

---

### Phase D: MLX Integration (Week 7-10) - CRITICAL
**Goal:** REAL AI responses

**Tasks:**

**D.1 Model Preparation:**
1. Download DeepSeek-Coder-V2-Lite
2. Convert to MLX format (using MLX conversion tools)
3. Test model locally in Python/MLX
4. Quantize for size (aim for 8-10GB)

**D.2 MLX Swift Integration:**
1. Add MLX Swift package to Xcode
2. Create `MLXInferenceService.swift`:
   - Load model from app bundle
   - Initialize MLX context
   - Handle tokenization
   - Generate responses
3. Handle model loading (show progress)
4. Implement streaming responses

**D.3 Prompt Engineering:**
1. Create system prompts for:
   - Code explanation
   - Error fixing
   - Improvement suggestions
2. Format user queries properly
3. Handle context injection

**Deliverable:** Real AI responses working offline!

---

### Phase E: Polish & Testing (Week 11-12)
**Goal:** Production-ready app

**Tasks:**
1. Performance optimization
2. Memory management
3. Error handling
4. UI/UX refinement
5. Beta testing (10-20 users)
6. Bug fixes

**Deliverable:** v1.0 ready for release

---

## 7. Critical Success Factors - UPDATED

### 7.1 Technical Requirements

**MUST HAVE:**
- ✅ Apple Silicon Mac (M1/M2/M3)
- ✅ macOS 14.0+ (for latest MLX)
- ✅ 16GB RAM minimum (for model)
- ✅ 20GB free disk space (app + model)

**Model Performance Targets:**
- First response: 5-10 seconds (model loading)
- Subsequent responses: 2-5 seconds
- Memory usage: 8-12GB (with model loaded)
- Token generation: 10-30 tokens/second

---

### 7.2 Development Requirements

**Tools Needed:**
1. Mac with Apple Silicon
2. Xcode 15+
3. Anti-Gravity (for code generation)
4. MLX Python tools (for model conversion)
5. 50GB free space (for model conversion)

**Skills Needed:**
- Swift/SwiftUI (Anti-Gravity helps!)
- Basic understanding of LLMs
- macOS app development
- File system APIs

---

## 8. Model Integration - DETAILED GUIDE

### 8.1 Model Selection: DeepSeek-Coder-V2-Lite

**Why This Model:**
✅ Coding-specialized (not general chat)
✅ Multi-language support (15+ languages)
✅ Good reasoning (Cursor-like quality)
✅ Lite version (runs on consumer hardware)
✅ Open source (Apache 2.0)
✅ Active development

**Model Specs:**
- Base: 16B parameters
- Quantized: ~8-10GB
- Context: 4K tokens
- Languages: Swift, Kotlin, Java, JS, Python, etc.

---

### 8.2 MLX Integration Steps

**Step 1: Model Conversion**
```bash
# Install MLX
pip install mlx mlx-lm

# Convert DeepSeek to MLX format
python -m mlx_lm.convert \
  --hf-path deepseek-ai/deepseek-coder-v2-lite \
  --mlx-path ./deepseek-mlx \
  --quantize
```

**Step 2: Test Locally**
```python
from mlx_lm import load, generate

model, tokenizer = load("./deepseek-mlx")
response = generate(model, tokenizer, 
                   prompt="Explain this Swift code",
                   max_tokens=512)
print(response)
```

**Step 3: Bundle in App**
- Copy `deepseek-mlx/` to Xcode project
- Add to app bundle: `Resources/Model/`
- Total size: ~10GB

**Step 4: Swift Integration**
```swift
import MLX

class MLXInferenceService {
    private var model: LLMModel?
    
    func loadModel() async {
        let modelPath = Bundle.main.resourceURL!
            .appendingPathComponent("Model")
        
        model = try await LLMModel.load(from: modelPath)
    }
    
    func generate(prompt: String) async -> String {
        return try await model?.generate(
            prompt: prompt,
            maxTokens: 512
        ) ?? "Error"
    }
}
```

---

## 9. UI/UX Design - SIMPLIFIED

### 9.1 Main Window Layout

```
┌────────────────────────────────────────────────┐
│  Underwater          [File] [Edit] [View] [AI] │
├──────────┬─────────────────────────┬────────────┤
│          │                         │            │
│  FILES   │    CODE EDITOR          │  AI CHAT   │
│          │                         │            │
│ 📁 proj/ │  1  import Foundation   │ 💬 Ask     │
│  📄 main │  2                      │ Underwater │
│  📄 util │  3  func hello() {      │            │
│  📁 test │  4    print("Hi")       │ User: Why  │
│          │  5  }                   │ error?     │
│          │                         │            │
│          │                         │ AI: The    │
│          │                         │ error...   │
│          │                         │            │
└──────────┴─────────────────────────┴────────────┘
```

**Panel Sizes:**
- Files: 20% width
- Editor: 50% width
- AI Chat: 30% width

---

## 10. Monetization - UPDATED

### 10.1 Pricing Strategy

**One-Time Purchase:**
- Price: $49 USD
- No subscriptions
- Lifetime access
- Free updates for 1 year

**Why $49:**
- Cursor: $20/month = $240/year
- Copilot: $10/month = $120/year
- Underwater: $49 one-time = ROI in 2-3 months

**Launch Pricing:**
- Early adopters: $29 (limited time)
- Regular price: $49
- Enterprise: Contact sales

---

## 11. Success Metrics - REALISTIC

### 11.1 Launch Targets (First 3 Months)

- Downloads: 500-1,000
- Active users: 300-500
- Revenue: $15,000-$25,000
- Rating: 4.0+ stars

### 11.2 Year 1 Targets

- Total users: 5,000-10,000
- Active monthly: 2,000-4,000
- Revenue: $150,000-$300,000
- Market position: #1 offline AI coding tool

---

## 12. Risks & Mitigation - UPDATED

### 12.1 Technical Risks

**Risk 1:** MLX integration too complex
- **Mitigation:** Start with mock AI, add real AI in phases
- **Backup:** Use pre-built MLX examples as reference

**Risk 2:** Model too large/slow
- **Mitigation:** Aggressive quantization (4-bit)
- **Backup:** Offer "Lite" version with smaller model

**Risk 3:** Memory issues on 8GB Macs
- **Mitigation:** Require 16GB minimum
- **Backup:** Implement model offloading/streaming

### 12.2 Market Risks

**Risk 1:** Users don't trust offline AI quality
- **Mitigation:** Free trial, demo videos
- **Backup:** Transparent benchmarks vs Cursor

**Risk 2:** Apple Silicon requirement limits market
- **Mitigation:** Intel support in v2.0 (with performance caveat)

---

## 13. Development Timeline - REALISTIC

### Total: 12 Weeks (3 Months)

**Weeks 1-2:** Foundation (app structure, UI scaffold)
**Weeks 3-4:** File browser + editor + syntax highlighting  
**Weeks 5-6:** AI chat UI + context extraction  
**Weeks 7-10:** MLX integration + real AI (CRITICAL)  
**Weeks 11-12:** Polish + testing  

**Post-Launch:** Bug fixes, v1.1 improvements

---

## 14. Anti-Gravity Implementation Strategy

### 14.1 How to Use Anti-Gravity

**Phase A-C (Weeks 1-6):**
Prompt: "Build macOS SwiftUI app with file browser, code editor, and chat panel"
- Let Anti-Gravity scaffold the UI
- Iterate on design
- Add syntax highlighting

**Phase D (Weeks 7-10) - CAREFUL:**
**DO NOT** ask Anti-Gravity for full MLX integration upfront!

**Instead, break into steps:**
1. "Add MLX Swift package to Xcode project"
2. "Create MLXInferenceService class that loads model"
3. "Implement token generation with MLX"
4. "Add prompt engineering for code questions"

**Work incrementally!**

---

## 15. Post-MVP Features (v2.0+)

### Future Enhancements (6-12 months)
- Multi-file context
- Inline code completion
- Git integration
- Custom model support
- Team licenses
- VS Code extension

---

## 16. Conclusion - UPDATED

Underwater is **achievable in 3 months** with:
✅ Anti-Gravity for rapid development
✅ MLX for Apple Silicon optimization
✅ Realistic scope (MVP first)
✅ Clear step-by-step plan

**Key Success Factors:**
1. Start simple (file browser + chat)
2. Add real AI incrementally
3. Test early and often
4. Ship v1.0, improve in v2.0

**Next Steps:**
1. ✅ Validate this PRD
2. ✅ Set up Xcode project
3. ✅ Start Phase A (Foundation)
4. ✅ Use Anti-Gravity for code generation
5. ✅ Ship in 3 months! 🚀

---

**PRD Version:** 2.0 (CORRECTED)  
**Last Updated:** February 15, 2026  
**Status:** ✅ Ready for Anti-Gravity Implementation  
**Changes from v1.0:**
- ✅ Fixed MLX vs llama.cpp confusion
- ✅ Realistic timeline (12 weeks)
- ✅ Clear phase-by-phase breakdown
- ✅ Detailed MLX integration guide
- ✅ Removed over-ambitious features
- ✅ Added Anti-Gravity usage strategy

