# LAB ONLY. This file is scanned statically; it is not intended for deployment.
# Challenge: Change the CIDR to 0.0.0.0/0 in a branch and open a pull request.
# Expected: Checkov policy CKV_AWS_24 fails. Then restore this restricted CIDR.

resource "aws_security_group" "admin_access" {
  name        = "security-gate-lab-admin"
  description = "Lab-only example for a GitHub Actions security gate"

  ingress {
    description = "SSH from one hypothetical admin address only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
