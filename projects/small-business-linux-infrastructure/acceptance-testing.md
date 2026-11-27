# Acceptance Testing

**Preliminary plan:** capstone acceptance criteria and tests have not yet been finalized or executed. These related guided-lab results can inform the planned tests.

| Area | Related lab result | Limitation |
| --- | --- | --- |
| Access | [User lab](../../ubuntu-server-lab/02-user-and-group-management/README.md) covers sudo access, denial, and group inheritance. | A fresh direct sudo attempt after revocation remains unverified. |
| Storage | [Storage lab](../../ubuntu-server-lab/03-storage-management/README.md) records a read/write test, a data mount verified after reboot, and active swap. | The swap-file warning is a non-blocking lab observation. Independent capstone storage has not been tested. |
| Service | [Service lab](../../ubuntu-server-lab/06-service-management/README.md) records an Nginx page request and service exercises. | Refer to the lab for the scope of each check. |
| Backup | [Automation lab](../../ubuntu-server-lab/scripts/README.md) covers checksum and restored-directory comparison. | Daily scheduled execution remains unverified. |

Future work: investigate the lab swap-file warning, record scheduled runs, and define and execute an independent capstone acceptance plan with explicit criteria.
