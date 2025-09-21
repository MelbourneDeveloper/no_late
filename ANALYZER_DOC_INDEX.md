# Analyzer Plugin Documentation Index

## File Breakdown:

### analyzerdoc_part_aa
- **Overview section**
- **plugin domain** - Plugin lifecycle, version check, details, shutdown
- **analysis domain** - Start of analysis requests

### analyzerdoc_part_ab
- **🔥 CRITICAL: analysis.errors notification** - How plugins send errors to IDEs
- **AnalysisError type definition** - Structure of error objects
- **completion domain** - Code completion APIs
- **edit domain** - Code edit APIs

### analyzerdoc_part_ac
- **AnalysisService enumeration** - Types of services plugins can provide

### analyzerdoc_part_ad
- **Type definitions continued**

### analyzerdoc_part_ae
- **Refactorings section**

### analyzerdoc_part_af
- **Index section** - Complete API reference index

## Key Sections for Plugin Implementation:

1. **analysis.errors notification** (analyzerdoc_part_ab lines 10-32)
   - Format: `{"event": "analysis.errors", "params": {"file": FilePath, "errors": List<AnalysisError>}}`
   - Used to send errors to IDEs for display

2. **AnalysisError type** (analyzerdoc_part_ab lines 412-476)
   - Required fields: severity, type, location, message, code
   - Optional: correction, url, contextMessages, hasFix

3. **plugin domain** (analyzerdoc_part_aa lines 126+)
   - versionCheck, details, shutdown requests
   - Plugin lifecycle management