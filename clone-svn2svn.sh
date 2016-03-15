#!/bin/bash

set -e

USAGE="USAGE: clone-svn2svn.sh [option...] <source_repo_url> <destination_repo_url>\n\n\
DESCRIPTION:\n\n\
The script clones an SVN repository to a remote SVN site retaining all history of the original repository.\n\
It uses git-svn to perform its task. The current directory is used as temporary storage.\n\
You can delete all files if you do not need to syncronise the repositories later. \n\
\n\
OPTIONS:\n\n\
--src-revision\trevision in the source repo\n\n\
--dst-revision\trevision in the destination repo\n\n\
This allows revision ranges for partial/cauterized history to be supported. \n\
\$NUMBER, \$NUMBER1:\$NUMBER2 (numeric ranges), \$NUMBER:HEAD, and BASE:\$NUMBER \n\
are all supported. See git svn --revision option for more details.\n\
\n\
https://github.com/evpo/clone-svn2svn"

if [[ $# > 6 ]] || [[ $# < 2 ]]
then
    echo -e $USAGE
    exit -1
fi

if [ -d .git ]
then
    echo "SVN2SVN: git repository already exists"
    exit -1
fi

while [[ $# > 2 ]]
do
key="$1"

case $key in
    --src-revision)
    SRC_REV="$2"
    shift # past argument
    ;;
    --dst-revision)
    DST_REV="$2"
    shift # past argument
    ;;
    *)
    # unknown option
    echo Invalid parameter: $key >&2
    echo -e $USAGE
    exit -1
    ;;
esac
shift # past argument or value
done

if [[ ! "$SRC_REV" = "" ]]
then
    SRC_REV=" --revision=$SRC_REV"
fi

if [[ ! "$DST_REV" = "" ]]
then
    DST_REV=" --revision=$DST_REV"
fi

echo "SVN2SVN: Clone source repository"
git svn clone -Rsrc${SRC_REV} --prefix="src-" $1 ./

echo "SVN2SVN: Clone destination repository"
git svn clone -Rdst${DST_REV} --prefix="dst-" $2 ./

#create a local branch for the destination repository
git checkout -b local-dst remotes/dst-git-svn

#rebase all changes from source repo onto local-dst
#This will rebase commits from src svn but the last commit will not have a branch
echo "SVN2SVN: Rebase all changes from source repo onto local destination repo"
git rebase --onto local-dst --root remotes/src-git-svn

#Fast-forward local-dst branch to HEAD
git rebase HEAD local-dst

echo "SVN2SVN: Commit to destination repo"
git svn dcommit -Rdst --add-author-from

#add-author-from will add a line to each commit message with the email of the original author in the source svn. 
#You can still see who made changes.
