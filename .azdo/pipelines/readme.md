# Deployment Template Notes

## 1. Template Definitions

Typically, you would want to set up either Option (a), or Option (b) AND Option (c), but not all three jobs.

- **infra-only-pipeline.yml:** Deploys the main.bicep template and does nothing else
- **function-only-pipeline.yml:** Builds the function app and then deploys the function app to the Azure Function
- **infra-and-code-pipeline.yml:** Deploys the main.bicep template, builds the function app, then deploys the function app to the Azure Function

---

## 2. Deploy Environments

These YML files were designed to run as multi-stage environment deploys (i.e. DEV/QA/PROD). Each Azure DevOps environments can have permissions and approvals defined. For example, DEV can be published upon change, and QA/PROD environments can require an approval before any changes are made.

---

## 3. These pipelines needs a variable group named "PythonDemo"

See [Create DevOps Variable Group](/Docs/CreateDevOpsVariableGroups.md) for details.
