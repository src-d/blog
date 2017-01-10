---
author: vadim
date: 2017-01-10
title: "Hercules and his labours (source code line burn down)"
draft: false
image: /post/hercules/rbtree.png
description: "src-d/hercules - incremental git blame on top of go-git - helps to analyse repositories. Is it hard for him?"
categories: ["science", "technical"]
---
When I was drowning in the sea of new information at [NIPS 2016](https://nips.cc/),
colleagues pointed me at the excellent blog post by Erik Bernhardsson:
[The half-life of code & the ship of Theseus](https://erikbern.com/2016/12/05/the-half-life-of-code.html).
It was very inspiring; Erik actually implemented something which was in my plans, too.
The idea is simple: see how many lines in the source code remain unchanged
over time. If you've not read that article yet, please do - I am moving further.

Problems
--------

The problem with the tool Erik used, [git-of-theseus](https://github.com/erikbern/git-of-theseus),
is that all the mainstream git libraries are not suitable for efficient
analysis we want. Particularly, we need `git blame` information at every
consecutive revision, and the only way to obtain it using those libraries is
to apparently execute `git blame` at every revision. Since `git blame` takes the
linear time O(N), N is the number of commits in the history, running it on all
the history takes the quadratic time O(N<sup>2</sup>). Alternatively, we could cache
the results from the previous `git blame` to reuse them during the next run,
effectively reducing the complexity back to the linear time.

Why speed matters to us? We would like to conduct that sort of analysis on
every repository in the world. Our data processing pipeline leverages
[src-d/go-git](https://github.com/src-d/go-git), our own Git client (and soon server)
implementation. We constantly harness the fruits from maintaining the special,
fine-tailored Git library in the production, and creating
[src-d/hercules](https://github.com/src-d/hercules) is just an example.

There is another problem with the tool related to the history itself. How do
you define the linear history in a Git repository? The taken approach seems
valid at first: we pick HEAD, go back to the parent, then go back again and
again until we reach the root commit. Sssh, here comes Mr. Merge:
```
      A---B---C topic
     /         \
D---E---F---G---H---I master
     ----------> time
 way <----------
```
Which direction shall we continue traversing the commit graph at H, to C or to G?
What about more complex cases, "polymerges" which are N>2 branches converging at
the single point? Mr. Merge laughs out loud and cries, "There is no right answer!".
"But wait, what about all the past, don't we know it?", you may ask.
"Let's pick all the commits belonging to `master` and sort them in time!"
You cannot. A branch in git is only a [pointer to some commit](https://git-scm.com/book/en/v1/Git-Branching-What-a-Branch-Is).
As time goes by, pointers move and we lose the previous states completely.
That is, according to how git works, there is no "master" branch in the past,
there is only `master` which exists at this very moment in the present. In other
words, git commits do not have branch associations except branch HEAD-s.
Luckily, we merge secondary branches to the major branches and not vice versa
in most sane git workflows, so the merge commit's first parent is **usually**
what we want. At the same time, execute `git help rev-list` and surprise how many ways
there are to extract the linear history.

Mr. Merge is not willing to leave us yet and points his dirty finger at
`git diff`, grinning. Indeed, `git diff` on a merge commit is not going
to show us the expected changes. Instead, it exclusively demonstrates how we solved
the conflicts during the merge; in the case of no conflicts, it is empty at all.
Now the funny thing, imagine the following situation: commit B changes line L and
commit G changes *the same line L exactly the same way*. The merge will treat
the lines equal and exclude them from the conflicts. Who is the L's author?
When was it changed? Mr. Merge laughs again and repeats his dreadful words,
"There is no right answer!"

If you are interested in `git diff` and `git blame` internals, please read the awesome
[presentation](https://drive.google.com/file/d/0B-w8jGUJto0iaWRjcFZUZy15NVU)
by Alberto Cortés, source{d}'s employee who implemented those functions in go-git.

For now, since there is no correct solution to the history problem, the only way
to deal with it is to support taking any commit sequence as input. As for the
diff problem, I treat secondary branches as if they appear at the merge time.
This is far from ideal but at least better than ignoring them completely.

Incremental blame
-----------------

Here "incremental blame" is different from `git blame --incremental`.
The former reduces the complexity of doing many sequential blames.
The latter streams the output in a machine readable format.

Let me remind you of [red-black trees](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree).
RB tree is the algorithm to maintain a balanced binary tree so that the
height variance is lower than 2x. Let's store our changed line intervals in
an RB tree with line numbers as keys:

![blame](/post/hercules/blame.png)
<p align="center">Random go-git blame...</p>

![rbtree](/post/hercules/rbtree.png)
<p align="center">...and the corresponding interval tree</p>

As can be seen, each line interval corresponding to the same commit is encoded by two
nodes, the beginning and the end, and the end node is in turn the beginning of
the next interval.

We start from the first element in the commit sequence aka "history root" and
iterate. We create the separate tree for every new file. Given the diff for every
commit, we maintain the RB tree structure efficiently. Every atomic edit in a file
is either an insertion or deletion of lines. Let's consider them separately.

#### Insertion

Suppose that we insert 2 new lines at position 314 which is in the middle of
`635c77e0` (brown, Alberto Cortés).

1. Insert new node A into the tree at 314 pointing to our commit.
   This leads to rebalancing the tree in O(log(N)) at worst.
2. Insert new node B into the tree at 314 + 2 = 316 pointing to `635c77e0`.
   Rebalancing the tree again.
3. For all the nodes greater than B, we add the same delta +2 to the key.
   *No need to rebalance the tree.* The complexity is O(N).
   
#### Deletion

Suppose that we delete 2 lines at position 314. For all the nodes greater than
`635c77e0` as 312, we add the same delta -2 to the key. *No need to rebalance the tree.*
The complexity is O(N).

Thus we've got the linear complexity for both operations. Still, let's look
at a typical commit on GitHub:

![commit](/post/hercules/commit.png)
<p align="center">[apache/spark@7026ee23](https://github.com/apache/spark/commit/7026ee23e0a684e13f9d7dfbb8f85e810106d022#diff-916ca56b663f178f302c265b7ef38499)</p>

Insertions and deletions are often coupled, and often their lengths are equal,
thus deltas neutralize and we do not have to update the subsequent keys at all,
getting O(log(N)), which is really O(1) amortized.

An alternative implementation would be using single-linked lists, where
each node carries the corresponding line interval length:

![list](/post/hercules/list.png)
<p align="center">Single-linked list, folded into a circle to fit</p>

That structure makes insertions and deletions constant time but seeking for
the right line number is always linear. In other words, disregarding our luck,
we always spend O(N) on updating a file.

The only way to choose the best data structure is to conduct real world
experiments, however, the blame performance itself is far from being the bottleneck
at this moment.

Bottlenecks
-----------

Our blame algorithm requires to have the diff on each of the changed files.
The funny thing is that extracting diffs at git "porcelain" level of
abstraction is literally impossible. Git stores each commit as a snapshot
of the repository, not a difference between adjacent revisions (refer to
[the book](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)). Thus
the only way to obtain a commit's diff is by fair diff-ing files, and this is 
what Hercules does currently.

Internally, git does store commits as "deltas" if it *considers worth it*.
`git blame` reuses those deltas as much as it can. "Leaky abstraction" diff
is yet to appear in go-git, there are certain plans to have it in the near
future, and it should dramatically speed up Hercules.

Diff-ing the file trees is another problem. Suppose that you've got two
snapshots of a deep directory with millions of files each. How to you decide
which files were changed, deleted or added? Without breaking the git abstraction,
the only way left is to do a linear scan over the whole tree which may take
ages to complete.

Internally, git assigns hashes to each directory based on it's contents.
We could eliminate traversing the majority of unchanged directories by
comparing the corresponding hashes. Again, "leaky abstraction" diff-tree
algorithm is not included into go-git, but Alberto will finish it soon.
It should speedup Hercules, too.

The last problem is how we work with the repository. Cgit, libgit2 and the rest
are designed to work with the file system in the first place, they cache everything
they can. go-git has *backends*, including the file system and fully in-memory storage.
If we load a git repository completely in memory, all operations will fly,
and it is the key point why Hercules still works pretty fast. If we use the current
file system backend which does not cache anything and we'll get 100x slowdown.
Analysing [git/git](https://github.com/git/git) in memory takes about 9 gigs,
and I am scared to play that trick with the Linux kernel.

Results
-------

The overall performance of Hercules compared to Theseus is about 6x better
on small repos and 20% better on large ones (like git/git). As for now,
it is mostly usable with moderately sized repos. The plots look pretty much
the same as they should.

The λ metric is going to be taken into account in one of our repositories
clustering schemes. Most likely, we will create several perks on top of it,
like clustering directories in a repository based on the local λ value or
finding weakly designed modules. Who knows?

![freeman](/post/hercules/freeman.jpg)
