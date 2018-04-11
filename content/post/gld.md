---
author: vadim
date: 2018-04-02
title: "go-license-detector"
image: /post/gld/wtfpl.png
description: "Detecting the license of an open source projects is harder than it seems. We have created go-license-detector, a Go library and command line application to solve that task."
categories: ["science", "technical"]
---

While working on [Public Git Archive](https://github.com/src-d/datasets/PublicGitArchive), we
thought that it would be handy to include the license of each project in the index file, so that
people could easily filter "grey" repositories without a clear license. Besides, we were
curious about the licenses distribution. GitHub already detects licenses by leveraging
[benbalter/licensee](https://github.com/benbalter/licensee) Ruby library and the easy solution was
to query GitHub API. However, we were not satisfied with
its detection quality: many projects which actually contain the license file in a non-standard
format are missed, and some are misclassified. This is how
[go-license-detector](https://github.com/src-d/go-license-detector) was born.

The goals were defined from the very beginning:

1. Favor false positives over false negatives (target data mining instead of compliance).
2. Perform fast.
3. Detect as many licenses as possible on the [hand-collected dataset of 1,000 top-starred repositories
on GitHub](https://github.com/src-d/go-license-detector/blob/master/licensedb/dataset.zip).
4. Comply with SPDX [licenses list](https://github.com/spdx/license-list-data) and
[detection guidelines](https://spdx.org/spdx-license-list/matching-guidelines).

(1) means that we should rather label a project with a bit inaccurate license than miss its
license completely. The open source compliance departments will not be satisfied with this choice,
as they need the opposite: the missed projects are manually studied. (2) restricts from using a
scripting language such as Python or Ruby, and we chose Go for our implementation. (3) leads
to technical tricks, hacks and heuristics which result in complex code.
(4) is the only way to obtain the database of 400 different licenses validated by professional
lawyers.

The following table compares the current go-license-detector with GitHub's built-in license detector,
Google's licenseclassifier and Ben Boyter's `lc` on the
[reference 1k dataset](https://github.com/src-d/go-license-detector/blob/master/licensedb/dataset.zip):

|Detector|Detection rate|Time to scan, sec|
|:-------|:----------------------------------------:|:-----------------------------------------|
|[go-license-detector](https://github.com/src-d/go-license-detector)| 99% \\(\\quad(\\frac{897}{902})\\) | 16 |
|[benbalter/licensee](https://github.com/benbalter/licensee)| 75% \\(\\quad(\\frac{673}{902})\\) | 111 |
|[google/licenseclassifier](https://github.com/google/licenseclassifier)| 76% \\(\\quad(\\frac{682}{902})\\) | 907 |
|[boyter/lc](https://github.com/boyter/lc)| 88% \\(\\quad(\\frac{797}{902})\\) | 548 |

The total number of repositories in the dataset is 958, however, only 902 contain any pointer to
the license - we looked through each of them. The rest are mainly "awesome lists" and Chinese projects
and translations of the western books. We filed issues for the maintainers to clarify the license
[\[1\]](https://github.com/DrkSephy/es6-cheatsheet/issues/90)
[\[2\]](https://github.com/kdn251/interviews/issues/63)
[\[3\]](https://github.com/markerikson/react-redux-links/issues/87)
[\[4\]](https://github.com/CodeHubApp/CodeHub/issues/441)
[\[5\]](https://github.com/h4cc/awesome-elixir/issues/4400)
[\[6\]](https://github.com/fffaraz/awesome-cpp/issues/449).
We also encountered two licenses which were not included into SPDX and reported them:
[\[1\]](https://github.com/spdx/license-list-XML/issues/611)
[\[2\]](https://github.com/spdx/license-list-XML/issues/612).

#### How we measured the time

Hardware: Intel Core i7-7500U (2x2 threads), 2x8GB LPDDR3@1867MHz.

```bash
$ cd $(go env GOPATH)/src/gopkg.in/src-d/go-license-detector.v2/licensedb
$ mkdir dataset && cd dataset
$ unzip ../dataset.zip
$ # src-d/go-license-detector
$ time license-detector * \
  | grep -Pzo '\n[-0-9a-zA-Z]+\n\tno license' | grep -Pa '\tno ' | wc -l
$ # benbalter/licensee
$ time ls -1 | xargs -n1 -P4 licensee \
  | grep -E "^License: Other" | wc -l
$ # google/licenseclassifier
$ time find -type f -print | xargs -n1 -P4 identify_license \
  | cut -d/ -f2 | sort | uniq | wc -l
$ # boyter/lc
$ time lc . \
  | grep -vE 'NOASSERTION|----|Directory' | cut -d" " -f1 | sort | uniq | wc -l
```

## Algorithm

We have implemented license detection based on the `LICENSE` and `README` files for now, and wish to
add fine-grained scanning of source code files in the future (do you want to help us?
work on the [issue](https://github.com/src-d/go-license-detector/issues/24)). Given the
stated license text, we compare it to the texts in the SPDX database and record the match. The naive
way of making the comparisons is to calculate the
[Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
between the query and each of the examples. This is not fast at all for the two reasons:

1. The complexity is linear to the number of examples.
2. The complexity is linear to the size of the difference. Since we've always got very few matches,
the rest of the distances will be slow to calculate.

These two reasons confidently render the naive approach unusable.

The core of go-license-detector's detection mechanism is [Locality Sensitive Hashing](https://en.wikipedia.org/wiki/Locality-sensitive_hashing).
We treat each license as a [TF-IDF-weighted](https://en.wikipedia.org/wiki/Tf%E2%80%93idf)
[bag-of-words](https://en.wikipedia.org/wiki/Bag-of-words_model) - that is, as a set of words where every
word has a weight corresponding to the frequency in the license text (term frequency) and
throughout the whole database (document frequency). This is a proven approach for large scale
similarity detection which we used multiple times in the past. Although 400 items is clearly
not large scale at all, it still makes sense to employ LSH because of the O(1) complexity
guarantee. We saw that it works reasonably well in practice and introduces a small overhead,
say 20MB of memory for the hashes and the vocabulary.

The hashing algorithm which we use is
[Weighted MinHash](http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/36928.pdf)
- again, battle-tested in the past, e.g. in [Apollo](https://github.com/src-d/apollo) or
[bags deduplication](https://blog.sourced.tech/post/minhashcuda/).
After careful tuning of false positive vs. false negative. vs. performance, we decided to set the Jaccard
similarity threshold for our algorithm to 75%, and the hash length to 154 samples.
Since we discard the text structure by treating sequences as sets, we further calculate the Levenshtein
distance to the matched database records in order to determine the precise confidence value.

We look at the `README` file if the analyzed project does not contain a license file. This happens
in more than 7% of the cases in the 1k dataset and 66% in Public Git Archive (182,000 repositories).
There is a fair chance that the license name is mentioned in the `README`, so we apply
[Named Entity Recognition](https://en.wikipedia.org/wiki/Named-entity_recognition)
to find them using the excellent [jdkato/prose](https://github.com/jdkato/prose) NLP library for Go.

Unfortunately, the devil is in the details. There are many unexpected variations for which we had to modify
our initially straight-forward algorithm.

## File names

There are many possible license file names. A few examples:

```nohighlight
LICENSE
license.txt
License.md
lisence.html
lisense.rst
copyright
copying
MIT.txt
gpl-2.0
legal
```

All of them may contain useful information, so we have to design a suitable regular expression for
them, which is currently

```go
var (
	licenseFileNames = []string{
		"li[cs]en[cs]e(s?)",
		"legal",
		"copy(left|right|ing)",
		"unlicense",
		"l?gpl([-_ v]?)(\\d\\.?\\d)?",
		"bsd",
		"mit",
		"apache",
	}
	licenseFileRe = regexp.MustCompile(
		fmt.Sprintf("^(|.*[-_. ])(%s)(|[-_. ].*)$",
			strings.Join(licenseFileNames, "|")))
)
```

There may also be directories which are named like a license file, and we need to look inside.
A few projects contained symbolic links to the actual license texts, and we need to resolve them.
One project even has a license file which consists of the path to a real `LICENSE` file with a custom file name - we treat those as symlinks.

## Rendering and normalization

Many developers like when the licenses are displayed on GitHub nicely formatted, either
put directly in HTML or written using a markup language such as Markdown or ReStructuredText.
Reading those files verbatim is harmful for our matching core and decreases the detection rate
dramatically. Thus we should first render markup to HTML and then extract plain text content from
HTML. go-license-detector currently supports Markdown through
[russross/blackfriday](https://github.com/russross/blackfriday) and ReST through
[hhatto/gorst](https://github.com/hhatto/gorst). HTML tags are stripped with `golang.org/x/net/html`
and a custom HTML entity recognizer.

Having a plain text license, we need to normalize it. SPDX has a list of rules which do not affect
accuracy, and we leverage it. However, our goal is data mining, so we can normalize aggressively.
We designed a three-level normalization pipeline. The first one is SPDX with some other rules
which do not affect the detection accuracy. The second one removes punctuation and lines with
copyright information. We apparently lose some data but our detection is more robust to random
deviations such as dots in the end of the section names or multiple copyright notices in the
header. Finally, the third level removes letter accents (e.g. ñ becomes n, á becomes a, etc.) and
removes all non-alphanumeric characters.

To summarize, this is the evolution of the license file content inside go-license-detector's normalizer.

Original ([home-assistant/home-assistant](https://raw.githubusercontent.com/home-assistant/home-assistant/dev/LICENSE.md)):
{{% scroll-panel height="400" %}}
```markdown
Apache License
==============

_Version 2.0, January 2004_
_&lt;<http://www.apache.org/licenses/>&gt;_

### Terms and Conditions for use, reproduction, and distribution

#### 1. Definitions

“License” shall mean the terms and conditions for use, reproduction, and
distribution as defined by Sections 1 through 9 of this document.

“Licensor” shall mean the copyright owner or entity authorized by the copyright
owner that is granting the License.

“Legal Entity” shall mean the union of the acting entity and all other entities
that control, are controlled by, or are under common control with that entity.
For the purposes of this definition, “control” means **(i)** the power, direct or
indirect, to cause the direction or management of such entity, whether by
contract or otherwise, or **(ii)** ownership of fifty percent (50%) or more of the
outstanding shares, or **(iii)** beneficial ownership of such entity.

“You” (or “Your”) shall mean an individual or Legal Entity exercising
permissions granted by this License.

“Source” form shall mean the preferred form for making modifications, including
but not limited to software source code, documentation source, and configuration
files.

“Object” form shall mean any form resulting from mechanical transformation or
translation of a Source form, including but not limited to compiled object code,
generated documentation, and conversions to other media types.

“Work” shall mean the work of authorship, whether in Source or Object form, made
available under the License, as indicated by a copyright notice that is included
in or attached to the work (an example is provided in the Appendix below).

“Derivative Works” shall mean any work, whether in Source or Object form, that
is based on (or derived from) the Work and for which the editorial revisions,
annotations, elaborations, or other modifications represent, as a whole, an
original work of authorship. For the purposes of this License, Derivative Works
shall not include works that remain separable from, or merely link (or bind by
name) to the interfaces of, the Work and Derivative Works thereof.

“Contribution” shall mean any work of authorship, including the original version
of the Work and any modifications or additions to that Work or Derivative Works
thereof, that is intentionally submitted to Licensor for inclusion in the Work
by the copyright owner or by an individual or Legal Entity authorized to submit
on behalf of the copyright owner. For the purposes of this definition,
“submitted” means any form of electronic, verbal, or written communication sent
to the Licensor or its representatives, including but not limited to
communication on electronic mailing lists, source code control systems, and
issue tracking systems that are managed by, or on behalf of, the Licensor for
the purpose of discussing and improving the Work, but excluding communication
that is conspicuously marked or otherwise designated in writing by the copyright
owner as “Not a Contribution.”

“Contributor” shall mean Licensor and any individual or Legal Entity on behalf
of whom a Contribution has been received by Licensor and subsequently
incorporated within the Work.

#### 2. Grant of Copyright License

Subject to the terms and conditions of this License, each Contributor hereby
grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable copyright license to reproduce, prepare Derivative Works of,
publicly display, publicly perform, sublicense, and distribute the Work and such
Derivative Works in Source or Object form.

#### 3. Grant of Patent License

Subject to the terms and conditions of this License, each Contributor hereby
grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable (except as stated in this section) patent license to make, have
made, use, offer to sell, sell, import, and otherwise transfer the Work, where
such license applies only to those patent claims licensable by such Contributor
that are necessarily infringed by their Contribution(s) alone or by combination
of their Contribution(s) with the Work to which such Contribution(s) was
submitted. If You institute patent litigation against any entity (including a
cross-claim or counterclaim in a lawsuit) alleging that the Work or a
Contribution incorporated within the Work constitutes direct or contributory
patent infringement, then any patent licenses granted to You under this License
for that Work shall terminate as of the date such litigation is filed.

#### 4. Redistribution

You may reproduce and distribute copies of the Work or Derivative Works thereof
in any medium, with or without modifications, and in Source or Object form,
provided that You meet the following conditions:

* **(a)** You must give any other recipients of the Work or Derivative Works a copy of
this License; and
* **(b)** You must cause any modified files to carry prominent notices stating that You
changed the files; and
* **(c)** You must retain, in the Source form of any Derivative Works that You distribute,
all copyright, patent, trademark, and attribution notices from the Source form
of the Work, excluding those notices that do not pertain to any part of the
Derivative Works; and
* **(d)** If the Work includes a “NOTICE” text file as part of its distribution, then any
Derivative Works that You distribute must include a readable copy of the
attribution notices contained within such NOTICE file, excluding those notices
that do not pertain to any part of the Derivative Works, in at least one of the
following places: within a NOTICE text file distributed as part of the
Derivative Works; within the Source form or documentation, if provided along
with the Derivative Works; or, within a display generated by the Derivative
Works, if and wherever such third-party notices normally appear. The contents of
the NOTICE file are for informational purposes only and do not modify the
License. You may add Your own attribution notices within Derivative Works that
You distribute, alongside or as an addendum to the NOTICE text from the Work,
provided that such additional attribution notices cannot be construed as
modifying the License.

You may add Your own copyright statement to Your modifications and may provide
additional or different license terms and conditions for use, reproduction, or
distribution of Your modifications, or for any such Derivative Works as a whole,
provided Your use, reproduction, and distribution of the Work otherwise complies
with the conditions stated in this License.

#### 5. Submission of Contributions

Unless You explicitly state otherwise, any Contribution intentionally submitted
for inclusion in the Work by You to the Licensor shall be under the terms and
conditions of this License, without any additional terms or conditions.
Notwithstanding the above, nothing herein shall supersede or modify the terms of
any separate license agreement you may have executed with Licensor regarding
such Contributions.

#### 6. Trademarks

This License does not grant permission to use the trade names, trademarks,
service marks, or product names of the Licensor, except as required for
reasonable and customary use in describing the origin of the Work and
reproducing the content of the NOTICE file.

#### 7. Disclaimer of Warranty

Unless required by applicable law or agreed to in writing, Licensor provides the
Work (and each Contributor provides its Contributions) on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
including, without limitation, any warranties or conditions of TITLE,
NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE. You are
solely responsible for determining the appropriateness of using or
redistributing the Work and assume any risks associated with Your exercise of
permissions under this License.

#### 8. Limitation of Liability

In no event and under no legal theory, whether in tort (including negligence),
contract, or otherwise, unless required by applicable law (such as deliberate
and grossly negligent acts) or agreed to in writing, shall any Contributor be
liable to You for damages, including any direct, indirect, special, incidental,
or consequential damages of any character arising as a result of this License or
out of the use or inability to use the Work (including but not limited to
damages for loss of goodwill, work stoppage, computer failure or malfunction, or
any and all other commercial damages or losses), even if such Contributor has
been advised of the possibility of such damages.

#### 9. Accepting Warranty or Additional Liability

While redistributing the Work or Derivative Works thereof, You may choose to
offer, and charge a fee for, acceptance of support, warranty, indemnity, or
other liability obligations and/or rights consistent with this License. However,
in accepting such obligations, You may act only on Your own behalf and on Your
sole responsibility, not on behalf of any other Contributor, and only if You
agree to indemnify, defend, and hold each Contributor harmless for any liability
incurred by, or claims asserted against, such Contributor by reason of your
accepting any such warranty or additional liability.

_END OF TERMS AND CONDITIONS_

### APPENDIX: How to apply the Apache License to your work

To apply the Apache License to your work, attach the following boilerplate
notice, with the fields enclosed by brackets `[]` replaced with your own
identifying information. (Don't include the brackets!) The text should be
enclosed in the appropriate comment syntax for the file format. We also
recommend that a file or class name and description of purpose be included on
the same “printed page” as the copyright notice for easier identification within
third-party archives.

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
```
{{% /scroll-panel %}}

HTML:
{{% scroll-panel height="400" %}}
```html
<h1>Apache License</h1>

<p><em>Version 2.0, January 2004</em>
<em>&amp;lt;<a href="http://www.apache.org/licenses/">http://www.apache.org/licenses/</a>&amp;gt;</em></p>

<h3>Terms and Conditions for use, reproduction, and distribution</h3>

<h4>1. Definitions</h4>

<p>“License” shall mean the terms and conditions for use, reproduction, and
distribution as defined by Sections 1 through 9 of this document.</p>

<p>“Licensor” shall mean the copyright owner or entity authorized by the copyright
owner that is granting the License.</p>

<p>“Legal Entity” shall mean the union of the acting entity and all other entities
that control, are controlled by, or are under common control with that entity.
For the purposes of this definition, “control” means <strong>(i)</strong> the power, direct or
indirect, to cause the direction or management of such entity, whether by
contract or otherwise, or <strong>(ii)</strong> ownership of fifty percent (50%) or more of the
outstanding shares, or <strong>(iii)</strong> beneficial ownership of such entity.</p>

<p>“You” (or “Your”) shall mean an individual or Legal Entity exercising
permissions granted by this License.</p>

<p>“Source” form shall mean the preferred form for making modifications, including
but not limited to software source code, documentation source, and configuration
files.</p>

<p>“Object” form shall mean any form resulting from mechanical transformation or
translation of a Source form, including but not limited to compiled object code,
generated documentation, and conversions to other media types.</p>

<p>“Work” shall mean the work of authorship, whether in Source or Object form, made
available under the License, as indicated by a copyright notice that is included
in or attached to the work (an example is provided in the Appendix below).</p>

<p>“Derivative Works” shall mean any work, whether in Source or Object form, that
is based on (or derived from) the Work and for which the editorial revisions,
annotations, elaborations, or other modifications represent, as a whole, an
original work of authorship. For the purposes of this License, Derivative Works
shall not include works that remain separable from, or merely link (or bind by
name) to the interfaces of, the Work and Derivative Works thereof.</p>

<p>“Contribution” shall mean any work of authorship, including the original version
of the Work and any modifications or additions to that Work or Derivative Works
thereof, that is intentionally submitted to Licensor for inclusion in the Work
by the copyright owner or by an individual or Legal Entity authorized to submit
on behalf of the copyright owner. For the purposes of this definition,
“submitted” means any form of electronic, verbal, or written communication sent
to the Licensor or its representatives, including but not limited to
communication on electronic mailing lists, source code control systems, and
issue tracking systems that are managed by, or on behalf of, the Licensor for
the purpose of discussing and improving the Work, but excluding communication
that is conspicuously marked or otherwise designated in writing by the copyright
owner as “Not a Contribution.”</p>

<p>“Contributor” shall mean Licensor and any individual or Legal Entity on behalf
of whom a Contribution has been received by Licensor and subsequently
incorporated within the Work.</p>

<h4>2. Grant of Copyright License</h4>

<p>Subject to the terms and conditions of this License, each Contributor hereby
grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable copyright license to reproduce, prepare Derivative Works of,
publicly display, publicly perform, sublicense, and distribute the Work and such
Derivative Works in Source or Object form.</p>

<h4>3. Grant of Patent License</h4>

<p>Subject to the terms and conditions of this License, each Contributor hereby
grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable (except as stated in this section) patent license to make, have
made, use, offer to sell, sell, import, and otherwise transfer the Work, where
such license applies only to those patent claims licensable by such Contributor
that are necessarily infringed by their Contribution(s) alone or by combination
of their Contribution(s) with the Work to which such Contribution(s) was
submitted. If You institute patent litigation against any entity (including a
cross-claim or counterclaim in a lawsuit) alleging that the Work or a
Contribution incorporated within the Work constitutes direct or contributory
patent infringement, then any patent licenses granted to You under this License
for that Work shall terminate as of the date such litigation is filed.</p>

<h4>4. Redistribution</h4>

<p>You may reproduce and distribute copies of the Work or Derivative Works thereof
in any medium, with or without modifications, and in Source or Object form,
provided that You meet the following conditions:</p>

<ul>
<li><strong>(a)</strong> You must give any other recipients of the Work or Derivative Works a copy of
this License; and</li>
<li><strong>(b)</strong> You must cause any modified files to carry prominent notices stating that You
changed the files; and</li>
<li><strong>&copy;</strong> You must retain, in the Source form of any Derivative Works that You distribute,
all copyright, patent, trademark, and attribution notices from the Source form
of the Work, excluding those notices that do not pertain to any part of the
Derivative Works; and</li>
<li><strong>(d)</strong> If the Work includes a “NOTICE” text file as part of its distribution, then any
Derivative Works that You distribute must include a readable copy of the
attribution notices contained within such NOTICE file, excluding those notices
that do not pertain to any part of the Derivative Works, in at least one of the
following places: within a NOTICE text file distributed as part of the
Derivative Works; within the Source form or documentation, if provided along
with the Derivative Works; or, within a display generated by the Derivative
Works, if and wherever such third-party notices normally appear. The contents of
the NOTICE file are for informational purposes only and do not modify the
License. You may add Your own attribution notices within Derivative Works that
You distribute, alongside or as an addendum to the NOTICE text from the Work,
provided that such additional attribution notices cannot be construed as
modifying the License.</li>
</ul>

<p>You may add Your own copyright statement to Your modifications and may provide
additional or different license terms and conditions for use, reproduction, or
distribution of Your modifications, or for any such Derivative Works as a whole,
provided Your use, reproduction, and distribution of the Work otherwise complies
with the conditions stated in this License.</p>

<h4>5. Submission of Contributions</h4>

<p>Unless You explicitly state otherwise, any Contribution intentionally submitted
for inclusion in the Work by You to the Licensor shall be under the terms and
conditions of this License, without any additional terms or conditions.
Notwithstanding the above, nothing herein shall supersede or modify the terms of
any separate license agreement you may have executed with Licensor regarding
such Contributions.</p>

<h4>6. Trademarks</h4>

<p>This License does not grant permission to use the trade names, trademarks,
service marks, or product names of the Licensor, except as required for
reasonable and customary use in describing the origin of the Work and
reproducing the content of the NOTICE file.</p>

<h4>7. Disclaimer of Warranty</h4>

<p>Unless required by applicable law or agreed to in writing, Licensor provides the
Work (and each Contributor provides its Contributions) on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
including, without limitation, any warranties or conditions of TITLE,
NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE. You are
solely responsible for determining the appropriateness of using or
redistributing the Work and assume any risks associated with Your exercise of
permissions under this License.</p>

<h4>8. Limitation of Liability</h4>

<p>In no event and under no legal theory, whether in tort (including negligence),
contract, or otherwise, unless required by applicable law (such as deliberate
and grossly negligent acts) or agreed to in writing, shall any Contributor be
liable to You for damages, including any direct, indirect, special, incidental,
or consequential damages of any character arising as a result of this License or
out of the use or inability to use the Work (including but not limited to
damages for loss of goodwill, work stoppage, computer failure or malfunction, or
any and all other commercial damages or losses), even if such Contributor has
been advised of the possibility of such damages.</p>

<h4>9. Accepting Warranty or Additional Liability</h4>

<p>While redistributing the Work or Derivative Works thereof, You may choose to
offer, and charge a fee for, acceptance of support, warranty, indemnity, or
other liability obligations and/or rights consistent with this License. However,
in accepting such obligations, You may act only on Your own behalf and on Your
sole responsibility, not on behalf of any other Contributor, and only if You
agree to indemnify, defend, and hold each Contributor harmless for any liability
incurred by, or claims asserted against, such Contributor by reason of your
accepting any such warranty or additional liability.</p>

<p><em>END OF TERMS AND CONDITIONS</em></p>

<h3>APPENDIX: How to apply the Apache License to your work</h3>

<p>To apply the Apache License to your work, attach the following boilerplate
notice, with the fields enclosed by brackets <code>[]</code> replaced with your own
identifying information. (Don&rsquo;t include the brackets!) The text should be
enclosed in the appropriate comment syntax for the file format. We also
recommend that a file or class name and description of purpose be included on
the same “printed page” as the copyright notice for easier identification within
third-party archives.</p>

<pre><code>Copyright [yyyy] [name of copyright owner]

Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</code></pre>
```
{{% /scroll-panel %}}

Plain text:
{{% scroll-panel height="400" %}}
```nohighlight
Apache License

Version 2.0, January 2004
<http://www.apache.org/licenses/>

Terms and Conditions for use, reproduction, and distribution.

1. Definitions.

“License” shall mean the terms and conditions for use, reproduction, and
distribution as defined by Sections 1 through 9 of this document.

“Licensor” shall mean the copyright owner or entity authorized by the copyright
owner that is granting the License.

“Legal Entity” shall mean the union of the acting entity and all other entities
that control, are controlled by, or are under common control with that entity.
For the purposes of this definition, “control” means (i) the power, direct or
indirect, to cause the direction or management of such entity, whether by
contract or otherwise, or (ii) ownership of fifty percent (50%) or more of the
outstanding shares, or (iii) beneficial ownership of such entity.

“You” (or “Your”) shall mean an individual or Legal Entity exercising
permissions granted by this License.

“Source” form shall mean the preferred form for making modifications, including
but not limited to software source code, documentation source, and configuration
files.

“Object” form shall mean any form resulting from mechanical transformation or
translation of a Source form, including but not limited to compiled object code,
generated documentation, and conversions to other media types.

“Work” shall mean the work of authorship, whether in Source or Object form, made
available under the License, as indicated by a copyright notice that is included
in or attached to the work (an example is provided in the Appendix below).

“Derivative Works” shall mean any work, whether in Source or Object form, that
is based on (or derived from) the Work and for which the editorial revisions,
annotations, elaborations, or other modifications represent, as a whole, an
original work of authorship. For the purposes of this License, Derivative Works
shall not include works that remain separable from, or merely link (or bind by
name) to the interfaces of, the Work and Derivative Works thereof.

“Contribution” shall mean any work of authorship, including the original version
of the Work and any modifications or additions to that Work or Derivative Works
thereof, that is intentionally submitted to Licensor for inclusion in the Work
by the copyright owner or by an individual or Legal Entity authorized to submit
on behalf of the copyright owner. For the purposes of this definition,
“submitted” means any form of electronic, verbal, or written communication sent
to the Licensor or its representatives, including but not limited to
communication on electronic mailing lists, source code control systems, and
issue tracking systems that are managed by, or on behalf of, the Licensor for
the purpose of discussing and improving the Work, but excluding communication
that is conspicuously marked or otherwise designated in writing by the copyright
owner as “Not a Contribution.”

“Contributor” shall mean Licensor and any individual or Legal Entity on behalf
of whom a Contribution has been received by Licensor and subsequently
incorporated within the Work.

2. Grant of Copyright License.

Subject to the terms and conditions of this License, each Contributor hereby
grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable copyright license to reproduce, prepare Derivative Works of,
publicly display, publicly perform, sublicense, and distribute the Work and such
Derivative Works in Source or Object form.

3. Grant of Patent License.

Subject to the terms and conditions of this License, each Contributor hereby
grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable (except as stated in this section) patent license to make, have
made, use, offer to sell, sell, import, and otherwise transfer the Work, where
such license applies only to those patent claims licensable by such Contributor
that are necessarily infringed by their Contribution(s) alone or by combination
of their Contribution(s) with the Work to which such Contribution(s) was
submitted. If You institute patent litigation against any entity (including a
cross-claim or counterclaim in a lawsuit) alleging that the Work or a
Contribution incorporated within the Work constitutes direct or contributory
patent infringement, then any patent licenses granted to You under this License
for that Work shall terminate as of the date such litigation is filed.

4. Redistribution.

You may reproduce and distribute copies of the Work or Derivative Works thereof
in any medium, with or without modifications, and in Source or Object form,
provided that You meet the following conditions:


(a) You must give any other recipients of the Work or Derivative Works a copy of
this License; and
(b) You must cause any modified files to carry prominent notices stating that You
changed the files; and
© You must retain, in the Source form of any Derivative Works that You distribute,
all copyright, patent, trademark, and attribution notices from the Source form
of the Work, excluding those notices that do not pertain to any part of the
Derivative Works; and
(d) If the Work includes a “NOTICE” text file as part of its distribution, then any
Derivative Works that You distribute must include a readable copy of the
attribution notices contained within such NOTICE file, excluding those notices
that do not pertain to any part of the Derivative Works, in at least one of the
following places: within a NOTICE text file distributed as part of the
Derivative Works; within the Source form or documentation, if provided along
with the Derivative Works; or, within a display generated by the Derivative
Works, if and wherever such third-party notices normally appear. The contents of
the NOTICE file are for informational purposes only and do not modify the
License. You may add Your own attribution notices within Derivative Works that
You distribute, alongside or as an addendum to the NOTICE text from the Work,
provided that such additional attribution notices cannot be construed as
modifying the License.


You may add Your own copyright statement to Your modifications and may provide
additional or different license terms and conditions for use, reproduction, or
distribution of Your modifications, or for any such Derivative Works as a whole,
provided Your use, reproduction, and distribution of the Work otherwise complies
with the conditions stated in this License.

5. Submission of Contributions.

Unless You explicitly state otherwise, any Contribution intentionally submitted
for inclusion in the Work by You to the Licensor shall be under the terms and
conditions of this License, without any additional terms or conditions.
Notwithstanding the above, nothing herein shall supersede or modify the terms of
any separate license agreement you may have executed with Licensor regarding
such Contributions.

6. Trademarks.

This License does not grant permission to use the trade names, trademarks,
service marks, or product names of the Licensor, except as required for
reasonable and customary use in describing the origin of the Work and
reproducing the content of the NOTICE file.

7. Disclaimer of Warranty.

Unless required by applicable law or agreed to in writing, Licensor provides the
Work (and each Contributor provides its Contributions) on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
including, without limitation, any warranties or conditions of TITLE,
NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE. You are
solely responsible for determining the appropriateness of using or
redistributing the Work and assume any risks associated with Your exercise of
permissions under this License.

8. Limitation of Liability.

In no event and under no legal theory, whether in tort (including negligence),
contract, or otherwise, unless required by applicable law (such as deliberate
and grossly negligent acts) or agreed to in writing, shall any Contributor be
liable to You for damages, including any direct, indirect, special, incidental,
or consequential damages of any character arising as a result of this License or
out of the use or inability to use the Work (including but not limited to
damages for loss of goodwill, work stoppage, computer failure or malfunction, or
any and all other commercial damages or losses), even if such Contributor has
been advised of the possibility of such damages.

9. Accepting Warranty or Additional Liability.

While redistributing the Work or Derivative Works thereof, You may choose to
offer, and charge a fee for, acceptance of support, warranty, indemnity, or
other liability obligations and/or rights consistent with this License. However,
in accepting such obligations, You may act only on Your own behalf and on Your
sole responsibility, not on behalf of any other Contributor, and only if You
agree to indemnify, defend, and hold each Contributor harmless for any liability
incurred by, or claims asserted against, such Contributor by reason of your
accepting any such warranty or additional liability.

END OF TERMS AND CONDITIONS

APPENDIX: How to apply the Apache License to your work.

To apply the Apache License to your work, attach the following boilerplate
notice, with the fields enclosed by brackets [] replaced with your own
identifying information. (Don’t include the brackets!) The text should be
enclosed in the appropriate comment syntax for the file format. We also
recommend that a file or class name and description of purpose be included on
the same “printed page” as the copyright notice for easier identification within
third-party archives.

Copyright [yyyy] [name of copyright owner]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
{{% /scroll-panel %}}

Normalized-1 - SPDX guidelines:
{{% scroll-panel height="400" %}}
```nohighlight
apache license

version 2.0, january 2004
http:/www.apache.org/licenses/
terms and conditions for use, reproduction, and distribution.
definitions.
"license" shall mean the terms and conditions for use, reproduction, and
distribution as defined by sections 1 through 9 of this document.
"licensor" shall mean the © or entity authorized by the ©
owner that is granting the license

"legal entity" shall mean the union of the acting entity and all other entities
that control, are controlled by, or are under common control with that entity.
for the purposes of this definition, "control" means (i) the power, direct or
indirect, to cause the direction or management of such entity, whether by
contract or otherwise, or (ii) ownership of fifty percent (50%) or more of the
outstanding shares, or (iii) beneficial ownership of such entity.
"you" (or "your") shall mean an individual or legal entity exercising
permissions granted by this license

"source" form shall mean the preferred form for making modifications, including
but not limited to software source code, documentation source, and configuration
files.
"object" form shall mean any form resulting from mechanical transformation or
translation of a source form, including but not limited to compiled object code,
generated documentation, and conversions to other media types.
"work" shall mean the work of authorship, whether in source or object form, made
available under the license, as indicated by a © notice that is included
in or attached to the work (an example is provided in the appendix below).
"derivative works" shall mean any work, whether in source or object form, that
is based on (or derived from) the work and for which the editorial revisions,
annotations, elaborations, or other modifications represent, as a whole, an
original work of authorship. for the purposes of this license, derivative works
shall not include works that remain separable from, or merely link (or bind by
name) to the interfaces of, the work and derivative works thereof.
"contribution" shall mean any work of authorship, including the original version
of the work and any modifications or additions to that work or derivative works
thereof, that is intentionally submitted to licensor for inclusion in the work
by the © or by an individual or legal entity authorized to submit
on behalf of the ©. for the purposes of this definition,
"submitted" means any form of electronic, verbal, or written communication sent
to the licensor or its representatives, including but not limited to
communication on electronic mailing lists, source code control systems, and
issue tracking systems that are managed by, or on behalf of, the licensor for
the purpose of discussing and improving the work, but excluding communication
that is conspicuously marked or otherwise designated in writing by the ©
owner as "not a contribution."
"contributor" shall mean licensor and any individual or legal entity on behalf
of whom a contribution has been received by licensor and subsequently
incorporated within the work.
grant of © license

subject to the terms and conditions of this license, each contributor hereby
grants to you a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable © license to reproduce, prepare derivative works of,
publicly display, publicly perform, sublicense, and distribute the work and such
derivative works in source or object form.
grant of patent license

subject to the terms and conditions of this license, each contributor hereby
grants to you a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable (except as stated in this section) patent license to make, have
made, use, offer to sell, sell, import, and otherwise transfer the work, where
such license applies only to those patent claims licensable by such contributor
that are necessarily infringed by their contribution(s) alone or by combination
of their contribution(s) with the work to which such contribution(s) was
submitted. if you institute patent litigation against any entity (including a
cross-claim or counterclaim in a lawsuit) alleging that the work or a
contribution incorporated within the work constitutes direct or contributory
patent infringement, then any patent licenses granted to you under this license
for that work shall terminate as of the date such litigation is filed.
redistribution.
you may reproduce and distribute copies of the work or derivative works thereof
in any medium, with or without modifications, and in source or object form,
provided that you meet the following conditions:
you must give any other recipients of the work or derivative works a copy of
this license; and
you must cause any modified files to carry prominent notices stating that you
changed the files; and
© you must retain, in the source form of any derivative works that you distribute,
all ©, patent, ™, and attribution notices from the source form
of the work, excluding those notices that do not pertain to any part of the
derivative works; and
if the work includes a "notice" text file as part of its distribution, then any
derivative works that you distribute must include a readable copy of the
attribution notices contained within such notice file, excluding those notices
that do not pertain to any part of the derivative works, in at least one of the
following places: within a notice text file distributed as part of the
derivative works; within the source form or documentation, if provided along
with the derivative works; or, within a display generated by the derivative
works, if and wherever such third-party notices normally appear. the contents of
the notice file are for informational purposes only and do not modify the
license. you may add your own attribution notices within derivative works that
you distribute, alongside or as an addendum to the notice text from the work,
provided that such additional attribution notices cannot be construed as
modifying the license

you may add your own © statement to your modifications and may provide
additional or different license terms and conditions for use, reproduction, or
distribution of your modifications, or for any such derivative works as a whole,
provided your use, reproduction, and distribution of the work otherwise complies
with the conditions stated in this license

submission of contributions.
unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you to the licensor shall be under the terms and
conditions of this license, without any additional terms or conditions.
notwithstanding the above, nothing herein shall supersede or modify the terms of
any separate license agreement you may have executed with licensor regarding
such contributions.
™.
this license does not grant permission to use the trade names, ™,
service marks, or product names of the licensor, except as required for
reasonable and customary use in describing the origin of the work and
reproducing the content of the notice file.
disclaimer of warranty.
unless required by applicable law or agreed to in writing, licensor provides the
work (and each contributor provides its contributions) on an "as is" basis,
without warranties or conditions of any kind, either express or implied,
including, without limitation, any warranties or conditions of title,
non-infringement, merchantability, or fitness for a particular purpose. you are
solely responsible for determining the appropriateness of using or
redistributing the work and assume any risks associated with your exercise of
permissions under this license

limitation of liability.
in no event and under no legal theory, whether in tort (including negligence),
contract, or otherwise, unless required by applicable law (such as deliberate
and grossly negligent acts) or agreed to in writing, shall any contributor be
liable to you for damages, including any direct, indirect, special, incidental,
or consequential damages of any character arising as a result of this license or
out of the use or inability to use the work (including but not limited to
damages for loss of goodwill, work stoppage, computer failure or malfunction, or
any and all other commercial damages or losses), even if such contributor has
been advised of the possibility of such damages.
accepting warranty or additional liability.
while redistributing the work or derivative works thereof, you may choose to
offer, and charge a fee for, acceptance of support, warranty, indemnity, or
other liability obligations and/or rights consistent with this license. however,
in accepting such obligations, you may act only on your own behalf and on your
sole responsibility, not on behalf of any other contributor, and only if you
agree to indemnify, defend, and hold each contributor harmless for any liability
incurred by, or claims asserted against, such contributor by reason of your
accepting any such warranty or additional liability.
end of terms and conditions
appendix: how to apply the apache license to your work.
to apply the apache license to your work, attach the following boilerplate
notice, with the fields enclosed by brackets [] replaced with your own
identifying information. (don"t include the brackets!) the text should be
enclosed in the appropriate comment syntax for the file format. we also
recommend that a file or class name and description of purpose be included on
the same "printed page" as the © notice for easier identification within
third-party archives.
© [yyyy] [name of ©]
licensed under the apache license, version 2.0 (the "license");
you may not use this file except in compliance with the license.
you may obtain a copy of the license at
http:/www.apache.org/licenses/license-2.0
unless required by applicable law or agreed to in writing, software
distributed under the license is distributed on an "as is" basis,
without warranties or conditions of any kind, either express or implied.
see the license for the specific language governing permissions and
limitations under the license
```
{{% /scroll-panel %}}

Normalized-2 - dots and copyrights removed:
{{% scroll-panel height="400" %}}
```nohighlight
apache license

version 20, january 2004
http:/wwwapacheorg/licenses/
terms and conditions for use, reproduction, and distribution
definitions
"license" shall mean the terms and conditions for use, reproduction, and
distribution as defined by sections 1 through 9 of this document
"licensor" shall mean the © or entity authorized by the ©
owner that is granting the license

"legal entity" shall mean the union of the acting entity and all other entities
that control, are controlled by, or are under common control with that entity
for the purposes of this definition, "control" means (i) the power, direct or
indirect, to cause the direction or management of such entity, whether by
contract or otherwise, or (ii) ownership of fifty percent (50%) or more of the
outstanding shares, or (iii) beneficial ownership of such entity
"you" (or "your") shall mean an individual or legal entity exercising
permissions granted by this license

"source" form shall mean the preferred form for making modifications, including
but not limited to software source code, documentation source, and configuration
files
"object" form shall mean any form resulting from mechanical transformation or
translation of a source form, including but not limited to compiled object code,
generated documentation, and conversions to other media types
"work" shall mean the work of authorship, whether in source or object form, made
available under the license, as indicated by a © notice that is included
in or attached to the work (an example is provided in the appendix below)
"derivative works" shall mean any work, whether in source or object form, that
is based on (or derived from) the work and for which the editorial revisions,
annotations, elaborations, or other modifications represent, as a whole, an
original work of authorship for the purposes of this license, derivative works
shall not include works that remain separable from, or merely link (or bind by
name) to the interfaces of, the work and derivative works thereof
"contribution" shall mean any work of authorship, including the original version
of the work and any modifications or additions to that work or derivative works
thereof, that is intentionally submitted to licensor for inclusion in the work
by the © or by an individual or legal entity authorized to submit
on behalf of the © for the purposes of this definition,
"submitted" means any form of electronic, verbal, or written communication sent
to the licensor or its representatives, including but not limited to
communication on electronic mailing lists, source code control systems, and
issue tracking systems that are managed by, or on behalf of, the licensor for
the purpose of discussing and improving the work, but excluding communication
that is conspicuously marked or otherwise designated in writing by the ©
owner as "not a contribution"
"contributor" shall mean licensor and any individual or legal entity on behalf
of whom a contribution has been received by licensor and subsequently
incorporated within the work
grant of © license

subject to the terms and conditions of this license, each contributor hereby
grants to you a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable © license to reproduce, prepare derivative works of,
publicly display, publicly perform, sublicense, and distribute the work and such
derivative works in source or object form
grant of patent license

subject to the terms and conditions of this license, each contributor hereby
grants to you a perpetual, worldwide, non-exclusive, no-charge, royalty-free,
irrevocable (except as stated in this section) patent license to make, have
made, use, offer to sell, sell, import, and otherwise transfer the work, where
such license applies only to those patent claims licensable by such contributor
that are necessarily infringed by their contribution(s) alone or by combination
of their contribution(s) with the work to which such contribution(s) was
submitted if you institute patent litigation against any entity (including a
cross-claim or counterclaim in a lawsuit) alleging that the work or a
contribution incorporated within the work constitutes direct or contributory
patent infringement, then any patent licenses granted to you under this license
for that work shall terminate as of the date such litigation is filed
redistribution
you may reproduce and distribute copies of the work or derivative works thereof
in any medium, with or without modifications, and in source or object form,
provided that you meet the following conditions:
you must give any other recipients of the work or derivative works a copy of
this license; and
you must cause any modified files to carry prominent notices stating that you
changed the files; and
all ©, patent, ™, and attribution notices from the source form
of the work, excluding those notices that do not pertain to any part of the
derivative works; and
if the work includes a "notice" text file as part of its distribution, then any
derivative works that you distribute must include a readable copy of the
attribution notices contained within such notice file, excluding those notices
that do not pertain to any part of the derivative works, in at least one of the
following places: within a notice text file distributed as part of the
derivative works; within the source form or documentation, if provided along
with the derivative works; or, within a display generated by the derivative
works, if and wherever such third-party notices normally appear the contents of
the notice file are for informational purposes only and do not modify the
license you may add your own attribution notices within derivative works that
you distribute, alongside or as an addendum to the notice text from the work,
provided that such additional attribution notices cannot be construed as
modifying the license

you may add your own © statement to your modifications and may provide
additional or different license terms and conditions for use, reproduction, or
distribution of your modifications, or for any such derivative works as a whole,
provided your use, reproduction, and distribution of the work otherwise complies
with the conditions stated in this license

submission of contributions
unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you to the licensor shall be under the terms and
conditions of this license, without any additional terms or conditions
notwithstanding the above, nothing herein shall supersede or modify the terms of
any separate license agreement you may have executed with licensor regarding
such contributions
™
this license does not grant permission to use the trade names, ™,
service marks, or product names of the licensor, except as required for
reasonable and customary use in describing the origin of the work and
reproducing the content of the notice file
disclaimer of warranty
unless required by applicable law or agreed to in writing, licensor provides the
work (and each contributor provides its contributions) on an "as is" basis,
without warranties or conditions of any kind, either express or implied,
including, without limitation, any warranties or conditions of title,
non-infringement, merchantability, or fitness for a particular purpose you are
solely responsible for determining the appropriateness of using or
redistributing the work and assume any risks associated with your exercise of
permissions under this license

limitation of liability
in no event and under no legal theory, whether in tort (including negligence),
contract, or otherwise, unless required by applicable law (such as deliberate
and grossly negligent acts) or agreed to in writing, shall any contributor be
liable to you for damages, including any direct, indirect, special, incidental,
or consequential damages of any character arising as a result of this license or
out of the use or inability to use the work (including but not limited to
damages for loss of goodwill, work stoppage, computer failure or malfunction, or
any and all other commercial damages or losses), even if such contributor has
been advised of the possibility of such damages
accepting warranty or additional liability
while redistributing the work or derivative works thereof, you may choose to
offer, and charge a fee for, acceptance of support, warranty, indemnity, or
other liability obligations and/or rights consistent with this license however,
in accepting such obligations, you may act only on your own behalf and on your
sole responsibility, not on behalf of any other contributor, and only if you
agree to indemnify, defend, and hold each contributor harmless for any liability
incurred by, or claims asserted against, such contributor by reason of your
accepting any such warranty or additional liability
end of terms and conditions
appendix: how to apply the apache license to your work
to apply the apache license to your work, attach the following boilerplate
notice, with the fields enclosed by brackets [] replaced with your own
identifying information (don"t include the brackets!) the text should be
enclosed in the appropriate comment syntax for the file format we also
recommend that a file or class name and description of purpose be included on
the same "printed page" as the © notice for easier identification within
third-party archives
licensed under the apache license, version 20 (the "license");
you may not use this file except in compliance with the license
you may obtain a copy of the license at
http:/wwwapacheorg/licenses/license-20
unless required by applicable law or agreed to in writing, software
distributed under the license is distributed on an "as is" basis,
without warranties or conditions of any kind, either express or implied
see the license for the specific language governing permissions and
limitations under the license
```
{{% /scroll-panel %}}

Normalized-3 - non-alphanumeric symbols removed:
{{% scroll-panel height="400" %}}
```nohighlight
apache license
thisislikelyalicenseheaderplaceholder
version 20 january 2004
httpwwwapacheorglicenses
terms and conditions for use reproduction and distribution
definitions
license shall mean the terms and conditions for use reproduction and
distribution as defined by sections 1 through 9 of this document
licensor shall mean the or entity authorized by the 
owner that is granting the license
thisislikelyalicenseheaderplaceholder
legal entity shall mean the union of the acting entity and all other entities
that control are controlled by or are under common control with that entity
for the purposes of this definition control means i the power direct or
indirect to cause the direction or management of such entity whether by
contract or otherwise or ii ownership of fifty percent 50 or more of the
outstanding shares or iii beneficial ownership of such entity
you or your shall mean an individual or legal entity exercising
permissions granted by this license
thisislikelyalicenseheaderplaceholder
source form shall mean the preferred form for making modifications including
but not limited to software source code documentation source and configuration
files
object form shall mean any form resulting from mechanical transformation or
translation of a source form including but not limited to compiled object code
generated documentation and conversions to other media types
work shall mean the work of authorship whether in source or object form made
available under the license as indicated by a notice that is included
in or attached to the work an example is provided in the appendix below
derivative works shall mean any work whether in source or object form that
is based on or derived from the work and for which the editorial revisions
annotations elaborations or other modifications represent as a whole an
original work of authorship for the purposes of this license derivative works
shall not include works that remain separable from or merely link or bind by
name to the interfaces of the work and derivative works thereof
contribution shall mean any work of authorship including the original version
of the work and any modifications or additions to that work or derivative works
thereof that is intentionally submitted to licensor for inclusion in the work
by the or by an individual or legal entity authorized to submit
on behalf of the for the purposes of this definition
submitted means any form of electronic verbal or written communication sent
to the licensor or its representatives including but not limited to
communication on electronic mailing lists source code control systems and
issue tracking systems that are managed by or on behalf of the licensor for
the purpose of discussing and improving the work but excluding communication
that is conspicuously marked or otherwise designated in writing by the 
owner as not a contribution
contributor shall mean licensor and any individual or legal entity on behalf
of whom a contribution has been received by licensor and subsequently
incorporated within the work
grant of license
thisislikelyalicenseheaderplaceholder
subject to the terms and conditions of this license each contributor hereby
grants to you a perpetual worldwide non-exclusive no-charge royalty-free
irrevocable license to reproduce prepare derivative works of
publicly display publicly perform sublicense and distribute the work and such
derivative works in source or object form
grant of patent license
thisislikelyalicenseheaderplaceholder
subject to the terms and conditions of this license each contributor hereby
grants to you a perpetual worldwide non-exclusive no-charge royalty-free
irrevocable except as stated in this section patent license to make have
made use offer to sell sell import and otherwise transfer the work where
such license applies only to those patent claims licensable by such contributor
that are necessarily infringed by their contributions alone or by combination
of their contributions with the work to which such contributions was
submitted if you institute patent litigation against any entity including a
cross-claim or counterclaim in a lawsuit alleging that the work or a
contribution incorporated within the work constitutes direct or contributory
patent infringement then any patent licenses granted to you under this license
for that work shall terminate as of the date such litigation is filed
redistribution
you may reproduce and distribute copies of the work or derivative works thereof
in any medium with or without modifications and in source or object form
provided that you meet the following conditions
you must give any other recipients of the work or derivative works a copy of
this license and
you must cause any modified files to carry prominent notices stating that you
changed the files and
all patent and attribution notices from the source form
of the work excluding those notices that do not pertain to any part of the
derivative works and
if the work includes a notice text file as part of its distribution then any
derivative works that you distribute must include a readable copy of the
attribution notices contained within such notice file excluding those notices
that do not pertain to any part of the derivative works in at least one of the
following places within a notice text file distributed as part of the
derivative works within the source form or documentation if provided along
with the derivative works or within a display generated by the derivative
works if and wherever such third-party notices normally appear the contents of
the notice file are for informational purposes only and do not modify the
license you may add your own attribution notices within derivative works that
you distribute alongside or as an addendum to the notice text from the work
provided that such additional attribution notices cannot be construed as
modifying the license
thisislikelyalicenseheaderplaceholder
you may add your own statement to your modifications and may provide
additional or different license terms and conditions for use reproduction or
distribution of your modifications or for any such derivative works as a whole
provided your use reproduction and distribution of the work otherwise complies
with the conditions stated in this license
thisislikelyalicenseheaderplaceholder
submission of contributions
unless you explicitly state otherwise any contribution intentionally submitted
for inclusion in the work by you to the licensor shall be under the terms and
conditions of this license without any additional terms or conditions
notwithstanding the above nothing herein shall supersede or modify the terms of
any separate license agreement you may have executed with licensor regarding
such contributions
this license does not grant permission to use the trade names 
service marks or product names of the licensor except as required for
reasonable and customary use in describing the origin of the work and
reproducing the content of the notice file
disclaimer of warranty
unless required by applicable law or agreed to in writing licensor provides the
work and each contributor provides its contributions on an as is basis
without warranties or conditions of any kind either express or implied
including without limitation any warranties or conditions of title
non-infringement merchantability or fitness for a particular purpose you are
solely responsible for determining the appropriateness of using or
redistributing the work and assume any risks associated with your exercise of
permissions under this license
thisislikelyalicenseheaderplaceholder
limitation of liability
in no event and under no legal theory whether in tort including negligence
contract or otherwise unless required by applicable law such as deliberate
and grossly negligent acts or agreed to in writing shall any contributor be
liable to you for damages including any direct indirect special incidental
or consequential damages of any character arising as a result of this license or
out of the use or inability to use the work including but not limited to
damages for loss of goodwill work stoppage computer failure or malfunction or
any and all other commercial damages or losses even if such contributor has
been advised of the possibility of such damages
accepting warranty or additional liability
while redistributing the work or derivative works thereof you may choose to
offer and charge a fee for acceptance of support warranty indemnity or
other liability obligations andor rights consistent with this license however
in accepting such obligations you may act only on your own behalf and on your
sole responsibility not on behalf of any other contributor and only if you
agree to indemnify defend and hold each contributor harmless for any liability
incurred by or claims asserted against such contributor by reason of your
accepting any such warranty or additional liability
end of terms and conditions
appendix how to apply the apache license to your work
to apply the apache license to your work attach the following boilerplate
notice with the fields enclosed by brackets replaced with your own
identifying information dont include the brackets the text should be
enclosed in the appropriate comment syntax for the file format we also
recommend that a file or class name and description of purpose be included on
the same printed page as the notice for easier identification within
third-party archives
licensed under the apache license version 20 the license
you may not use this file except in compliance with the license
you may obtain a copy of the license at
httpwwwapacheorglicenseslicense-20
unless required by applicable law or agreed to in writing software
distributed under the license is distributed on an as is basis
without warranties or conditions of any kind either express or implied
see the license for the specific language governing permissions and
limitations under the license
thisislikelyalicenseheaderplaceholder
```
{{% /scroll-panel %}}

We use level 3 output for LSH and level 2 output for the Levenshtein distance refinement.

## Merged licenses

There are projects with several license texts in the same file
Some of them are dual-licensed, some mention dependencies. Our core matcher assumes the single
sample by design, and those cases are hard for it to handle.
[google/licenseclassifier](https://github.com/google/licenseclassifier) project gracefully
digests them because it is based on ngram hashing instead, and hence we considered switching to that
algorithm. We did not for the following reasons:

1. The memory consumption is higher, about [200 MB](https://github.com/google/licenseclassifier/blob/master/classifier.go#L188).
2. Non-trivial database preprocessing and lack of high-level documentation.
3. Slower performance on single licenses.
3. It appeared that 95% of the cases could be resolved by simple split heuristics.

After all, we found that since it is very cheap to query a text, we could make a few split assumptions
and process each variant independently. For example, many texts separate licenses
with `===` or `---` decorations. Besides, it is common to place the license name before the body
and we easily find all possible split points. This is still not bulletproff as in license-classifier,
but as was written works reasonably well.

## Pointers

Sometimes, all the efforts fail and we do not discover anything in `LICENSE` files and in `README` files.
There is still hope: we discovered that many projects contain the URL to the official license text
in them. E.g. [awesome lists which have the CC0 badge at the bottom](https://github.com/terryum/awesome-deep-learning-papers),
[Apache banners](https://github.com/dmlc/xgboost/blob/master/LICENSE) or numerous users of
[mit-license.org](https://mit-license.org). 

## Implementation

go-license-detector is a library and a self-contained binary CLI tool.

[Francesc](https://twitter.com/francesc), our VP of Developer Community, took a serious effort
in making the code idiomatic. You may have experienced this: when you are focused on **what** your
code is doing, you often miss **how** the code is looking. I would like to write
a follow-up post which describes which points were improved and what were the
typical issues.

## Offtopic

Since we had to manually look through hundreds of most-starred projects on GitHub, we noticed
a few funny trends. Many Chinese repositories isolated from the other communities,
awesome list expansion and others. Again, I should devote a separate post to those,
they are funny and also help to understand the picture of open source popularity better.

## PGA license survey

We've recently released [Public Git Archive](https://github.com/src-d/datasets/PublicGitArchive) (PGA),
182,000 Git repositories belonging to most popular projects on GitHub. It's index file contains the licenses
detected by go-license-detector. The following pie chart summarizes the license usage in PGA:

<svg id="pga-licenses"></svg>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/4.13.0/d3.min.js"></script>
<script src="/post/gld/chart.js"></script>

go-license-detector was able to find licenses in 66.6% of the projects (confidence threshold 0.75).
It can be seen that the most widespread license is MIT (no surprise here), Apache is on the second place and GPL on the third.