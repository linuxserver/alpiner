#! /bin/bash
########################
#  Alpiner main logic  #
#    Linuxserver.io    #
########################

## Get CLI input
for i in "$@"
do
case $i in
  -ALPINE_VERSION=*)
  ALPINE_VERSION="${i#*=}"
  shift
  ;;
  -BUILD_ONLY=*)
  BUILD_ONLY="${i#*=}"
  shift
  ;;
esac
done

## Main loop
IFS=$'\n' 
for input in $(cat repos.config); do
  # Set variables for loops
  repo=$(echo $input | awk -F '=' '{print $1}')
  eval branches=$(echo $input | awk -F '=' '{print $2}')
  # Clone the repo using ssh endpoint
  git clone git@github.com:linuxserver/docker-${repo}.git
  cd docker-${repo}
  # Branch Loop
  for branch in ${branches[@]}; do
    git checkout -f ${branch}
    git checkout -b ${branch}-${ALPINE_VERSION}
    # Make sure we can checkout the new branch
    if [ "$?" = 0 ]; then
      # Replace alpine version with passed variable
      sed -ri "/^FROM lsiobase\/alpine.*/{s/:[0-9]\.[0-9]/:${ALPINE_VERSION}/}" Dockerfile*
      # Build local x86 variant
      echo "docker building ${repo}-${branch}-${ALPINE_VERSION}"
      docker build --no-cache -t ${repo}-${ALPINE_VERSION} . > ../dockerout/${repo}-${branch}-${ALPINE_VERSION}.txt
      # Make sure the build succeeded
      if [ "$?" = 0 ]; then
        echo "build succeeded for ${repo} on branch ${branch}"
        echo "build succeeded for ${repo} on branch ${branch}" >> ../logs/success.log
        if [ "${BUILD_ONLY}" = "true" ]; then
          echo "This is a build only run nothing will be pushed for ${repo} on ${branch}"
        else
          # Commit and push new branch
          git add Dockerfile*
          git commit -m "Rebasing to Alpine ${ALPINE_VERSION}"
          git push origin ${branch}-${ALPINE_VERSION}
        fi
      else
        echo "build failed for ${repo} on branch ${branch}"
        echo "build failed for ${repo} on branch ${branch}" >> ../logs/fail.log
      fi
    else
      echo "Unable to create new branch ${repo}-${ALPINE_VERSION} this branch has allready been pushed"
      echo "Unable to create new branch ${repo}-${ALPINE_VERSION} this branch has allready been pushed" >> ../logs/fail.log
    fi
  done
  # Purge local repo
  cd ..
  rm -Rf docker-${repo}
done
