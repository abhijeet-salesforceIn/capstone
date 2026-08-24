# Architecture — Agentforce Capstone (Pacific Haven Properties)

Technical architecture documentation for the three Agentforce agents built for Pacific Haven Properties.

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Agent Architecture](#agent-architecture)
3. [Routing Architecture](#routing-architecture)
4. [Data Flow](#data-flow)
5. [Security Architecture](#security-architecture)
6. [Compliance Design](#compliance-design)
7. [Deployment Architecture](#deployment-architecture)

---

## System Overview

```
┌─────────────────────────────────────────────────┐
│              Frontend Layer                     │
│   Experience Cloud Portal  |  Salesforce UI     │
└───────────────┬─────────────────────┬───────────┘
                │                     │
┌───────────────▼─────────────────────▼───────────┐
│              Messaging Layer                    │
│   Omnichannel Router → MessagingSession         │
│   Route Extraction (userId present?)            │
└─────────┬──────────────────────┬────────────────┘
          │                      │
     userId = NULL          userId = set
          │                      │
┌─────────▼────────┐   ┌─────────▼────────────────┐
│  Leasing         │   │  Tenant Concierge Agent   │
│  Assistant       │   │  (Authenticated)          │
│  (Anonymous)     │   └──────────────────────────┘
└──────────────────┘
                              ┌───────────────────┐
                              │  Ops Copilot       │
                              │  (Internal —       │
                              │   Salesforce UI)   │
                              └───────────────────┘
```

All three agents use **Einstein HyperClassifier** (`sfdc_ai__DefaultEinsteinHyperClassifier`) for intent routing. Leasing and Tenant Concierge run as `ExternalCopilot` (Service Agent). Ops Copilot runs as `AgentforceEmployeeAgent`.

---

## Agent Architecture

### Leasing Assistant (v22)

**Access:** Anonymous users (Experience Cloud)
**Model:** `sfdc_ai__DefaultEinsteinHyperClassifier`
**RAG:** Enabled (`ARFPC_1JDoB000000KyuTWAS`) with citations

```
Leasing Assistant
└── Agent Router (intent classification)
    ├── Property_Search subagent
    │   ├── Get_Available_Apartments  →  flow://Get_Available_Apartments
    │   ├── Get_Move_In_Specials      →  flow://Get_Move_In_Specials
    │   └── Create_Lead_Record        →  flow://Create_Lead_Record
    ├── GeneralFAQ subagent
    │   └── AnswerQuestionsWithKnowledge  →  RAG (Tenant Handbook)
    ├── escalation subagent
    │   └── escalate_to_human
    ├── ambiguous_question subagent
    └── off_topic subagent
```

**Routing rules (from agent script):**
- Property/pricing/bedroom/rent/discount keywords → `Property_Search`
- Policy/amenity/pet/lease terms/deposit keywords → `GeneralFAQ`
- Explicit "speak with human" only (no property ask) → `escalation`
- Prior lead-capture conversation continuation (name/email/phone in message) → `Property_Search`

---

### Tenant Concierge Agent (v36)

**Access:** Authenticated tenants (MessagingSession with userId)
**Model:** `sfdc_ai__DefaultEinsteinHyperClassifier`
**RAG:** Enabled (`ARFPC_1JDoB000000KyuTWAS`) with citations
**Type:** ExternalCopilot

```
Tenant Concierge Agent
└── Agent Router (intent classification)
    ├── Maintenance_Support subagent
    │   ├── AnswerQuestionsWithKnowledge  →  RAG
    │   └── Create_Maintenance_Case       →  flow://Create_Maintenance_Case
    ├── Door_Unlock_and_OTP_Security subagent
    │   ├── Send_Verification_Code        →  flow://Send_Verification_Code
    │   └── Verify_Customer_Code          →  flow://Verify_Customer_Code
    ├── Keyfob_Replacement subagent
    │   ├── AnswerQuestionsWithKnowledge  →  RAG
    │   └── Order_Keyfob_Replacement      →  flow://Order_Keyfob_Replacement
    ├── escalation subagent
    │   ├── escalate_to_human
    │   └── Create_Maintenance_Case       →  flow://Create_Maintenance_Case (off-hours fallback)
    ├── ambiguous_question subagent
    └── off_topic subagent
```

**Session variables (linked from MessagingSession):**

| Variable | Source | Purpose |
|---|---|---|
| `EndUserId` | `MessagingSession.MessagingEndUserId` | Identify end user |
| `ContactId` | `MessagingEndUser.ContactId` | Linked Salesforce contact |
| `RoutableId` | `MessagingSession.Id` | Session routing |
| `ChannelType` | `MessagingSession.ChannelType` | Channel context |
| `authenticationKey` | Internal | Stores OTP key for session |
| `isVerified` | Internal (boolean) | OTP verification state |
| `customerId` | Internal | Resolved tenant ID |

---

### Ops Copilot (v9)

**Access:** Internal — property managers via Salesforce native UI
**Model:** `sfdc_ai__DefaultEinsteinHyperClassifier`
**Type:** `AgentforceEmployeeAgent`
**Template:** `EmployeeCopilot__AgentforceEmployeeAgent`

```
Ops Copilot
└── Agent Router (intent classification)
    ├── Lease_Operations subagent
    │   ├── Get_Tenant_Rental_Summary    →  flow://Get_Tenant_Rental_Summary
    │   └── Get_Weekly_Property_Summary  →  flow://Get_Weekly_Property_Summary
    ├── ambiguous_question subagent
    └── off_topic subagent
```

**Context variables (set by Salesforce UI):**

| Variable | Source | Purpose |
|---|---|---|
| `currentAppName` | External | Active Salesforce app name |
| `currentObjectApiName` | External | Current object API name |
| `currentPageType` | External | Page type (record/list/home) |
| `currentRecordId` | External | Active record ID |
| `currentManagerUserId` | Internal | Running manager's `$User.Id` for scope enforcement |
| `currentTenantAccountId` | Internal | Account ID of tenant under review |
| `currentRenewalAction` | Internal | Persists renewal recommendation across turns |
| `currentMonthlyRent` | Internal | Used for 10% increase calculation |

**Manager scoping:** The `Get_Weekly_Property_Summary` flow receives `currentManagerUserId` (set at runtime to `$User.Id`) to ensure the report only covers properties assigned to the authenticated manager. No hardcoded IDs.

---

## Routing Architecture

### Session Routing Flow

```
Tenant opens embedded chat on Experience Cloud
        │
        ▼
Prechat form collects userId (if logged in)
        │
        ▼
MessagingSession created with userId field
        │
        ▼
Omnichannel Flow: Tenant_Agent_Route_to_Work
        │
  userId present?
  /             \
YES              NO
  │               │
  ▼               ▼
Tenant         Leasing
Concierge      Assistant
Agent          Queue
```

Property managers access Ops Copilot directly from the Salesforce record page (no MessagingSession routing required).

---

## Data Flow

### Leasing: Prospect to Lead

```
Prospect input: "2BR under $2000 in SF"
        │
        ▼
Property_Search subagent
        │
        ├─ Execute Get_Available_Apartments(bedrooms=2, city=SF, maxRent=2000)
        │       └── SOQL: Apartment__c WHERE Bedrooms=2 AND City=SF
        │              AND MonthlyRent <= 2000 AND Available=true
        │
        ├─ Return list of matching apartments
        │
        ├─ Collect: Name, Email, Phone
        │
        └─ Execute Create_Lead_Record(name, email, phone, city)
                └── DML: Lead INSERT (Status=Open, Source=Leasing Agent)
```

### Tenant Concierge: OTP Door Unlock

```
Tenant: "I'm locked out"
        │
        ▼
Door_Unlock_and_OTP_Security subagent
        │
        ├─ Sentiment check (angry? → escalate)
        │
        ├─ Execute Send_Verification_Code(MessagingUser_Id)
        │       └── Generates OTP, stores authenticationKey in session variable
        │
        ├─ Tenant enters code
        │
        ├─ Execute Verify_Customer_Code(code, authenticationKey)
        │       └── Compares input against stored key
        │           ├─ MATCH: set isVerified=true, resolve door from tenant record
        │           └─ NO MATCH: refuse, log attempt
        │
        └─ (On success) Trigger door unlock action via verified tenant record
```

### Tenant Concierge: Maintenance Case with Recurrence Check

```
Tenant: "My faucet is leaking again"
        │
        ▼
Maintenance_Support subagent
        │
        ├─ AnswerQuestionsWithKnowledge (RAG troubleshooting steps)
        │
        ├─ "Is the issue resolved?" → NO
        │
        └─ Execute Create_Maintenance_Case(contactId, issueType, description)
                └── DML: Case INSERT (Type=Maintenance, Status=New)
                └── SOQL: Count Cases for this Account in last 12 months
                    ├─ >= 3 cases: recommend replacement
                    └─ < 3 cases: case created, inform tenant
```

### Ops Copilot: Renewal Decision

```
Manager: "Review John Doe's lease"
        │
        ▼
Lease_Operations subagent
        │
        ├─ Resolve Account ID from currentRecordId or prompt
        │
        ├─ Execute Get_Tenant_Rental_Summary(accountId)
        │       └── SOQL: COUNT LeasePayment__c WHERE Past_Due__c=true AND AccountId=:id
        │       └── SOQL: COUNT Case WHERE AccountId=:id
        │       └── Returns: latePaymentCount, totalCaseCount, renewalAction
        │
        ├─ Store renewalAction in currentRenewalAction variable
        │
        └─ Present summary (CCPA-filtered, no protected characteristics)
                └── On renewal draft request:
                    ├─ WARM_RENEWAL (0 late)  → standard rate email
                    ├─ TEN_PERCENT_INCREASE (1-3 late) → +10% rent email
                    └─ NO_RENEWAL (>3 late) → decline email
```

---

## Security Architecture

### Authentication Layers

| Agent | Auth Level | Mechanism |
|---|---|---|
| Leasing Assistant | None | Anonymous MessagingSession |
| Tenant Concierge | Session | MessagingSession userId (portal login) |
| Tenant Concierge (door) | Step-up | OTP via Send/Verify_Verification_Code flows |
| Ops Copilot | Salesforce session | Native Salesforce user login (`$User.Id`) |

### OTP Verification Detail

The door unlock flow requires two sequential verified steps:

1. `Send_Verification_Code` — generates a cryptographic OTP, sends to tenant's registered contact, stores `authenticationKey` in the session variable (Internal visibility)
2. `Verify_Customer_Code` — compares tenant-entered code against `authenticationKey`; sets `isVerified=true` only on exact match

The tenant's unit/door ID is resolved from their verified Salesforce record — never from user-provided input. This prevents identity spoofing even if an OTP is intercepted.

### Jailbreak Guardrails

| Guardrail | Agent | Rule |
|---|---|---|
| Discount guardrail | Leasing | Only offer specials returned by `Get_Move_In_Specials` — never invent amounts |
| Unit override prevention | Concierge | Door/unit resolved from tenant record only |
| Knowledge grounding | Leasing + Concierge | All FAQ answers from RAG — citations required |
| Lead validation | Leasing | Require name + email + phone before `Create_Lead_Record` |
| Renewal bias prevention | Ops | Reject requests that reference protected characteristics |

---

## Compliance Design

### CCPA (California Consumer Privacy Act)

The Ops Copilot system instructions explicitly prohibit inclusion of:
- Employer name
- Employment status
- Income details

These are silently omitted from all agent outputs regardless of what the underlying records contain.

### Fair Housing Act

The Ops Copilot renewal logic is based exclusively on objective payment history (`latePaymentCount`). The system instructions include a hard refusal for any request that attempts to incorporate:

> race, color, religion, sex, national origin, familial status, disability, sexual orientation, gender identity

If a manager's input references these characteristics, the agent refuses and explains that decisions must be based solely on payment history.

### Manager Scoping

`Get_Weekly_Property_Summary` passes `currentManagerUserId` (set at runtime from `$User.Id`) as a required input to the flow. The flow queries only `Apartment__c` records where `OwnerId = :managerId`. Cross-manager data access is structurally impossible through the agent.

---

## Deployment Architecture

### Metadata Types Deployed

| Type | Count | Key Items |
|---|---|---|
| `Bot` | 4 | Tenant_Concierge_Agent, Leasing_Assistant, Ops_Copilot, Copilot_for_Salesforce |
| `GenAiPlannerBundle` | 4 | v36, v22, v9, EmployeeCopilotPlanner |
| `GenAiFunction` | 4 | Create_Lead_Record, Get_Available_Apartments, Get_Move_In_Specials, File_PACIFIC_HAVEN |
| `GenAiPromptTemplate` | 4 | Field generation + Flex AI templates |
| `Flow` | 16 | All agent action flows + routing flows |
| `ApexClass` | 37 | Case, auth, community, field generation classes |
| `CustomObject/Field` | 79 files | All custom object definitions |

### Deployment Commands (Salesforce CLI v2)

```bash
# Validate (dry run — no changes deployed)
sf project deploy validate --manifest manifest/package.xml --target-org my-org

# Deploy all metadata
sf project deploy start --manifest manifest/package.xml --target-org my-org

# Deploy specific metadata type
sf project deploy start --metadata "GenAiPlannerBundle:Tenant_Concierge_Agent_v36" --target-org my-org

# Check status
sf project deploy report
```

### Environment Strategy

| Environment | Purpose |
|---|---|
| Developer Sandbox | Agent configuration, flow development, unit testing |
| UAT Sandbox | End-to-end scenario testing, security review |
| Production | Live agents, customer data, monitoring |

### Deployment Checklist

Before deploying to a new org:

- [ ] Verify Agentforce / Einstein Service Agent license is enabled
- [ ] Confirm Omnichannel Messaging is configured
- [ ] Publish Knowledge articles (required for RAG)
- [ ] Confirm `currentManagerUserId` is injected dynamically at runtime (no hardcoded IDs)
- [ ] Validate OTP flows have access to the tenant's registered contact channel
- [ ] Run `sf project deploy validate` and resolve all errors before full deploy
- [ ] Run Apex test suite: `sf apex run test --target-org <alias> --synchronous`

---

**Architecture Document Version:** 1.1.0
**Last Updated:** August 2026
**Owner:** Abhijeet Kumar (Salesforce FDE)
