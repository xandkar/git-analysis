git-analysis
============

An exploratory analysis of a Git repository.


Examples
--------
Compare punchcards of top 4 committers to Erlang/OTP repository:
```shell
$ git clone git://github.com/erlang/otp.git
$ cd otp
$ time git-analysis -n 4
145.09s user 0.38s system 99% cpu 2:25.63 total
$ ls -1 .git-analysis
plot-distribution-edits-per-commit-hist.png
plot-distribution-edits-per-commit-kde.png
plot-punchcard-all-diff.png
plot-punchcard-all-edits.png
plot-punchcard-all.png
plot-punchcard-top-4-committers-diff.png
plot-punchcard-top-4-committers-edits.png
plot-punchcard-top-4-committers.png
raw-log.dat
table-commits.csv
table-punchcard.csv
```

`plot-punchcard-top-4-committers-edits.png`: punch holes color-scaled by total
edits
(insertions + deletions)
![Erlang/OTP](https://raw.github.com/ibnfirnas/git-analysis/master/examples/otp-punchcard-top-4-edits.png)

`plot-punchcard-top-4-committers-diff.png`: punch holes color-scaled by diff
proportions (insertions - deletions):
![Erlang/OTP](https://raw.github.com/ibnfirnas/git-analysis/master/examples/otp-punchcard-top-4-diff.png)


TODO
----
* Optionally reuse parsed data instead of re-parsing on each run
* Consider replacing (slow) ggplot2 with (much faster) lattice


Ideas
-----
* 2D, GitHub-like punchcard:
    - optionally parse time as either:
        + author-local
        + analyst-local (as in computer running this program)
        + UTC
    - ~~basic punchcard~~
    - broken down by:
        + ~~author~~
        + branch
        + language
        + permutations of the above criteria
    - deletions/additions scale
        + remove unusually large edits
          (e.g. a drop-in or a removal of a 3rd party library)
        + ~~punches colored by~~
        + characters inserted/deleted stats in addition to lines
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
