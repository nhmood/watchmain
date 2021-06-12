#!/bin/bash
# watchmain - domain registration checker
#
# nhmood @ goosecode
# june 12th, 2021


# note - this should be run after watchmain has been built
# run the watchmain domain checker and commit the updated domain files
./watchmain config/watchmain.yml

# add the updated domain json to the repo and commit (as watchmain[bot])
git add domains
git -c user.name="watchmain[bot]" -c user.email="watchmain@goosecode.com" commit -m "Domain Status Change - $(date +%m/%d/%Y)" --author="watchmain[bot] <watchmain@goosecode.com>"
git push
