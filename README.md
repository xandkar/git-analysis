git-anal
========

An exploratory analysis of a Git repository.


Examples
--------
Compare punchcards of top 2 committers to OCaml repository:
```shell
$ git clone https://github.com/ocaml/ocaml.git
$ cd ocaml
$ git-anal-punchcard.R 2 && open punchcard.png
```
![OCaml](https://raw.github.com/ibnfirnas/git-anal/master/examples/ocaml-punchcard-top-2.png)

Compare punchcards, with diff proportions, of top 4 committers to erlcloud
repository:
```shell
$ git clone https://github.com/gleber/erlcloud.git
$ cd erlcloud
$ git-anal-punchcard.R 4 diff && open punchcard.png
```
![erlcloud](https://raw.github.com/ibnfirnas/git-anal/master/examples/erlcloud-punchcard-top-4-diff.png)


Ideas
-----
* 2D, GitHub-like punchcard:
    - basic punchcrad
    - broken down by:
        + author
        + committer
        + branch
        + language
        + permutations of the above criteria
    - deletions/additions scale
        + remove unusually large edits
          (e.g. a drop-in or a removal of a 3rd party library)
        + punches colored by
        + punches sized by
            * show count of commits at the same time:
                - insert number inside the punch hole?
                - as a 3rd dimension?
* 3D punchcard (removing anomalies):
    - X: time
    - Y: weekday
    - Z: additions/deletion OR commits
    - color: additions/deletion OR commits
* Language detection:
    - by file extension
    - disambiguate file extension (for example Perl vs Prolog `*.pl`) based on
      file content: most common keywords, etc.
* Clusters
    - around files by percentage of contributions
    - around languages by percentage of contributions
    - around relative times of commits
    - around absolute times of commits (could help sync teams across timezones)
* Style analysis:
    - counts of added/deleted;
        + tab characters
        + lines over 80 characters
        + blob files:
            * .DS_Store
            * compiler output (`*.beam`, `*.cmx`, `*.pyc`, `*.o`, etc.)
    - summaries of:
        + line lengths of code
        + line lengths of commit messages:
            * 1st line
            * 2nd line
            * 3rd+ lines
