# Branch Review

**Base Branch**: ${ARGUMENTS:-dev}

> **Instructions**: Execute each task in the order given to conduct a thorough review of the current branch changes.
> **Important**: Review only the changes made in this branch compared to the base branch.

## Git Diff Analysis

First, analyze the branch changes:

```bash
# Show current branch
git branch --show-current

# Show files changed in this branch
git diff --name-only ${ARGUMENTS:-dev}

# Show detailed diff
git diff ${ARGUMENTS:-dev}

# Show commit history for this branch
git log --oneline ${ARGUMENTS:-dev}..HEAD
```

---

## Task 1: Product Manager Review

**Objective**: Assess from a product management perspective, focusing on:
- **Business Value**: Do these branch changes clearly advance our core product goals and deliver immediate ROI?
- **User Experience**: Are the changes intuitive and delightful for users right now? If not, make fixes immediately.
- **Strategic Alignment**: Do the changes align with current (and long-term, i.e., now) strategic objectives?

**Action**: Provide clear directives on how to ensure maximum user and business impact. All "future" suggestions must be implemented now.

---

## Task 2: Developer Review

**Objective**: Evaluate the code changes thoroughly from a senior lead engineer perspective:
1. **Code Quality & Maintainability**: Are the changes structured for readability and easy maintenance? If not, refactor now.
2. **Performance & Scalability**: Will these changes operate efficiently at scale? If not, optimize immediately.
3. **Best Practices & Standards**: Note any deviation from coding standards and correct it now.

**Action**: Leave a concise yet complete review comment, ensuring all improvements happen immediately—no deferrals.

---

## Task 3: Quality Engineer Review

**Objective**: Verify the overall quality, testing strategy, and reliability of the changes:
1. **Test Coverage**: Are there sufficient tests (unit, integration, E2E) for the new changes? If not, add them now.
2. **Potential Bugs & Edge Cases**: Have all edge cases been considered in the changes? If not, address them immediately.
3. **Regression Risk**: Confirm changes don't undermine existing functionality. If risk is identified, mitigate now with additional checks or tests.

**Action**: Provide a detailed QA assessment, insisting any "future" improvements be completed right away.

---

## Task 4: Security Engineer Review

**Objective**: Ensure robust security practices and compliance for the changes:
1. **Vulnerabilities**: Could these changes introduce security vulnerabilities? If so, fix them right away.
2. **Data Handling**: Are we properly protecting sensitive data (e.g., encryption, sanitization) in the new code? Address all gaps now.
3. **Compliance**: Confirm alignment with any relevant security or privacy standards (e.g., OWASP, GDPR, HIPAA). Implement missing requirements immediately.

**Action**: Provide a security assessment. Any recommended fixes typically scheduled for "later" must be addressed now.

---

## Task 5: DevOps Review

**Objective**: Evaluate build, deployment, and monitoring considerations for the changes:
1. **CI/CD Pipeline**: Validate that the changes integrate smoothly with existing build/test/deploy processes. If not, fix it now.
2. **Infrastructure & Configuration**: Check whether the code changes require immediate updates to infrastructure or configs.
3. **Monitoring & Alerts**: Identify new monitoring needs or potential improvements and implement them immediately.

**Action**: Provide a DevOps-centric review, insisting that any improvements or tweaks be executed now.

---

## Task 6: UI/UX Designer Review

**Objective**: Ensure optimal user-centric design for the changes:
1. **Visual Consistency**: Confirm adherence to brand/design guidelines in the changes. If not, adjust now.
2. **Usability & Accessibility**: Validate that the UI changes are intuitive and compliant with accessibility standards. Make any corrections immediately.
3. **Interaction Flow**: Assess whether the user flow changes are seamless. If friction exists, refine now.

**Action**: Provide a detailed UI/UX evaluation. Any enhancements typically set for "later" must be done immediately.

---

**End of Branch Review**