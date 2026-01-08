# SAP CAP + Fiori AI Agents

AI agents for building enterprise SAP applications with CAP backend and Fiori Elements frontend. Updated for December 2025 CAP release.

## Quick Start

**Option 1: Full Guided Workflow**
```
Build me a complete [domain] application with CAP backend and Fiori frontend
```
Triggers `sap-full-stack-orchestrator` (8-phase guided development)

**Option 2: Individual Agents**
- "Help me create a CAP data model" → `sap-cap-developer`
- "Which Fiori floorplan should I use?" → `sap-fiori-designer`
- "Add annotations to my service" → `sap-fiori-elements-developer`
- "Generate a Fiori app" → `sap-fiori-scaffolder`
- "Deploy to SAP BTP" → `sap-cap-deployment`

## Agent Registry

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `sap-cap-developer` | Backend development | Domain models, services, handlers, auth, `@flow.status`, `@assert` |
| `sap-fiori-designer` | Floorplan selection | Choosing LROP, ALP, OVP, Worklist, FCL |
| `sap-fiori-elements-developer` | UI annotations | LineItem, Facets, ValueHelps, Criticality, `@hierarchy` |
| `sap-fiori-scaffolder` | App generation | Creating Fiori apps with `@sap-ux/fiori-elements-writer` |
| `sap-cap-deployment` | Cloud deployment | MTA build, XSUAA, HANA Cloud, BTP CF |
| `sap-full-stack-orchestrator` | End-to-end workflow | New projects, complete applications |

## Orchestrator Workflow

```
Phase 1: Requirements → Phase 2: Backend → Phase 3: Services
                                              ↓
Phase 4: Frontend Planning → Phase 5: Scaffolding → Phase 6: UI Enhancement
                                                         ↓
                                    Phase 7: Testing → Phase 8: Deployment
```

## December 2025 CAP Features

All agents support:
- `@flow.status` - Declarative state transitions (Gamma)
- `@assert` - Declarative validation constraints (Gamma)
- `@hierarchy` - Simplified tree views
- Auto-loading from `app/*` subfolders
- Enum symbols in annotation expressions

## File Structure

```
.ai/
├── sap-cap-developer.md           # Backend specialist
├── sap-cap-deployment.md          # Cloud deployment
├── sap-fiori-designer.md          # Floorplan expert
├── sap-fiori-elements-developer.md # Annotation specialist
├── sap-fiori-scaffolder.md        # App generator
└── sap-full-stack-orchestrator.md # Workflow coordinator
```

## Best Practices

1. **Start with orchestrator** for new projects
2. **Use individual agents** for specific tasks on existing projects
3. **Always test with `cds watch`** after each phase
4. **Use declarative features** (`@flow.status`, `@assert`) over imperative code
5. **Separate concerns** - flows, constraints, auth in separate `.cds` files
