# Alpiner

This is an internal only tool to LSIO used for branching alpine images to a new alpine release.

Usage:

```
./alpiner.sh \
-ALPINE_VERSION=X.X \
-BUILD_ONLY=(true|false)
```

Flagging a BUILD_ONLY as true will not push your branches to github, only build them locally and give you the logs to review. It is highly reccomended to run this first before running false as you can review and deal with any basic failures before pushing them to github.

Before the branch is pushed a local smoke test will run and build the x86 variant. 

All docker output can be found in the dockerout directory. 

Success and fail logs will be written to the logs directory for review when the run is completed. 

Repos.config should be kept up to date with Alpine repos we manage and their maintained branches.
