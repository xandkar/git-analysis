git-anal
========

An exploratory analysis of a Git repository.


Examples
--------
Compare punchcards of top 4 committers to Erlang/OTP repository:
```shell
$ git clone git://github.com/erlang/otp.git
$ cd otp
```
First color-scaled by total edits (insertions + deletions)
```shell
$ git-anal-punchcard.R 4 edits && open punchcard.png
```
![Erlang/OTP](https://raw.github.com/ibnfirnas/git-anal/master/examples/otp-punchcard-top-4-edits.png)

Now the same but with diff proportions instead of total edits scale (greener
for more insertions and redder for more deletions):
```shell
$ git-anal-punchcard.R 4 diff && open punchcard.png
```
![Erlang/OTP](https://raw.github.com/ibnfirnas/git-anal/master/examples/otp-punchcard-top-4-diff.png)


TODO
----
* Optionally reuse parsed data instead of re-parsing on each run


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
