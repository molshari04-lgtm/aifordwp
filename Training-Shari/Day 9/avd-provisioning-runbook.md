# AVD Provisioning Runbook — POOL-FIN-01 / FinBridge-Workspace

**Date:** 2026-08-13
**Engineer:** DWP (Desktop Workplace)
**Subscription:** `6da86af0-2cc6-4e5d-8f3d-bbf6e05c686d` (labs25)
**Resource group:** `dwp-lab-rg` (Central US — see note below)
**M365 tenant:** zippyops.in
**Target user:** p53@zippyops.in

## 1. Pre-flight permission check

Before making any changes, confirmed the signed-in identity's RBAC on the subscription:

```powershell
az account show --output json
az role assignment list --assignee traininguser73@zippyops.in --all --output table
```

Result: signed-in account had **Owner** on the subscription — sufficient to create role assignments, so provisioning proceeded.

## 2. Resource group check

```powershell
az group show -n dwp-lab-rg --output table
```

`dwp-lab-rg` already existed in **Central US**, not East US as requested in the brief. Azure does not allow changing an existing resource group's region, and creating a duplicate RG in East US would have fragmented the environment, so the existing Central US resource group was used as-is. **This deviation from the requested region should be flagged to the requester.**

## 3. Inventory of existing resources

```powershell
az resource list -g dwp-lab-rg --output table
```

A prior deployment of the full target stack already existed in the resource group. Rather than re-creating resources blindly, each one was individually verified against requirements:

| Resource | Command used to verify | Result |
|---|---|---|
| Host pool `POOL-FIN-01` | `az desktopvirtualization hostpool show -g dwp-lab-rg -n POOL-FIN-01` | Pooled, `loadBalancerType: BreadthFirst`, `maxSessionLimit: 5` ✅ |
| App group `POOL-FIN-01-DAG` | `az desktopvirtualization applicationgroup show -g dwp-lab-rg -n POOL-FIN-01-DAG` | `applicationGroupType: Desktop`, linked to host pool and workspace ✅ |
| Workspace `FinBridge-Workspace` | `az desktopvirtualization workspace show -g dwp-lab-rg -n FinBridge-Workspace` | References `POOL-FIN-01-DAG` ✅ |
| Session host `POOL-FIN-01-SH0` | `az vm show -g dwp-lab-rg -n POOL-FIN-01-SH0` | `Standard_B2ms`, image `MicrosoftWindowsDesktop:windows-11:win11-24h2-avd` (AVD-optimized multi-session), `securityProfile.securityType: TrustedLaunch` with `secureBootEnabled` and `vTpmEnabled` both `true` ✅ |
| Entra ID join (no on-prem AD) | inspected VM `resources` extensions | `AADLoginForWindows` extension present and `Succeeded`; DSC extension has `aadJoin: true`; no domain-join extension present ✅ |

## 4. Session host health diagnosis

The CLI (`az desktopvirtualization`) has no `sessionhost` subcommand in the installed extension version, so status was queried directly via ARM REST:

```powershell
$sub = "6da86af0-2cc6-4e5d-8f3d-bbf6e05c686d"
az rest --method get --url "https://management.azure.com/subscriptions/$sub/resourceGroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/hostPools/POOL-FIN-01/sessionHosts?api-version=2023-09-05"
```

Initial result: session host status = **`Shutdown`**, `sessionHostHealthCheckResults` empty.

Rather than re-running the same deployment command, the underlying VM was diagnosed directly:

```powershell
az vm get-instance-view -g dwp-lab-rg -n POOL-FIN-01-SH0 --query "instanceView.statuses"
```

Root cause: `PowerState/deallocated` — the VM was simply powered off, not faulted.

Fix:

```powershell
az vm start -g dwp-lab-rg -n POOL-FIN-01-SH0
```

Re-checked instance view (`PowerState/running`) and then re-queried the session host status via the same REST call. Once the RDAgent came back up and reported in, all health checks passed:

- `DomainJoinedCheck` — Succeeded
- `DomainTrustCheck` — Succeeded
- `SxSStackListenerCheck` — Succeeded
- `UrlsAccessibleCheck` — Succeeded
- `MetaDataServiceCheck` — Succeeded
- `AppAttachHealthCheck` — Succeeded
- `TURNRelayAccessHealthCheck` — Succeeded
- `AADJoinedHealthCheck` — Succeeded (Entra device ID confirmed)

Final status: **`Available`**.

## 5. Role assignments for p53@zippyops.in

Confirmed the target user exists in Entra ID:

```powershell
az ad user show --id "p53@zippyops.in"
```

Assigned the two roles required for (a) direct RDP to the Entra-joined VM and (b) connecting to the published desktop through the AVD client:

```powershell
$userId  = "f0845865-439b-446a-ad12-989db93046c3"   # p53@zippyops.in
$vmScope = "/subscriptions/6da86af0-2cc6-4e5d-8f3d-bbf6e05c686d/resourceGroups/dwp-lab-rg/providers/Microsoft.Compute/virtualMachines/POOL-FIN-01-SH0"
$dagScope = "/subscriptions/6da86af0-2cc6-4e5d-8f3d-bbf6e05c686d/resourceGroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/applicationgroups/POOL-FIN-01-DAG"

# Direct RDP login (Entra-joined VM — local admin creds are not used)
az role assignment create --assignee-object-id $userId --assignee-principal-type User `
  --role "Virtual Machine User Login" --scope $vmScope

# AVD client access to the published desktop
az role assignment create --assignee-object-id $userId --assignee-principal-type User `
  --role "Desktop Virtualization User" --scope $dagScope
```

Verified with:

```powershell
az role assignment list --assignee "f0845865-439b-446a-ad12-989db93046c3" --all --output table
```

Final state:

| Principal | Role | Scope |
|---|---|---|
| p53@zippyops.in | Virtual Machine User Login | `.../virtualMachines/POOL-FIN-01-SH0` |
| p53@zippyops.in | Desktop Virtualization User | `.../applicationgroups/POOL-FIN-01-DAG` |

## Outcome

- Host pool, application group, workspace, and session host all match the requested spec.
- Session host is `Available` and passing all AVD health checks.
- p53@zippyops.in can both RDP directly into the session host and connect to the published desktop via the AVD client.
- **Open item:** resource group region is Central US, not East US as originally requested — needs a decision from the requester (leave as-is, or migrate to a new East US resource group).
