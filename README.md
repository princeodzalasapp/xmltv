# TV guides - XMLTV

This repository keeps XMLTV TV guides up to date in order to be used with the Live TV "PVR IPTV Simple Client/Catch-up TV & More" combo.

## Developers notes

The `update_all_tv_guides.sh` can be used to automatically update TV guides files (`xxxxx.xml` files).
The script automatically create a commit with the latest TV guides and it will push the modification on this GitHub repository.
This script is executed every night with a cron task but you can trigger it manually on your own computer.


