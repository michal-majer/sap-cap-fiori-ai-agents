# SAP Agents

AI agents for building enterprise SAP CAP and Fiori applications. Work with individual agents for specific tasks, or use the orchestrator for guided end-to-end development.

## Two Ways to Work

### **À La Carte (Individual Agents)**
Use specific agents when you know exactly what you need. Jump directly to backend development, UI design, or annotation work.

**Best for:**
- Adding features to existing projects
- Solving specific problems (e.g., "add value help to this field")
- Experienced developers who know the workflow
- Quick iterations on specific layers

### **Guided Workflow (Orchestrator)**
Let the orchestrator walk you through complete application development with a structured, phase-by-phase approach.

**Best for:**
- Building new applications from scratch
- Learning SAP CAP + Fiori development
- Ensuring nothing is missed
- Teams wanting consistent patterns

---

## Agents

### **sap-cap-developer**
Build SAP Cloud Application Programming (CAP) backends with proper domain modeling, service layers, and authorization.

**Use for:** Data models, OData services, custom handlers, multi-tenancy, authorization

### **sap-fiori-designer**
Choose the optimal Fiori floorplan for your use case with decision matrices and architectural guidance.

**Use for:** List Report vs Object Page, Analytical List Page, Flexible Column Layout, navigation patterns

### **sap-fiori-elements-developer**
Implement Fiori Elements applications using CDS annotations for rich, metadata-driven UIs.

**Use for:** @UI annotations, value helps, field control, actions, charts, contact cards, criticality

### **sap-fiori-scaffolder**
Generate Fiori Elements apps programmatically using `@sap-ux/fiori-elements-writer`.

**Use for:** Automated app generation, scaffolding multiple apps, CI/CD integration

### **sap-full-stack-orchestrator**
Master orchestrator that guides you through complete SAP CAP + Fiori development from requirements to deployment.

**Use for:** End-to-end projects, learning the full workflow, structured development phases

## Quick Start

### Using Individual Agents

**Backend Development:**
```
"I need help building a CAP service for inventory management"
"Add authorization to my Travel service"
"Create a custom handler for order validation"
```

**UI Design:**
```
"Help me choose the right floorplan for a task approval app"
"Should I use List Report or Worklist for this use case?"
```

**Annotations:**
```
"Add value helps to all foreign key fields"
"Create a professional contact card for the Customer entity"
"Add criticality colors to the status field"
```

**App Generation:**
```
"Generate a List Report app for my Products entity"
"Scaffold three Fiori apps using fiori-elements-writer"
```

### Using the Orchestrator

**Complete Guided Development:**
```
"Build a complete time tracking application with CAP + Fiori"
"Walk me through creating an RMA system from scratch"
"I want to build a project management app - guide me step by step"
```

The orchestrator will:
1. Gather requirements through questions
2. Create the CAP backend (domain model, services, authorization)
3. Design the optimal Fiori app architecture
4. Generate Fiori apps
5. Add rich UI annotations
6. Set up testing and documentation

All while explaining each phase and waiting for your approval before proceeding.

---

## When to Use What

| Scenario | Use This | Example Prompt |
|----------|----------|----------------|
| New full-stack app from scratch | **Orchestrator** | "Build a complete inventory management system" |
| Adding a new entity to existing CAP project | **sap-cap-developer** | "Add a Supplier entity with associations to Products" |
| Deciding on Fiori app layout | **sap-fiori-designer** | "Should I use List Report or Analytical List Page?" |
| Enhancing existing Fiori UI | **sap-fiori-elements-developer** | "Add value helps and criticality to my app" |
| Generating multiple apps at once | **sap-fiori-scaffolder** | "Create 3 Fiori apps for my services" |
| Learning the complete workflow | **Orchestrator** | "Walk me through building my first CAP app" |
| Quick fix or specific task | **Individual agent** | "Fix the route pattern in my manifest.json" |

## Agent Directory

All agents are located in `.ai/`:

```
.ai/
├── sap-cap-developer.md
├── sap-fiori-designer.md
├── sap-fiori-elements-developer.md
├── sap-fiori-scaffolder.md
└── sap-full-stack-orchestrator.md
```

## What You Get

- **CAP Best Practices:** Domain modeling with aspects, proper associations, service projections
- **Authorization Patterns:** Role-based access control, restrictions, field-level security
- **UI Annotations:** Production-ready Fiori Elements with proper labels, value helps, criticality
- **Professional UX:** Contact cards, conditional visibility, side effects, validation
- **Automated Generation:** Programmatic Fiori app scaffolding with metadata-driven approach

## Technical Focus

These agents emphasize:

- CDS-native development (not SQL/HDI)
- Annotation-driven UI (not freestyle coding)
- Value helps and dropdowns everywhere
- Human-friendly labels (never show technical IDs)
- Criticality and status visualization
- Draft-enabled workflows
- Multi-language support
- Test data generation

Built for developers who want to ship enterprise SAP applications fast, following SAP best practices.
