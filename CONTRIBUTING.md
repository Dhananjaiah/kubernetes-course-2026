# Contributing to Kubernetes Course 2026

Thank you for your interest in contributing to this Kubernetes course! This document provides guidelines for contributing.

## How to Contribute

### Types of Contributions

We welcome several types of contributions:

1. **Bug fixes** - Fix typos, broken links, incorrect commands
2. **Content improvements** - Enhance explanations, add examples, improve clarity
3. **New examples** - Add YAML manifests, scripts, or practical examples
4. **Lab exercises** - Create hands-on exercises for students
5. **Module completion** - Help complete remaining course modules
6. **Translations** - Translate content to other languages
7. **Documentation** - Improve README, setup guides, or troubleshooting

### Getting Started

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub, then:
   git clone https://github.com/YOUR-USERNAME/kubernetes-course-2026.git
   cd kubernetes-course-2026
   ```

2. **Create a branch**
   ```bash
   git checkout -b feature/your-contribution-name
   ```

3. **Make your changes**
   - Follow the style guidelines below
   - Test your changes locally
   - Update documentation if needed

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Brief description of your changes"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-contribution-name
   ```

6. **Create a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill in the PR template
   - Submit for review

## Style Guidelines

### Markdown Style

- Use ATX-style headers (`#`, `##`, `###`)
- Use fenced code blocks with language specification
- Use tables for structured data
- Keep lines under 120 characters when possible
- Use relative links for internal references

**Example:**
```markdown
## Section Title

Some text with a [link](./other-file.md).

```bash
# Code example
kubectl get pods
```

| Header 1 | Header 2 |
|----------|----------|
| Value 1  | Value 2  |
```

### Code Examples

- Always specify language in code blocks
- Test commands before including them
- Include expected output when helpful
- Add comments to explain complex commands
- Use realistic, meaningful names (not foo, bar)

**Good:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-server
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

**Avoid:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: foo
spec:
  containers:
  - name: bar
    image: nginx
```

### YAML Manifests

- Use 2 spaces for indentation
- Include meaningful metadata (name, labels)
- Add comments for complex configurations
- Follow Kubernetes best practices
- Validate YAML before committing

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: descriptive-name
  labels:
    app: myapp
    environment: production
  annotations:
    description: "What this resource does"
spec:
  # Resource specifications
  containers:
  - name: container-name
    image: image:tag
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Documentation Structure

Each module should follow this structure:

```markdown
# Module X: Title

## Overview
Brief description of what the module covers

## Learning Objectives
- Objective 1
- Objective 2
- Objective 3

## Table of Contents
1. [Section 1](#section-1)
2. [Section 2](#section-2)

---

## Section 1
Content...

## Section 2
Content...

---

## Hands-On Lab
Practical exercises

---

## Summary
- ✅ Key takeaway 1
- ✅ Key takeaway 2

## Next Steps
Link to next module

## Additional Resources
- [Resource 1](url)
- [Resource 2](url)

---

[← Previous: Module X-1](0X-1-previous.md) | [Next: Module X+1 →](0X+1-next.md)
```

## Content Guidelines

### Writing Style

- **Clear and concise**: Avoid jargon when simpler terms work
- **Beginner-friendly**: Explain concepts before diving into details
- **Practical**: Include real-world examples and use cases
- **Progressive**: Build on previous concepts
- **Accurate**: Test all commands and examples

### Code Examples

- Test all commands in a real Kubernetes cluster
- Use Minikube or kind for testing
- Include expected output when helpful
- Show both successful and error scenarios
- Explain what each command does

### Lab Exercises

Good lab exercises should:
- Have clear objectives
- Build on previous knowledge
- Include step-by-step instructions
- Show expected results
- Include troubleshooting tips
- Have cleanup instructions

**Example Lab Structure:**
```markdown
### Lab X: Title

**Objective:** What you'll learn or build

**Prerequisites:**
- Prerequisite 1
- Prerequisite 2

**Steps:**

1. **Step 1 title**
   ```bash
   kubectl command
   ```
   Expected output:
   ```
   Output here
   ```

2. **Step 2 title**
   ...

**Verification:**
How to verify it worked

**Cleanup:**
```bash
kubectl delete ...
```
```

## Testing Your Changes

### Local Testing

1. **Markdown rendering**: Use a markdown previewer
2. **Commands**: Test in a local Kubernetes cluster
3. **Links**: Verify all internal links work
4. **YAML**: Validate with `kubectl apply --dry-run=client -f file.yaml`

### Command Testing

```bash
# Start fresh Minikube cluster
minikube delete
minikube start

# Test your commands
kubectl apply -f your-manifest.yaml
kubectl get pods

# Clean up
kubectl delete -f your-manifest.yaml
```

### YAML Validation

```bash
# Validate YAML syntax
kubectl apply --dry-run=client -f manifest.yaml

# Validate with server-side checks
kubectl apply --dry-run=server -f manifest.yaml

# Check with kubeval (if installed)
kubeval manifest.yaml
```

## Commit Messages

Write clear, descriptive commit messages:

**Good:**
```
Add hands-on lab for Services module

- Added 3-part lab covering ClusterIP, NodePort, and LoadBalancer
- Included verification steps and expected outputs
- Added cleanup instructions
```

**Avoid:**
```
Update files
Fixed stuff
Changes
```

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature or content
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code/content restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

## Pull Request Process

### Before Submitting

- [ ] Test all code examples
- [ ] Validate YAML manifests
- [ ] Check spelling and grammar
- [ ] Verify all links work
- [ ] Update table of contents if needed
- [ ] Follow style guidelines

### PR Description

Include in your PR:

1. **What**: Brief description of changes
2. **Why**: Reason for the changes
3. **How**: Approach taken
4. **Testing**: How you tested the changes
5. **Screenshots**: If UI/output changes

**Example:**
```markdown
## Description
Added hands-on lab for the Services module covering all service types.

## Why
Module 8 was missing practical exercises for students to practice creating services.

## Changes
- Added 3-part lab in docs/08-services.md
- Created example manifests in examples/services/
- Updated module navigation links

## Testing
- Tested all commands in Minikube 1.28
- Verified all service types work as expected
- Validated YAML with kubectl --dry-run

## Checklist
- [x] Tested locally
- [x] Updated documentation
- [x] Follows style guide
```

### Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. Your contribution will be credited

## Module Completion

If you're completing one of the remaining modules (5-21):

1. Follow the existing module structure
2. Reference the presentation (K8s-Runbook.pptx) for content
3. Include:
   - Clear explanations
   - Code examples
   - Hands-on labs
   - Common troubleshooting
4. Create corresponding example manifests
5. Update the main README if needed

### Modules Needing Completion

- Module 5: ReplicaSets
- Module 6: Deployments
- Module 7: Labels & Selectors
- Module 8: Services
- Module 9: Update Strategies & Rollback
- Module 10: Cluster Maintenance
- Module 11: DaemonSets, Jobs & CronJobs
- Module 12: ConfigMaps & Secrets
- Module 13: Health Probes
- Module 14: Node Scheduling
- Module 15: Taints & Tolerations
- Module 16: Storage & Persistence
- Module 17: StatefulSets
- Module 18: RBAC
- Module 19: Ingress
- Module 20: Network Policies
- Module 21: Helm

## Questions?

- Open an issue for questions
- Join discussions in existing issues/PRs
- Check the FAQ document
- Review closed PRs for examples

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the content, not the person
- Help create a positive learning environment

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.

---

Thank you for contributing to this course! Your efforts help learners worldwide master Kubernetes. 🚀
