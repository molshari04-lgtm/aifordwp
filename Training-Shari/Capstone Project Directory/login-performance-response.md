# Prompt 4a: Login/Performance

## Technical Action

**Working assumption:** evidence has confirmed that the Friday **Document Manager** deployment causes resource contention during Floor 6 sign-in. The DMS package name, application ID, affected Entra ID device group, Configuration Manager device collection, and approved previous version are **to confirm** before action.

**Permission requirement:** This step requires an Intune Administrator, Endpoint Manager Administrator, or a Configuration Manager role with permission to modify application deployments and collections. It must be approved through the incident/change authority before execution.

### Intune: stop further assignment to the Floor 6 ring

1. Go to `Intune admin center > Apps > All apps > [Document Manager - to confirm] > Properties > Assignments > Edit`.
2. Under **Required**, remove the Floor 6 deployment group `[Floor 6 Document Manager Ring - to confirm]`.
3. Select **Review + save** and then **Save**.
4. Verify at `Apps > All apps > [Document Manager] > Monitor > Device install status` that no additional Floor 6 devices are receiving the app.

Removing the assignment stops further required deployment. It does **not** remove the already installed app from affected devices.

### Intune: roll back affected devices

1. Confirm the approved prior version/package and its detection rule: `[Document Manager previous stable version - to confirm]`.
2. Deploy that approved package as **Required** to a new, incident-approved group containing only affected Floor 6 devices: `[Floor 6 Document Manager Rollback - to confirm]`.
3. If the current app must be removed first, configure the approved rollback package with Intune Win32 app **supersedence** to uninstall `[Document Manager current version - to confirm]`, or assign the current app's approved uninstall package to the rollback group.
4. Monitor `Apps > All apps > [rollback package] > Monitor > Device install status` and endpoint Intune Management Extension logs.

Do not use a local uninstall command unless the approved package owner has supplied and tested it. A generic command cannot be safely specified because the product code, uninstall command, and data-retention behavior are **to confirm**.

### Configuration Manager (SCCM): stop deployment to the Floor 6 ring

1. Open **Configuration Manager Console > Software Library > Application Management > Applications > [Document Manager - to confirm]**.
2. Open the existing deployment to `[Legal Floor 6 collection - to confirm]` and select **Delete**. Confirm removal of the deployment assignment only.
3. Verify under **Monitoring > Deployments** that the deployment is no longer targeted to the Floor 6 collection.

Deleting the deployment assignment stops future enforcement. It does **not** uninstall the application from devices that already received it.

### Configuration Manager (SCCM): roll back affected devices

1. Confirm the approved previous stable application/package and its uninstall/install commands: `[Document Manager previous stable version - to confirm]`.
2. Create or use the incident-approved affected-device collection `[Floor 6 Document Manager Rollback - to confirm]`.
3. Deploy the approved rollback application to that collection as **Required**, using a schedule and user-experience setting approved by incident command.
4. If removal of the current release is required, deploy the vendor-approved uninstall deployment type or use **supersedence** configured for the approved rollback application.
5. Monitor **Monitoring > Deployments**, then validate install state, sign-in duration, CPU/disk usage, and application errors on a small control set before expanding rollback.

## Floor Message

We are investigating the sign-in and performance issues affecting Floor 6 and have paused the recent Document Manager rollout while we work through the impact. Your files and access are not being changed by this action. Please restart only if the Service Desk asks you to. If you still cannot sign in, or your computer remains slow after signing in, contact the Service Desk and include your computer name and the time the issue occurred.