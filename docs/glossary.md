# Glossary

- **Repository (repo):** A project storing code and its version history.
- **Branch:** A parallel line of code changes you can develop without editing `main` directly.
- **Commit:** A recorded snapshot of changes.
- **Pull request (PR):** A proposal to merge branch changes, including review and automated checks.
- **GitHub Actions:** GitHub's workflow automation platform.
- **Event:** Something that can trigger a workflow, e.g., opening or updating a PR.
- **Workflow:** YAML file in `.github/workflows/` that defines automation.
- **Job:** A collection of steps run on a specified runner.
- **Step:** An action or shell command executed during a job.
- **Runner:** The machine executing the job (here, an Ubuntu runner hosted by GitHub).
- **Checkov:** Static infrastructure-as-code security scanner.
- **Infrastructure as code (IaC):** Defining infrastructure through version-controlled files such as Terraform.
- **Security gate:** A policy-enforced automated check that must succeed before a change can merge.
- **Branch protection:** Repository rule that can require status checks and/or reviews before merging.
- **CKV_AWS_24:** Checkov policy for AWS security group rules exposing port 22 to all IPv4 addresses.
- **CIDR:** Network address range notation (`0.0.0.0/0` means any IPv4 address; `/32` means one IPv4 address).
- **Least privilege:** Granting only the access necessary to perform a task.
- **Shift left:** Find security problems earlier in development, before infrastructure or software is deployed.
