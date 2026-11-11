# GitHub Actions Security Gate — Lab 01

**Goal:** Simulate a security review of Terraform changes in a pull request. GitHub Actions automatically runs Checkov, catches unsafe SSH exposure, and returns a failed check. You remediate the configuration and demonstrate a passing check.

**No AWS account required. No Terraform apply. No credentials or secrets.** All infrastructure is sample Terraform text for static analysis only. Do not deploy the insecure example.

## Expected outcomes

1. Explain what event triggers a GitHub Actions workflow.
2. Understand workflow -> job -> step -> runner.
3. Open a PR that introduces a detectable IaC misconfiguration.
4. Read the Checkov finding and describe the risk.
5. Fix the misconfiguration and observe a passing check.
6. Optionally enforce the check as a branch protection requirement.
7. Write a security finding with evidence and remediation.

## Repository structure

```text
.github/workflows/security-gate.yml  # workflow definition
terraform/main.tf                   # secure baseline and test target
docs/finding-template.md           # analyst's investigation notes
docs/glossary.md                   # key concepts
README.md                          # this lab guide
```

## Requirements

- Git installed, VS Code or another editor, a GitHub account.
- A **new, empty** GitHub repository named `github-actions-security-gate-lab` (don't pre-create README, license, or .gitignore there).
- Optional: Python and Checkov locally. The GitHub workflow installs Checkov for you.

## Part A — Create repo and establish a green baseline

1. Unzip the project. In VS Code, open the **inner `github-actions-security-gate-lab` directory** (it contains `README.md`).
2. Create a new *empty* GitHub repository with the same name. Public is fine for this non-secret training project; private works too if your plan permits Actions.
3. Open the VS Code integrated terminal inside the directory and run:

```bash
git init
git branch -M main
git add .
git commit -m "Initial secure Terraform and Checkov workflow"
git remote add origin https://github.com/YOUR_USERNAME/github-actions-security-gate-lab.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username. Git may ask you to set `user.name` and `user.email` before the first commit. GitHub may ask you to authenticate.

4. On GitHub open **Actions** -> **Terraform Security Gate** -> **Run workflow** -> **Run workflow**.
5. Watch the **Checkov Terraform Security Scan** job. Expect a green pass for the scoped policy `CKV_AWS_24`.

> If GitHub prompts you to enable Actions, enable it for this repo. A workflow with only a pull-request trigger won't run until a PR exists; this lab also includes `workflow_dispatch` so you can manually test the baseline.

## Part B — Make an intentionally insecure change in a branch

```bash
git switch -c lab/open-ssh
```

Edit `terraform/main.tf`. Change this exact line:

```hcl
cidr_blocks = ["10.10.10.10/32"]
```

To:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

Then run:

```bash
git add terraform/main.tf
git commit -m "Lab: introduce unrestricted SSH ingress"
git push -u origin lab/open-ssh
```

Open GitHub -> **Pull requests** -> **New pull request**, with base branch `main` and compare branch `lab/open-ssh`. Give it the title `Lab: Review proposed SSH access change` and create it.

GitHub Actions should automatically run. Open the PR's **Checks** section or the **Actions** tab, select **Checkov Terraform Security Scan**, and inspect the failure. Look for policy `CKV_AWS_24` and the `0.0.0.0/0` ingress rule. The scan should fail because port 22 is reachable from any IPv4 address **if this configuration is deployed on a publicly reachable host**.

Write a short security finding using `docs/finding-template.md` (do not commit any sensitive tokens, credentials, or screenshots with personal data).

## Part C — Remediate and get a green check

Keep the PR open. Edit `terraform/main.tf` again, restoring:

```hcl
cidr_blocks = ["10.10.10.10/32"]
```

Then run:

```bash
git add terraform/main.tf
git commit -m "Restrict lab SSH ingress to one address"
git push
```

Return to the PR. The push updates it, automatically triggering another run of the workflow. Expect a pass for `CKV_AWS_24`. This proves the *static security gate* detected and cleared the specific misconfiguration; it does not prove the broader infrastructure is secure.

## Part D — Turn the scanner into an enforceable guardrail

A GitHub Actions check can fail without stopping a merge. To enforce it, enable branch protection for `main`:

1. Open the repo's **Settings** -> **Branches** (or repository rulesets depending on your UI).
2. Create a rule for `main` requiring pull requests and status checks to pass before merging.
3. Select **Checkov Terraform Security Scan** as a required status check after it has run at least once.
4. Optionally require review approvals. Validate the rule on a *new* intentionally failing PR; verify the merge is blocked until checks pass.

This feature is available for **public repositories on GitHub Free** and for **private repositories on certain paid plans**. Repository settings and organization policies can limit what you can configure.

## Part E — Security analyst write-up

Explain these questions in your own words:

1. What event triggered the workflow?
2. What did `actions/checkout` accomplish?
3. What runs `checkov -d terraform --framework terraform --check CKV_AWS_24`?
4. Why does `0.0.0.0/0` matter for port 22?
5. Does a scanner finding mean a compromise has happened? Why not?
6. What changed between the failed and passed runs?
7. How is a status check different from branch protection?
8. Why do we use `permissions: contents: read`?

## Optional: run Checkov locally

```bash
python -m pip install checkov
checkov -d terraform --framework terraform --check CKV_AWS_24
```

You can use `py -m pip install checkov` on Windows if `python` is not recognized. Running locally is useful before pushing changes; it is not required for the lab.

## Level-up exercises — after the first red -> green PR

- **Level 2 / broader scanning:** Remove `--check CKV_AWS_24` from the workflow so Checkov runs its broader Terraform policy set. Expect other findings; investigate each before making it a gate.
- **Level 3 / least privilege:** Write a second workflow job that checks GitHub Actions workflow permissions. Keep the token read-only unless permissions are explicitly required.
- **Level 4 / CNAPP:** Compare the IaC issues Checkov finds *before deployment* with the types of findings AWS Security Hub CSPM and IAM Access Analyzer generate for deployed infrastructure. Use a separately scoped AWS sandbox only when you are ready to set up billing controls.
- **Level 5 / portfolio:** Write a one-page case study: trigger, vulnerability, policy, failure log, fix, successful rerun, and policy-enforcement configuration.

## Safety and limitations

- Do not run `terraform apply` or place real keys in this lab. The example contains no provider configuration and is not intended to deploy.
- Use branch-local changes. A committed vulnerable configuration is intentionally stored for learning; don't copy it into production.
- The first version checks *only* `CKV_AWS_24`. Passing does not mean all security risks are eliminated.
- This intentionally uses published major-version GitHub Actions tags for ease of learning. For production, consider pinning third-party actions to reviewed commit SHAs, pinning scanner dependency versions, reviewing supply-chain risks, and carefully limiting token permissions.
- Never use `pull_request_target` to run untrusted PR code with privileged credentials. This lab uses `pull_request` and minimal permissions.
