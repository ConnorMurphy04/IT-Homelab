# Backup Verification Procedure

Use this to check that Ridgeline's data can actually be recovered, not just that backups are running. Record every test in the log at the bottom, including the ones that fail.

Owner: IT Specialist
Last reviewed: November 2026

## Weekly

- Open Backup and Restore on each laptop that has a local backup (or check the backup report, if one is set up) and confirm the last backup ran on schedule.
- If a backup missed its scheduled run, find out why the same week. A backup that quietly stopped running months ago is the most common way to find out you have no backup.

## Monthly

- Restore one folder from a laptop backup to its original location. Delete it first so the test is real.
- Before deleting anything, browse the backup and confirm the folder is in it.
- After the restore, check file sizes in Properties, not just that the files open.
- Restore an earlier version of one OneDrive or SharePoint file.
- Time each restore and record it in the log.

## Quarterly

- Delete and restore a test user in the Microsoft 365 admin center. Deleted users can be restored for 30 days.
- Recover a deleted email from Recoverable Items.
- Review what's being backed up. New folders, new laptops, and new jobsites don't get added to a backup on their own.

## Things to know

- Restoring a deleted Microsoft 365 user resets their password. Plan to give the employee a new one.
- Restoring files on a managed laptop needs admin rights, so employees can't do it themselves. They need to open a ticket.
- Admin roles in Microsoft 365 don't make an account a local admin on laptops. IT accounts need the Microsoft Entra Joined Device Local Administrator role for that.
- Windows 11 Notepad keeps unsaved text between sessions. A file can look full in Notepad and still be empty on disk.

## Verification log

| Date | System | Test | Result | Time to restore | Initials |
| --- | --- | --- | --- | --- | --- |
| 2026-11-10 | Microsoft 365 admin center | Delete and restore a test user | Passed. User restored, password reset by the restore. | Not timed | CM |
| 2026-11-10 | OneDrive | Restore an earlier file version | Passed. Document went back from Version 3 to Version 1. | Not timed | CM |
| 2026-11-10 | Laptop, Backup and Restore to E: | Delete the ProjectFiles folder and restore it | Passed. Folder and files restored to the original location. One file was 0 bytes because the text was never saved to disk before the backup. | About 10 minutes | CM |
| | Exchange Online | Recover a deleted email | Not tested yet | | |
