# Capstone — Agentforce for Pacific Haven Properties

**Unified AI-Powered Property Management Platform built on Salesforce Agentforce.**

> Three autonomous agents for leasing, tenant support, and property management operations.

**Status:** Production-Ready | **Version:** 1.0.0 | **Last Updated:** August 2026

---

## Table of Contents

- [Overview](#overview)
- [Agents](#agents)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Data Model](#data-model)
- [Security & Compliance](#security--compliance)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Deployment](#deployment)
- [Testing](#testing)

---

## Overview

The **Pacific Haven Properties** Agentforce platform automates three core workflows:

| Agent | Audience | Primary Function |
|---|---|---|
| **Leasing Assistant** | Anonymous prospects | Apartment search, lead capture, property FAQ |
| **Tenant Concierge Agent** | Authenticated tenants | Maintenance, door unlock (OTP), keyfob replacement |
| **Ops Copilot** | Property managers | Rental history review, lease renewal drafts, weekly summaries |

---

## Agents

### Leasing Assistant (v22)

Public-facing agent for Experience Cloud. Routes to:

- **Property Search** — `Get_Available_Apartments`, `Get_Move_In_Specials`, `Create_Lead_Record`
- **General FAQ** — `AnswerQuestionsWithKnowledge` (RAG-grounded, citations enabled)
- **Escalation** — transfer to live leasing agent; fallback acknowledgement if unavailable

Guardrails:
- Discounts only offered from system results — no verbal agreements
- Lead capture requires name, email, and phone before record creation
- Urgent move-in requests (`"this week"`, `"immediately"`) escalate to a human for showing scheduling

---

### Tenant Concierge Agent (v36)

Authenticated tenant-facing agent. Routes to:

- **Maintenance Support** — troubleshoot via Knowledge, create `Create_Maintenance_Case`; flags recurring issues (3+ in 12 months) for replacement recommendation
- **Door Unlock & OTP Security** — identity verification via `Send_Verification_Code` + `Verify_Customer_Code` before any access action
- **Keyfob Replacement** — FAQ lookup, confirm fee, then `Order_Keyfob_Replacement`
- **Escalation** — transfers to human; creates a case as fallback when agents unavailable (e.g. off-hours)

Guardrails:
- Sentiment check before OTP flow — angry/frustrated users auto-escalated
- Unit/door identity resolved from verified tenant record only — never from user input

---

### Ops Copilot (v9)

Internal employee agent for property managers. Routes to:

- **Lease Operations** — `Get_Tenant_Rental_Summary`, `Get_Weekly_Property_Summary`, renewal email drafts

Renewal decision logic:

| Late Payments | Recommendation | Action |
|---|---|---|
| 0 | `WARM_RENEWAL` | Standard renewal at current rate |
| 1–3 | `TEN_PERCENT_INCREASE` | Renewal with +10% rent increase |
| >3 | `NO_RENEWAL` | Decline renewal offer |

Guardrails:
- CCPA: employer name, employment status, and income omitted from all outputs
- Fair Housing: protected characteristics never used in renewal decisions
- Manager scoping: weekly summaries limited to the authenticated manager's assigned properties (`$User.Id`)

---

## Architecture

```
Experience Cloud Portal (Embedded Chat)
        |
        v
Omnichannel Router (MessagingSession)
        |
   userId present?
   /             \
  YES             NO
  |               |
Tenant         Leasing
Concierge      Assistant
Agent          (Anonymous)
  |
  +-- Maintenance Support
  +-- Door Unlock & OTP
  +-- Keyfob Replacement
  +-- Escalation

Ops Copilot (Salesforce Native UI — Internal)
  +-- Lease Operations
```

Routing is handled by `Tenant_Agent_Route_to_Work` and `Agent_Route_to_Work` flows which inspect the MessagingSession for a userId to determine which agent to activate.

---

## Repository Structure

```
force-app/main/default/
├── bots/                              # Bot/Agent definitions
│   ├── Tenant_Concierge_Agent/        # v36 — ExternalCopilot (authenticated)
│   ├── Leasing_Assistant/             # v22 — ExternalCopilot (anonymous)
│   ├── Ops_Copilot/                   # v9  — Employee Agent (internal)
│   └── Copilot_for_Salesforce/        # v1  — Employee Copilot
│
├── genAiPlannerBundles/               # Agent scripts, graphs, and local action schemas
│   ├── Tenant_Concierge_Agent_v36/
│   ├── Leasing_Assistant_v22/
│   └── Ops_Copilot_v9/
│
├── genAiFunctions/                    # Callable agent functions
│   ├── Create_Lead_Record/
│   ├── Get_Available_Apartments/
│   ├── Get_Move_In_Specials/
│   └── File_PACIFIC_HAVEN_PROPERTIES_HANDBOOK/
│
├── genAiPromptTemplates/              # Prompt templates (field generation, Flex AI)
│
├── flows/                             # Automation flows (16 total)
│   ├── Agent_Route_to_Work.flow-meta.xml
│   ├── Tenant_Agent_Route_to_Work.flow-meta.xml
│   ├── Route_Work_to_Human_Agent.flow-meta.xml
│   ├── Create_Maintenance_Case.flow-meta.xml
│   ├── Send_Verification_Code.flow-meta.xml
│   ├── Verify_Customer_Code.flow-meta.xml
│   ├── Order_Keyfob_Replacement.flow-meta.xml
│   ├── Get_Available_Apartments.flow-meta.xml
│   ├── Get_Move_In_Specials.flow-meta.xml
│   ├── Create_Lead_Record.flow-meta.xml
│   ├── Get_Tenant_Rental_Summary.flow-meta.xml
│   ├── Get_Weekly_Property_Summary.flow-meta.xml
│   └── ...
│
├── classes/                           # Apex classes (37 total)
│   ├── CaseEmail.cls
│   ├── ApexResponseBody.cls / ApexResponseCustom.cls
│   ├── KnowledgeAnswersCaller.cls
│   ├── FieldGenerationApexClass.cls / FieldGenCaller.cls
│   └── Communities / Login / Auth controllers + tests
│
└── objects/                           # Custom object and field definitions

manifest/
└── package.xml                        # Deployment manifest (all metadata)
```

---

## Data Model

| Object | Purpose |
|---|---|
| `Lead` | Prospective tenant created by Leasing Agent |
| `Contact` | Registered tenant (linked to Account) |
| `Account` | Tenant account used by Concierge and Ops |
| `Case` | Maintenance cases raised by Concierge |
| `LeasePayment__c` | Lease payment records with `Past_Due__c` flag |
| `Apartment__c` | Available units queried by Leasing Agent |
| `Knowledge` | Tenant Handbook articles powering RAG |

---

## Security & Compliance

| Layer | Control |
|---|---|
| Authentication | OTP required before door unlock or sensitive access |
| Routing | Anonymous → Leasing; Authenticated → Concierge |
| Manager scoping | Ops Copilot uses `$User.Id` — no cross-manager data |
| CCPA | Employer, income, employment status omitted from all agent outputs |
| Fair Housing | Protected characteristics excluded from all renewal decisions |
| Jailbreak prevention | Door/unit identity resolved from system record only — never user input |

---

## Prerequisites

- Salesforce CLI (`sf`) v2.x or later — [install guide](https://developer.salesforce.com/tools/salesforcecli)
- Salesforce org with Agentforce / Einstein Service Agent enabled
- Omnichannel Messaging configured
- Knowledge articles published (RAG for Leasing and Concierge agents)
- Node.js 18+ (for linting/formatting, optional)

---

## Setup

### 1. Authenticate to your org

```bash
sf org login web --alias my-org
sf config set target-org=my-org
```

### 2. Verify connection

```bash
sf org display --target-org my-org
```

---

## Deployment

### Validate before deploying (dry run)

```bash
sf project deploy validate --manifest manifest/package.xml --target-org my-org
```

### Deploy all metadata

```bash
sf project deploy start --manifest manifest/package.xml --target-org my-org
```

### Deploy a single metadata type

```bash
# Flows only
sf project deploy start --metadata Flow --target-org my-org

# A specific bot
sf project deploy start --metadata "Bot:Tenant_Concierge_Agent" --target-org my-org

# A specific planner bundle
sf project deploy start --metadata "GenAiPlannerBundle:Tenant_Concierge_Agent_v36" --target-org my-org
```

### Check deployment status

```bash
sf project deploy report
```

---

## Testing

### Run all Apex tests

```bash
sf apex run test --target-org my-org --result-format human --synchronous
```

### Test scenarios by agent

#### Leasing Assistant

| Scenario | Input | Expected |
|---|---|---|
| Property search | "2BR under $2000 in San Francisco" | Returns apartments + lead capture |
| Move-in special | "Any discounts for immediate move-in?" | Returns exact system special only |
| FAQ | "What's your pet policy?" | RAG-grounded answer with citations |
| Urgent escalation | "I need to move in this week!" | Escalates to human agent |

#### Tenant Concierge Agent

| Scenario | Input | Expected |
|---|---|---|
| Maintenance | "My faucet is leaking" | Troubleshooting steps; case if unresolved |
| Recurring issue | "This keeps happening!" (4th time) | Escalate + recommend replacement |
| Door unlock | "I'm locked out" | OTP sent → verified → door unlocked |
| Keyfob | "I lost my keyfob" | Fee shown → confirmed → order placed |
| Off-hours | No agents available at 2 AM | Case created for morning review |

#### Ops Copilot

| Scenario | Input | Expected |
|---|---|---|
| Rental review | "Review John Doe's lease" | Late payment count + renewal recommendation |
| Renewal email | "Draft renewal for this tenant" | Email draft based on payment tier |
| Weekly summary | "Show me this week's metrics" | Units, late payments, new cases (manager-scoped) |

---

## Connected Org

| Alias | Username | Org ID |
|---|---|---|
| `my-org` | epic.out.5fdcabe93656@orgfarm.salesforce.com | 00DoB000003YIQ6UAO |

---

## Author

**Abhijeet Mondal**
Field Development Engineer, Salesforce

---

**Last Updated:** August 2026
