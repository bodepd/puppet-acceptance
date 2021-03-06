#!/bin/bash
#
# author: Dan Bode
#
# tests that puppet yum provider can downgrade packages.
#
set -e
set -u

source lib/setup.sh
if ! which rpm ; then NOT_APPLICABLE ; fi

PACKAGE='spectest'
# we have to include the build number of puppet fails, YUCK!
OLD_VERSION='1.1-1'
VERSION='1.0-1'

# precondition
if rpm -q $PACKAGE; then
  rpm -ef $PACKAGE
fi
yum install -d 0 -e 0 -y $PACKAGE-$OLD_VERSION

# run ralsh
$BIN/puppet resource package $PACKAGE ensure=$VERSION | tee $OUTFILE

grep "ensure changed '${OLD_VERSION}' to '${VERSION}'" $OUTFILE
# postcondition
# package should have been downgraded.
[ `rpm -q $PACKAGE` == "${PACKAGE}-${VERSION}" ] 
