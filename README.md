# watchmain 🦉

watchmain is a set of domain helpers that run with the help of various GitHub offerings.  
The tool consists of two main components
- Porkbun Explorer: web ui to search/filter on domains available on [porkbun](https://porkbun.com)
- Domain Checker: domain status checker that emails you on any registration change

The great thing about watchmain is that it runs entirely with the help of GitHub Pages and GitHub Actions!  
No need to setup any infrastructure, just fork the repo and update some configs and you'll be ready to go!

## Installation / Usage

## 1. Fork It
Fork the watchmain repository (<https://github.com/nhmood/watchmain/fork>)

## 2. Sign up for Mailgun and WhoisXMLAPI
watchmain currently relies on [WhoisXMLAPI](https://whois.whoisxmlapi.com/) to track domain registration changes and [Mailgun](http://mailgun.com/) to send those updates to your inbox.  
Both of these services have free tiers and, for regular watchmain usage, should be sufficient for continous monitoring at no cost. 


## 3. Update the Configuration
### watchmain.yml
Update the [watchmain.yml](https://github.com/nhmood/watchmain/blob/main/config/watchmain.yml) configuration file.  
If you plan on running these tools with GitHub actions you can leave the Mailgun and WhoisXMLAPI keys blank, they will be sourced from ENV secrets.  
watchmain can also be run locally, so the API keys can be put into a config file for convenience.   

Your Mailgun config should reflect the domain you used to setup your Mailgun account.

```
mailgun:
  api_key: "" # LEAVE BLANK IF USING GITHUB ACTIONS / ENV SECRETS
  domain: "mg.yourdomain.com"
  from: "watchmain@yourdomain.com"
  to:
    - "you@yourdomain.com"


whois:
  api_key: "" # LEAVE BLANK IF USING GITHUB ACTIONS / ENV SECRETS


domains:
  - "domainyoureallywant.com"
```

### GitHub Pages
In order to provide the Porkbun Domain explorer, you'll need to enable GitHub Pages and point it to the `docs/` directory.  
Go to the settings for the repo, select the Pages option, and point the path to `docs/`.  
**NOTE - GitHub Pages are only available if the repo is public for free accounts**

### GitHub Action Workflows
By default, the GitHub Actions for checking the domain status [CheckDomainRegistration](https://github.com/nhmood/watchmain/blob/main/.github/workflows/check_domains.yml) and updating the Porkbun domain list [UpdatePorkbunDomains](https://github.com/nhmood/watchmain/blob/main/.github/workflows/update_domains.yml) are _not_ set to run automatically - this is to prevent accidental forks and wasted GitHub Action minutes.

To enable automatic running in GitHub Actions - simply uncomment the `schedule` block and configure the cron syntax for when you want the tasks to run.  
You can reference the [GitHub Actions Scheduling](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events) docs for the proper syntax.  
We recommend the defaults of every day for the CheckDomainRegistration action and once a week for the UpdatePorkbunDomains action.

```
name: Check Domain Registration
on:
# UNCOMMENT THESE LINES TO ENABLE AUTOMATIC RUNS
#  schedule:
#    # 9am est
#    - cron: "0 13 * * *"
  workflow_dispatch:

```

# 4. Manually Run Actions
To validate that everything is configured properly - you can manually execute the action with the configured `workflow_dispatch` event trigger.  
Just navigate over to the Actions tab, select the workflow you want to test, and click the `Run workflow` button.

You should be able to see the full run and updated status. If this is the first time running you'll see that watchmain has committed updated domain status / porkbun domain data directly into the repo!




# Implementation Details
Both the Porkbun Domain Explorer as well as the Domain Status Check rely on GitHub Actions building and running the scraper/checkers, generating the associated status files, and committing that data back into the repository to store state between runs.  


## Porkbun Explorer
The Porkbun Explorer is simply a [scraper](https://github.com/nhmood/watchmain/blob/main/src/porkbun.cr) for [porkbun](https://porkbun.com) that stores the data in a easy to use JSON file.  
The scraper generates the JSON file and commits it back into the `docs/data/domains.json` which is then pulled down by the static GitHub Page site running out of `docs/`. The frontend is incredibly simple and just uses vanilla, suboptimal, handrolled Javascript.


## Domain Status Checker
The Domain Status Checker utilizes WhoisXMLAPI to get the latest whois data on the specified domains.  
It stores and compares the Base64 MD5 hash between runs to determine whether the data has changed.  
If a change is detected, it generates a (basic) diff between the payloads and sends an email using [Mailgun](http://mailgun.com/)
