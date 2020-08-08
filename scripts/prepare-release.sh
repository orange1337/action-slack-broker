#!/bin/bash -u

echo "::set-output name=skip::true"
git diff HEAD~..HEAD -- package-lock.json | grep -q '"version":'

if [ $? = 0 ]; then
  echo start release flow

  # setup git
  git config user.name "8398a7"
  git config user.email "8398a7@gmail.com"

  tag=$(git diff HEAD~..HEAD -- package-lock.json | grep version | tail -n 1 | cut -d'"' -f4)
  major=$(echo ${tag:0:1})
  tag=v$tag

  # release flow
  git checkout v$major
  git merge origin/master
  npm ci
  npm install
  npm run release
  git add -A
  git commit -m '[command] npm run release'
  git remote add github "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
  git push github v$major

  # push tag
  git tag $tag
  git push github --tags

  echo "::set-output name=skip::false"
  echo "::set-output name=tag::$tag"
fi