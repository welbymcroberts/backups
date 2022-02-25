# 3-2-1 rule
The 3-2-1 rule was written by [Peter Krogh](https://thedambook.com/about/) as part of their book on digital asset management (ISBN: 9780596100186). In this they state that 3-2-1 applies as 3 copies, 2 different media, 1 off site. In a modern cloud based world this doesnt translate as it would have in the early 2000's when this was written. It's commonly interpreted as Media meaning media types, for example LTO Tape and HDDs. This however could be intperted as a different media set. For example a different raid group.

My intepretation is as follows:

## 3 Copies
This means at least 3 copies of the data. This can include the original copy. As an example, a smartphones camera might have

* Local
* Apple iCloud / Google Photos
* Synology Photos

## 2 Media groups
This means that the data must exist on at least two different media groups. Using the above example again

* Local Flash on smartphone
* HDD at Cloud Provider
* HDD in Synology NAS RAID

## 1 Offsite
This should include at least one copy that is not within the same 'failure domain' as the original data. Intepreting the failure domain would depend on the data. For personal data, within a few miles should be 'safe'. ISO 22301, BS 259990-2 and NIST SP 800 and ISO 27xxx are, at time of writing, non specific regarding what a "safe distance" is.

Consider the problem domain. A Copy of the data should be retreivable should a disaster occur. The disaster is more likley to be related to component failure, water ingress, damage due to power fluxuations etc, rather than a larger disaster like a forest fire,  earthquake, sharknado, EMP or an atomic blast. If these are to be considered, it may be more prudent to up the numbers by 1, making this the 4-3-2-1 rule, where there is one copy kept on another continental shelf, or the other side of the country.

## [Optional] 1 Immutable
For critical data it is also worth considering that one copy is 'immutable' or offline. This can be achieved using Object Lock or similar functionality in a Cloud Based storage platform or by the use of Write Once media. LTO WORM (Write Once Read Many) tapes or Long Term DVD/Bluray are options for this. Another alternative is to have offline media, such as another raid set. Both WORM and offline media come with their own issues. WORM media will require a drive to read it, which may or may not be available in the future. A spare drive should also be kept with the media, however this has a caveat that the drive may require lubrication or replacement of rubber parts prior to use to recover data. Offline Drives fall into a simmilar category, as they may require regular 'spin ups' to stop the mechancial side of things seizeing. The same is true for SSDs which will have silent bit decay. [JEDEC](https://www.jedec.org/sites/default/files/Alvin_Cox%20%5BCompatibility%20Mode%5D_0.pdf) states 1 year @ 30C for consumer drives, 3 months @ 40C for Enterprise and as such should not be considered for longer term offline storage.

***

# Verification
:bangbang: **A backup does not exist until it has been verified as restorable.** :bangbang:

A scheduled task to do a test restore of a backup should be performed on a semi-regular interval. 

Schedules for backups can be seen on each individual device as per below, they can also be seen in [this document](verification.md)

An additional task should be to take a checksum of the data, allowing to check for bit rot (at least at a high level) for the backup.

***
# Software

Whilst there are a number of great backup software options, care must be taken when making longer term backups that the software will still be useable in the future. As a general rule and software that stores the data in an easily retrievable way, such as an exact copy of the file, or a 'standard' file format will be preferable over one which stores it in a proprietary or hard to access method.

For data which is in a propitiatory format as the source, it is preferable to follow the Library of Congress's [Recommended Formats](https://www.loc.gov/preservation/resources/rfs/TOC.html). Examples would be that paper documents could be backed up as a PDF/UA (ISO 14289-1) or PDF/A (ISO 19005), as these are formats that will likely have readability into the far future, due to their use by organisations like the LoC, but also due to their standard being an open standard.

A format such as Microsoft Word's DOC format may still be acceptable, however care has to be taken to ensure that future versions of the software, or alternative software, will be able to read the file and render it correctly.

Generally FOSS will be preferable over COTS due to the open nature of the software. This doesn't however mean that software will work in 20 years from now, however it is likely that the format will be well documented, and at worst case, could be reversed from the source code.

Examples could be:

* tar vs Veritas
Whilst Veritas is a supported COTS application, that likely will be readable in the future, the tar standard is moderately unchanged since its format standardisation in 1988 and refinement in 2001. Both formats are supported by modern tar compatible software.

* Zip vs RAR
RAR is a wonderful compression and container format like ZIP, however it is less well documented and supported compared to the ZIP format, it is also against the RAR liscence to create a utility that can read / write to RAR files. Due to this, despite potential higher storage requirements of ZIP, it is preferable to use the format which is supported by more software and is public domain. An argument could be made that the IETF standard of gzip, coupled with tar may infact be preferable to ZIP.

* Machine Backups
There are a number of options available for backing up machines. An open standard will be preferable, however the 'ease of backup and management' also has to be considered. Something like Borg, Restic etc may be great options for a platform like Linux, but from a usability perspective, it is less preferable to a built in solution like Mac OS's Time Machine. Another example may by Synology's Active Backup. This is not a great solution from readability of data, as it does require a significant amount of work to manually restore.

***
Per device or service backup strategies and restore instructions

## [Servers](/servers/README.md)
## [Networking](/networking/README.md)
## [IoT](/iot/README.md)
## [Cloud Services](/cloudservices/README.md)
