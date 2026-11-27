# Troubleshooting

**Planned capstone:** no independent capstone troubleshooting has been recorded. The following issues arose in the existing guided labs and may inform future work.

- [Storage](../../ubuntu-server-lab/03-storage-management/README.md): a malformed `fstab` line caused a parse error that remained after a systemd reload. A later lab follow-up reported zero parse errors, verified the data mount after reboot, and confirmed active swap. The swap-file warning is a non-blocking observation.
- [SSH](../../ubuntu-server-lab/05-ssh-and-remote-access/README.md): the lab records an incorrect key-generation environment and the subsequent investigation.
- [Service management](../../ubuntu-server-lab/06-service-management/README.md): the exercise records a service failure and recovery.
- [Monitoring](../../ubuntu-server-lab/09-monitoring-and-troubleshooting/README.md): a mistyped page path returned 404; a later request to the correct path returned HTTP 200.
- [Automation](../../ubuntu-server-lab/scripts/README.md): the backup restore comparison initially used an incorrect variable reference; the corrected comparison returned zero.

The linked reports retain the full context and evidence. Future improvements include documenting follow-up checks and any changes made to resolve outstanding issues.
