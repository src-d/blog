---
author: alcortesm
date: 2017-03-21
title: "Comparing Git trees in Go"
draft: false
image: /post/difftree/intro.jpg
description: "If you use Git, you probably compare commits on a daily basis.
This blog post explains the data structures and algorithms involved in such
task, in an intuitive way.  After reading this blog post you will have
a nice understanding of how to use prefix trees and Merkle trees and a good
intuition of how to solve similar problems whenever they come up."
categories: ["git", "technical"]
---

<style>
p.dt {
  margin-top: -16px;
  font-style: italic;
}
</style>

![Front image](/post/difftree/intro.jpg "Old Trees, copyright (c) 2015 by Moises Levy, http://www.moiseslevy.com/Old%20Trees")

## Introduction

Do you know how Git identifies what files have changed between two commits?

It is a fairly common operation you probably do every day when you review
pull requests, when you check staged files... It involves prefix trees and
Merkle trees and many comparisons.

In this blog post I will walk you through every step in the process in an
intuitive way; I will skip some of the hairy details so I can focus on the main
problems and solutions, and present them in a clear and understandable way.

This blog post was inspired by my work on
[go-git](http://github.com/src-d/go-git), which in turn was inspired by
[Git](https://git-scm.com/) itself and [libgit2](https://libgit2.github.com/).

I will use snippets of Go code here and there to illustrate some concepts, they
all are simplified versions of the real Go code we use in go-git.

## Git trees

Whenever you make a Git commit, you save a snapshot of your project into
your repository, that is, Git remembers the state of all the files you have
staged and stores all that information in a tree structure inside the
commit.

This tree structure is composed of nodes that represent your files and
directories.  I call this kind of tree a `MerkleTrie`, as it has properties of
both prefix trees (tries) and Merkle trees, let us get into the details!

### Git trees as tries

In a Git tree every node has a **name**, which is the filename portion of the
path to the file or directory it represents, as in the figure below:

!["An example of a Git tree with some names in their nodes."](/post/difftree/names.png "A typical Git tree, with some files and directories. The names of the nodes are shown between double quotes.")
<p align="center" class="dt">An example of a Git tree with some names in their nodes.</p>

The practical implications of this are:

- The root has the empty string as its name.

- The name of a node is not its full path, and does not provide enough
  information to know where the node is located in the tree.

- The path of a node is the list of its ancestors, starting from the root and
  ending with the node itself. For example, the path to `lib/lib.go` will be
  the list of nodes containing the root node, `lib` and finally `lib.go`
  itself.

- The children of each node can be lexicographically sorted by their name:
  `LICENSE` comes before `lib`, `lib` comes before
  `main.go`.  Similarly, `lib.go` always comes before `lib_test.go`.

- The depth-first traversal of a tree which visit nodes in the same directory in
  lexicographic order enumerates them the same way as the `tree` command line tool:

  ```text
  LICENSE
  lib
  lib/lib.go
  lib/lib_test.go
  main.go
  ```

### Git trees as Merkle trees

Every node has a SHA-1 hash in a Git tree:

- The hash of a file is calculated from its size and contents.

- The hash of a directory is calculated from the
  [mode](https://en.wikipedia.org/wiki/Modes_(Unix)), name and hash of its
  children, in lexicographic order.

If we add the hash information belonging to each node, in blue, to the previous figure, we
get a more detailed view of the tree:

!["An example of a Git tree with some names and hashes in their
nodes."](/post/difftree/hashes.png "A typical Git tree, with some files and directories. The names of the nodes are shown between double quotes, the first bytes of their hashes are shown in blue.")
<p align="center" class="dt">An example of a Git tree with some names and hashes in their
nodes.</p>

This means Git trees are [Merkle
trees](https://en.wikipedia.org/wiki/Merkle_tree), the practical implications
for us are:

- *Files with different contents have different hashes*.  This means it is
  pretty fast to find out if a file has changed between two commits, as you only
  need to compare their hashes, not their contents.

- *Two files with the same content have the same hash*, no matter if they
  have different names and/or permissions.  If you index contents by hash, you
  only need to store it once, no matter how many times it appear
  in the history of the repository.

- *If two directories have the same hash, then they have the same children*:
  same files and directories with recursively the same names, modes and
  contents.

  This is a huge time saver for comparing directories between commits, because
  if their hashes match, you know they have not been modified; there is no
  need to check their children individually.

  Consequently, the worst case algorithmic complexity of checking two
  directories for equality is reduced from O(n) to O(1) (with n being the
  number of descendants of the directory with less descendants).

- If some change has been introduced in a commit, no matter how small it is, all the
  ancestor directories of the modified file will have their hashes modified.

Let us assume, for the sake of this blog post, that hash collisions are
impossible, even though they are quite popular
[nowadays](https://shattered.io/static/shattered.pdf)).

# Representing Git trees programmatically

In line with what we have explained so far, this is a sensible representation of
Git trees in Go:

```go
type Noder interface {
        Name()     string
        Hash()     []byte
        Children() []Noder
}
```

The path to a node in a tree will look something like this:

```go
type Path []Noder // beginning from the root
                  // and ending with the node itself
```

I recommend `Path` to implement `Noder` so that you can treat paths as
nodes when needed:

```go
// assuming the receiver is not the empty slice…
func (p Path) last() Noder       { return p[len(p)-1] }
func (p Path) Name() string      { return p.last().Name() }
func (p Path) Hash() []byte      { return p.last().Hash() }
func (p Path) Children() []Noder { return p.last().Children() }
```

# Representing changes in Git trees

Let A and B be two Git trees from consecutive commits.  If we compare one with
the other there are going to be quite a few changes we have to deal
with, let us see a minimal set (changes depicted in red):

- **Modified file**: Both trees have the same topology, but the hash of the
  file is different from A to B, along with the hash of all its ancestors, as
  illustrated in the figure below:

!["The index contents before and after lib/lib.go is modified](/post/difftree/modified.png "The index before and after lib/lib.go is modified, changed hashes are shown in red.")

- **Renamed file** (the name of the file has changed, but it has not been moved
  to a different directory): Both trees have the same topology and the hash
  of the file is the same in A and B, but the hash of its ancestors is different in each tree.

!["The index contents before and after lib/lib.go is renamed to lib/foo.go](/post/difftree/renamed.png "Renamed file.")

- **Inserted file**: The topology of A and B is different, the
  parent directory of the file has a new entry in B and the hash of all
  its ancestors changes.

!["The index contents before and after lib/foo.go is inserted](/post/difftree/inserted.png "Inserted file.")

- **Deleted file**: The topology of A and B is different, the
  parent directory of the file has a missing entry in B and the hash of
  all its ancestors changes.

!["The index contents before and after lib/lib.go has been deleted](/post/difftree/deleted.png "Deleted file.")

In general, if we compare two Git trees we are likely to face several occurrences of the
cases above, and maybe even some composite cases, like moving a file to another
directory or replacing a file with an empty directory with the same name.

The output of our tree comparator will be a list of changes, that applied to the
A tree will turn it into the B tree.  A change in this context is defined as an
action and the involved paths. We can represent them as follows in Go:

```go
type Action int

const (
  Insert Action = iota
  Delete
  Modify
)

type Change struct {
  Action Action
  From   Path // to the modified node in A or nil if Action is Insert
  To     Path // to the modified node in B or nil if Action is Delete
}
```

Here are some examples of how to represent a few popular kinds of changes
between two trees:

- Inserting a `lib/foo.go` file will be represented as a single insertion
  action, from `nil` to the path of the new file:

  ```go
  fooDotGo := ...  // the node for the 'foo.go' file
  lib := ...       // the node for B's 'lib' directory (contains the new fooDotGo)
  root := ...      // the root node (contains lib)
  
  insertion := Change{
          Action: Insert,
          To:   Path{root, lib, fooDotGo}
  }
  
  changes := []Change{insertion}
  ```

- A modification of the contents of `lib/lib.go` is represented as
  the single change too, from A's `lib/lib.go` to B's `lib/lib.go`:

  ```go
  libDotGoA := ...  // A's 'lib.go' file
  libA := ...       // A's 'lib' directory
  rootA := ...      // A's root node
  
  libDotGoB := ...  // B's 'lib.go' file (different hash than libDotGoA)
  libB := ...       // B's 'lib' directory (different hash than libA)
  rootB := ...      // B's root node (different hash than rootA)
  
  modification := Change{
          Action: Modify,
          From: Path{rootA, libA, libDotGoA}
          To:   Path{rootB, libB, libDotGoB}
  }
  
  changes := []Change{modification}
  ```

- Renaming `lib/lib.go` to `lib/foo.go` needs two changes:
  deleting A's `lib/lib.go` and inserting B's `lib/foo.go`.

  ```go
  libDotGo := ... // A's 'lib.go' file
  libA := ...     // A's 'lib' directory
  rootA := ...    // A's root node
  
  fooDotGo := ... // B's 'foo.go' file
  libB := ...     // B's 'lib' directory (different hash and children than libA)
  rootB := ...    // B's root node (different hash than rootA)
  
  deletion := Change{
          Action: Delete,
          From: Path{rootA, libA, libDotGo},
  }
  insertion := Change{
          Action: Insert,
          To: Path{rootB, libB, fooDotGo}
  }
  
  changes := []Change{deletion, insertion} // in any order
  ```

  Alternatively, you can also have your own `Rename Action` and report this as
  the single change from the old path to the new path, but that complicates the
  tree comparison algorithm (described in the next section). In any case, it
  must be pretty easy to detect renames and copies in a later step simply by
  processing the original output.

Now that we know how to represent changes between two trees, we can already
write down the signature of our difftree function:

```go
func DiffTree(a, b Noder) []Change
```

That is, the `DiffTree` function takes two trees indicated by their roots, compares
them and returns the collection of changes needed to turn one into the other.


# An intuitive overview of the difftree algorithm 

Detecting insertions and deletions can be implemented by simultaneously walking
both trees using the lexicographic depth-first traversal and comparing the paths
of the returned nodes. The algorithm can be nicely summarized with the following
animation that shows how to detect the insertion of `lib/foo.go`.

<!--
convert -size 238x98 -background white -antialias -density 192 -delay 250 -loop
0 -dispose previous walk1-*.svg walk1.gif
-->

![Simultaneously walking both trees.](/post/difftree/walk1.gif "Simultaneously walking both trees, looking for insertions or deletions.")
<p align="center" class="dt">Simultaneously walking both trees.</p>

If both walkers are on the same path, the element is neither inserted nor
deleted and we can advance both walkers to their respective next nodes. We
still need to compare the hashes of both paths though, just in case the
contents have changed; if the hashes differ, the modification change
from the old path to the new one is issued.

If the walkers are pointing to different paths then either the old path was
deleted or the new one inserted, depending on which one comes first in
the lexicographic depth-first sorting.

I suggest adding the `Compare` method to the `Path` type
to find out which path comes first. That method returns whether the path comes
before or after another under the particular sorting policy.

This path comparison deserves some careful planning since the naive comparison
of string representations of both paths would return wrong results in some corner
cases. For instance `a/z.go` should come before `a.go` but the former is
greater than the latter when they are compared as simple strings.  The proper way
to compare paths is to compare ancestor names between them, making one step at
a time:

```go

// Compare returns -1, 0 or 1 if the path p comes before, at the same time or
// after the path o, in lexicographic depth-first order; for example:
//
// "a" < "b"
// "a/b/c/d/z" < "b"
// "a/b" < "a/b/a"
// "a/a.go" < "a.go"
func (p Path) Compare(o Path) int {
        for i := 0; ; i++ {
                switch {
                // there are no more elements in any of the paths
                case len(o) == len(p) && i == len(p):
                        return 0
                // there are no more elements in o
                case i == len(o):
                        return 1
                // there are no more elements in p
                case i == len(p):
                        return -1
                // both paths still have elements, compare the ith one
                default:
                        cmp := strings.Compare(p[i].Name(), o[i].Name())
                        if cmp != 0 {
                                return cmp
                        }
                }
        }
}
```

# The recipe so far

The algorithm described above can be summarized as:

1. Start traversing both trees at the same time.

2. While there are nodes left to visit in both trees:

  Compare the names and/or hashes of the elements pointed to by both paths and
  decide:

  - What changes must be issued, if any.

  - How to advance the walkers: the first, the second or both.

3. Issue changes to delete the remaining nodes from A or to insert the
   remaining nodes from B.

Implementing this algorithm involves writing:

- A tree iterator that traverses trees in lexicographic depth-first order,
  returning the path to the nodes.

- A comparator that takes the name and hash of the current paths of two tree
  iterators and tells us what changes we should issue and how to advance the
  iterators further.

Let us see how to implement each of them.

# The tree iterator

This would be a regular depth-first tree iterator if it were not for some
interesting details: 

- siblings are to be iterated in lexicographic order by name.

- it must be possible to skip whole directories instead of penetrating deeper
  into them.  This is important for efficiency reasons, when the hashes of two
  directories are the same, we would like to skip all their contents.

Taking those into account, the iterator type will look something like this:

```go
type Iterator interface {
        Next() Path // skips directory contents
        Step() Path // descends into directories
}
```

Both `Next` and `Step` methods return the path of the next node in the tree,
but each of them traverses the tree using a different policy:

- `Next` returns the next path without getting any deeper into the tree, that is,
  if the current node is a directory, its contents are skipped.

- `Step` returns the path to the next node, getting into directories if needed.

I have chosen the names for `Next` and `Step` in honour of the
[gdb](https://www.gnu.org/software/gdb/) commands.

Here is how I recommend to implement such an iterator:

- The path to the current node should be represented by the stack of frames,
  the root frame being at the bottom and the frame with the current node being
  at the top.

- Each frame is a stack of siblings sorted in the reverse
  lexicographic order by name so that the "smallest" node is at the top.

- This means the current node is the top node of the top frame.

- `Next` drops the current node and sets its next sibling to the new current
  node by popping the top frame. If the top frame ends up empty, just repeat the
  same operation recursively to remove all empty frames as we climb the tree
  towards its root.

- `Step` behaves just like `Next` for files, but for directories is quite different:
  it pushes a new frame with the children of the directory.

The following animation shows the series of `Next` and `Step` method calls over
a tree along with the states of the main stack and its frames.

<!-- convert -size 294x240 -antialias -density 192 -delay 250 -loop 0 -dispose previous iter-0[1-4].svg iter-06.svg iter-08.svg iter-09.svg iter-10.svg -delay 400 iter-11.svg iter-12.svg -delay 300 iter-1[3-9].svg iter.gif -->
![Iteration demonstration](/post/difftree/iter.gif "Iteration demostration")
<p align="center" class="dt">Git tree traversal demonstration.</p>


# The path comparator

![An unmodified file.](/post/difftree/walk1-02.png "Both paths point to the same unmodified file.")
<p align="center" class="dt">An unmodified file.</p>

The path in both trees have the same name and hash in the figure above, because
they represent the same unchanged file. No change has to be issued and we
can proceed with both iterators to the next comparison.

If they were directories instead of files, we would still want to advance both
iterators but skip their contents to save some time.

![An inserted file.](/post/difftree/walk1-05.png "A's path is "bigger" than B's path.")
<p align="center" class="dt">An inserted file.</p>

In the case of an inserted file like the one in the figure above, the name of
the paths will be different. The path of the A tree iterator points
to `lib/lib.go` and B's iterator points to `lib/foo.go`.

As A's path is "bigger" than B's path (comes later in the lexicographic
depth-first sort), we know that B's path was inserted, otherwise A's
iterator would have already reached a similar file. This means we need to issue
the insertion and advance the B's iterator while keeping A's iterator intact,
since the fate of `lib/lib.go` has not been decided yet.

If we keep doing this for all the possible cases we end up having the following
table, with `a` and `b` being the current paths of the iterators and `iterA` and
`iterB` being the iterators themselves:

| Description | Check                                                                            |        Actions         |            Movements           |
|:----:|:-------------------------------------------------------------------------------------:|:----------------------:|:------------------------------:|
| inserted <br> file or dir           | a.Name() > b.Name()                                                                      | insert b recursively   |          iterB.Next()          |
| deleted <br> file or dir            | a.Name() < b.Name()                                                                      | delete a recursively   |          iterA.Next()          |
| same <br> file or dir               | same name <br> && <br> same hash                                                         | nothing                | iterA.Next() <br> iterB.Next() |
| modified file                       | same name <br> && <br> different hash <br> && <br> both are files                        | modify a into b        | iterA.Next() <br> iterB.Next() |
| deleted a file <br> and created a dir <br> with the same name <br> or vice versa | same name <br> && <br> different hash <br> && <br> one is file <br> the other is dir  | delete a (recursively) <br> insert b (recursively)| iterA.Next() <br> iterB.Next() |
| add contents to <br> an empty dir   | same name <br> && <br> different hash <br> && <br> both are dirs <br> && <br> a is empty | insert b recursively   | iterA.Next() <br> iterB.Next() |
| deleted all contents <br> form a dir | same name <br> && <br> different hash <br> && <br> both are dirs <br> && <br> b is empty | delete a recursively   | iterA.Next() <br> iterB.Next() |
| changed the children <br> of a dir   | same name <br> && <br> different hash <br> && <br> both are dirs<br>&&<br>none is empty  | nothing                | iterA.Step() <br> iterB.Step() |

Here I wrote down all the possible combinations of nodes and
situations you may encounter in paths comparisons and carefully arranged the
combinations with similar outcomes in groups so they can be straightforwardly
detected with simple checks in your code.

# Conclusion

Comparing Git trees becomes an easy task once you split it into the
comfortably small pieces.

Even if you don't plan to implement your own version of Git, I hope that
understanding the challenges and the proposed solutions at a conceptual level
will help you solve similar problems in the future.

**P.S.** The trees in the photo are oaks at Dixie Plantation, South Carolina,
USA.  The photo is called "[Old Trees](http://www.moiseslevy.com/Old%20Trees)"
copyright (c) 2015 by Moises Levy.

**P.P.S.** Thanks to my reviewers, Miguel Molina and Vadim Markovtsev for their
suggestions, proper English and clean code; the broken English and the
convoluted code is all mine.
