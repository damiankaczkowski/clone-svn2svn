# clone-svn2svn.sh
## Description

The script clones an SVN repository to a remote SVN site retaining all history of the original repository.
It uses git-svn to perform its task. The current directory is used as temporary storage.
You can delete all files if you do not need to synchronise the repositories later.

## Usage

```
clone-svn2svn.sh [option...] <source_repo_url> <destination_repo_url>
```

## Options

*--src-revision*  revision range in the source repo

*--dst-revision*  revision range in the destination repo

This allows revision ranges for partial/cauterized history to be supported.
$NUMBER, $NUMBER1:$NUMBER2 (numeric ranges), $NUMBER:HEAD, and BASE:$NUMBER
are all supported. See git svn --revision option for more details.

## Example

```
clone-svn2svn.sh --src-revision 6:HEAD --dst-revision 52:HEAD svn://hexahon/project-swordfish svn://community/project-swordfish
```

## Update Cloned Repository from Source Repository

If more changes were made in the source SVN repository after it was cloned, we can transfer those changes with the following steps.

* Checkout the branch corresponding to the source repository

```
git checkout master
```
	
* Pull latest changes from the source SVN

```
git svn rebase
```

* Rebase the recent changes onto the destination

```
git rebase local-dst src-git-svn
```

* Move local-dst to the HEAD
	
```
git rebase HEAD local-dst
```
	
* Commit to the destination SVN

```
git svn dcommit -Rdst --add-author-from
```
