---
name: sap-full-stack-orchestrator
description: Master orchestrator for end-to-end SAP CAP + Fiori application development
---

# SAP Full-Stack Orchestrator Skill

This skill coordinates the complete development lifecycle of SAP CAP applications with Fiori Elements frontends, guiding you through all phases from requirements to deployment.

## When to Use

- Building a complete application from scratch
- Unsure where to start with a new project
- Want guided, phase-by-phase development
- Need to coordinate backend, frontend, and deployment
- Building your first SAP CAP + Fiori application

## How to Invoke

From your IDE (VSCode/Cursor with Claude Code extension):

```
Build me a complete application for managing customer returns with CAP backend and Fiori frontend
```

```
Guide me through creating an inventory management system from scratch
```

```
I want to build a complete booking system - walk me through all the steps
```

## 8-Phase Development Workflow

### Phase 1: Requirements Gathering
- Business domain understanding
- Entity identification
- User roles and permissions
- Key use cases and workflows

### Phase 2: Backend Foundation
- Domain model (entities, associations)
- Seed data for testing
- Database setup and testing

### Phase 3: Service Layer
- Service definitions
- Status flows (@flow.status)
- Validation constraints (@assert)
- Authorization rules

### Phase 4: Frontend Planning
- Floorplan selection per user role
- Navigation patterns
- Multi-app architecture design

### Phase 5: Frontend Scaffolding
- Generate Fiori applications
- Configure manifests
- Set up routing

### Phase 6: UI Enhancement
- Add rich annotations
- Implement value helps
- Configure contact cards
- Add charts and KPIs

### Phase 7: Testing & Validation
- Service tests
- Authorization tests
- End-to-end workflow testing

### Phase 8: Deployment
- MTA configuration
- XSUAA setup
- Deploy to SAP BTP
- Post-deployment verification

## What Makes This Different

**Guided vs. À La Carte:**
- **Orchestrator**: Step-by-step guidance through all phases
- **Individual agents**: Pick specific agents for specific tasks

Use orchestrator when:
- ✅ Starting from scratch
- ✅ Building complete applications
- ✅ Want structured approach
- ✅ Need coordination between phases

Use individual agents when:
- ✅ Adding features to existing apps
- ✅ Know exactly what you need
- ✅ Comfortable with CAP/Fiori already

## Agents Coordinated

The orchestrator leverages:
1. **sap-cap-developer** - Backend development
2. **sap-fiori-designer** - Floorplan selection
3. **sap-fiori-scaffolder** - App generation
4. **sap-fiori-elements-developer** - UI annotations
5. **sap-cap-deployment** - BTP deployment

## Full Documentation

See [../../.ai/sap-full-stack-orchestrator.md](../../.ai/sap-full-stack-orchestrator.md) for:
- Detailed 8-phase workflow (385 lines)
- Phase transition criteria
- Decision points and gates
- Complete example walkthroughs

## Example Usage

**New project:**
```
I want to build a complete RMA (Return Merchandise Authorization) system - guide me through everything
```

**Domain-specific:**
```
Build me a project management application with tasks, milestones, and team collaboration
```

**Learning:**
```
I'm new to SAP CAP and Fiori - help me build my first real application step by step
```

## Entry Point

Simply describe your business domain and the orchestrator will:
1. Ask clarifying questions about requirements
2. Guide you through each phase sequentially
3. Invoke appropriate agents at each step
4. Verify outputs before moving forward
5. Ensure completeness and quality throughout
