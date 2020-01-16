#!/bin/bash
set -ex
set -o pipefail

curl --silent --show-error https://www.hex-rays.com/updida.shtml | python -c "import re, sys; sys.stdout.write(re.search(r'(?s)(?<=<center>\n      ).*(?=    </center>)', sys.stdin.read()).group().replace('<br>', '').replace('\n ', ''))" >version.txt

if [ -n "$(git status --porcelain)" ]; then
    pip3 install -r .github/requirements.txt
    cat version.txt | TO=ida-update@googlegroups.com SUBJECT='new version of IDA Pro is available' .github/gmail.py
    git config --global user.name 'GitHub Actions'
    git config --global user.email "$(whoami)@$(hostname --fqdn)"
    git add --all
    git commit --all --message 'IDA updated'
    git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" HEAD:master
fi
