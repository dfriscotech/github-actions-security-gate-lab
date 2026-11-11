# Security Finding / Pull Request Review

**Finding ID:**
**Date:**
**Reviewer:**
**Pull request / commit:**
**Scanner and check ID:** Checkov / CKV_AWS_24
**Affected file and line:**
**Status:** Open / Remediated / Accepted exception

## 1. Technical finding
What configuration triggered the scanner? Include the exact rule and offending CIDR.

## 2. Risk / attack path
What type of access does this allow? What additional conditions would be needed for exploitation? Do not assume exposure equals confirmed compromise.

## 3. Business impact
How could this affect an organization if the configuration were deployed in a reachable environment?

## 4. Recommended remediation
Describe the least-privilege configuration, authorized access model, and expected code change.

## 5. Evidence
Paste the failed check name/output, link to the Actions run, and mention the affected code line. Do not include secrets.

## 6. Verification
Paste the successful rerun result and PR link. Confirm what was verified (static IaC scan, not runtime AWS state).

## 7. Ownership / next action
Who owns remediation? Is a security exception warranted? What needs follow-up?
