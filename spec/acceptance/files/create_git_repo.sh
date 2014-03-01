#!/bin/bash
mkdir /tmp/testrepo
cd /tmp/testrepo

touch file1.txt file2.txt file3.txt
git init
echo 'change 1' > file1.txt
git add file1.txt
git commit -m 'add file1'
echo 'change 2' > file2.txt
git add file2.txt
git tag 0.0.2
git commit -m 'add file2'
echo 'change 3' > file3.txt
git add file3.txt
git commit -m 'add file3'
git tag 0.0.3

git checkout -b a_branch
echo 'change 4' > file4.txt
git add file4.txt
git commit -m 'add file4'
echo 'change 5' > file5.txt
git add file5.txt
git commit -m 'add file5'
echo 'change 6' > file6.txt
git add file6.txt
git commit -m 'add file6'

git checkout master

git --git-dir=/tmp/testrepo/.git config core.bare true
cp -r /tmp/testrepo/.git /tmp/testrepo.git
rm -rf /tmp/testrepo
