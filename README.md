# aws-infra — Terraform CI/CD Pipeline with Approval Gate

A production-style Infrastructure as Code (IaC) pipeline built on **Terraform + GitHub Actions**, implementing a secure plan-review-apply workflow with automated security scanning, audit logging, and SES email notifications.

---

## Pipeline Overview

```
Push to main
     │
     ▼
┌─────────────────────────────────────┐
│  JOB 1 — Lint, Security & Plan      │
│                                     │
│  ✔ TFLint        (lint)             │
│  ✔ tfsec         (security scan)    │
│  ✔ terraform fmt (format check)     │
│  ✔ terraform validate               │
│  ✔ terraform plan                   │
│  ✔ Upload binary plan → S3          │
│  ✔ Email plan output → Manager      │
└──────────────┬──────────────────────┘
               │
               ▼
     ⏳ Manual Approval Gate
     (GitHub Environment: production)
               │
               ▼
┌─────────────────────────────────────┐
│  JOB 2 — Apply                      │
│                                     │
│  ✔ Download approved plan from S3   │
│  ✔ terraform apply (saved plan)     │
│  ✔ Upload apply logs → S3           │
│  ✔ Email success/failure → Manager  │
└─────────────────────────────────────┘
```

---

## Key Design Decisions

### Plan Integrity
The binary `tfplan` artifact is uploaded to S3 after Job 1 and downloaded in Job 2 for apply. This ensures the **exact plan that was reviewed and approved is what gets applied** — no recalculation, no drift between approval and execution.

### Approval Gate
Job 2 is gated behind a GitHub **`production` environment** with required reviewers. The apply step cannot run until a designated approver manually approves the run in GitHub Actions. Approval link is sent automatically via email in Job 1.

### Audit Trail
Every pipeline run stores:
- `plans/<run_id>/tfplan` — binary plan artifact
- `plans/<run_id>/plan_output.txt` — human-readable plan
- `applies/<run_id>/apply_output.txt` — apply output

All stored in a dedicated S3 bucket, keyed by `github.run_id` for full traceability.

### SES Notifications
- **Plan email** — Full plan output + approval link sent to manager after Job 1
- **Success email** — Apply confirmation with S3 log paths sent after successful apply
- **Failure email** — Immediate failure alert with log path for investigation

---

## Tech Stack

| Tool | Version | Purpose |
|---|---|---|
| Terraform | 1.12.2 | Infrastructure provisioning |
| TFLint | 0.62.1 | Terraform linting |
| tfsec | 1.28.1 | Static security analysis |
| GitHub Actions | — | CI/CD orchestration |
| AWS SES | — | Email notifications |
| AWS S3 | — | Plan artifact & log storage |

---

## Infrastructure Provisioned

### S3 Bucket (Security Hardened)
- Private ACL with all public access blocked
- Versioning enabled
- KMS encryption (SSE-KMS) with key rotation enabled
- Bucket ownership controls enforced

---

## Repository Structure

```
aws-infra/
├── .github/
│   └── workflows/
│       └── terraform.yml     # Full CI/CD pipeline
├── main.tf                   # S3 + KMS resources
├── provider.tf               # AWS provider config
├── backend.tf                # Remote state (S3)
├── .terraform.lock.hcl       # Provider version lock
└── .gitignore
```

---

## Secrets Required

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS IAM credentials |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM credentials |
| `TF_LOGS_BUCKET` | S3 bucket for plan/apply log storage |
| `MANAGER_EMAIL` | Recipient address for SES notifications |

---

## Author

**Nikhil Thengane** — Cloud & DevOps Engineer  
[LinkedIn](https://linkedin.com/in/nikhil-thengane) · [nikhil.thengane@outlook.com](mailto:nikhil.thengane@outlook.com)
