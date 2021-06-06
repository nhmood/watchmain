#!/bin/bash
# watchmain - porkbun domain updater
#
# nhmood @ goosecode
# june 5th, 2021


# note - this should be run after porkbun has been built
# run the porkbun updater and store results in docs path
./porkbun docs/data/domains.json

# add the updated domain json to the repo and commit (as watchmain[bot])
git add docs/data/domains.json
git -c user.name="watchmain[bot]" -c user.email="watchmain@goosecode.com" commit -m "Porkbun Domain Change - $(date +%m/%d/%Y)" --author="watchmain[bot] <watchmain@goosecode.com>"
git push
