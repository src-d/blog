---
author: campoy
date: 2018-02-20
title: "source{d} does FOSDEM 2018"
image: "/post/fosdem-2018/fosdem.png"
description: "Almost every source{d} employee just came back from FOSDEM 2018 and we have so much to tell you!"
categories: ["technical", "community"]
---

As every year since (for the last 18 years) February is the time for
[FOSDEM](https://fosdem.org), the Free and Open Source Software Developers'
European Meeting.

And for the third year in a row, most of the employees here at
[source{d}](https://sourced.tech) went all the way to freezing Brussels to participate
in this amazing conference. Some were attending, others speaking, others organizing
entire devrooms.

This blog post is a recollection of the facts, as accurately as we can remember,
since part of FOSDEM is enjoying Belgian delicacies such as waffles and beers.

## The Go Devroom

On Saturday [Maartje Eyskens](https://twitter.com/MaartjeME), CEO of
[Women Who Go](https://womenwhogo.org), and [Francesc](https://twitter.com/francesc), our
dear VP of Developer Relations, co-organized the fourth edition of the Go Devroom.

This year the Go Devroom was a huge success and you can already watch all of the talks
online on this [YouTube playlist](https://www.youtube.com/playlist?list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi).

- The State of Go What's new in Go 1.10, by [Francesc Campoy](https://twitter.com/francesc) ([🎥](https://www.youtube.com/watch?v=iR7LPAXWfmw&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=3) / [📈](https://campoy.cat/l/sog110))
- Advanced Go debugging with Delve, by [Derek Parker](https://twitter.com/derkthedaring) ([🎥](https://www.youtube.com/watch?v=VBiFiguj52I&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=2&t=7s) / [📈](https://speakerdeck.com/derekparker/debugging-go-programs-with-delve#)).
- Networking deepdive From net.Dial to gRPC, by [Michael Hausenblas](https://twitter.com/mhausenblas) ([🎥](https://www.youtube.com/watch?v=xfv5nhqacAc&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=3) / [📈](http://go-talks.appspot.com/github.com/mhausenblas/fosdem2018-godevroom-networkingdeepdive/main.slide#1)).
- Testing and Automation in the Era of Containers (with Go), by [Verónica López](https://twitter.com/maria_fibonacci) ([🎥](https://www.youtube.com/watch?v=KgY2uVgz_tQ&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=4)  / [📈](https://docs.google.com/presentation/d/1RiOlYfYN0cuNKRrwr8DcSYJ6WlfxFgBHgBFADGyZ1fo/edit#slide=id.g32c02a2df3_2_52)).
- Upspin and a future of the Internet, by [Gildas Chabot](https://twitter.com/GildasChabot) ([🎥](https://www.youtube.com/watch?v=gw9TRP5RQLU&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=5) / [📈](https://speakerdeck.com/gildasch/upspin-fosdem-2018)).
- Dep Deep Dive!, by [Sam Boyer](https://twitter.com/sdboyer) ([🎥](https://www.youtube.com/watch?v=G6MZyC_saGY&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=6) / [📈](https://docs.google.com/presentation/d/1nXZQXlkE3dSfOutJh4VVc76aXt8HCs-HoD1nWeb9Jzc/edit#slide=id.p)).
- Networking Swiss Army Knife for Go, by Roman Mohr ([🎥](https://www.youtube.com/watch?v=vfBqvuH0ykM&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=7)).
- The case for interface{} When and how to use empty interface, by [Sam Whited](https://twitter.com/SamWhited) ([🎥](https://www.youtube.com/watch?v=FKcCnA9jjXc&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=8) / [📈](https://blog.samwhited.com/Whited_FOSDEM2018_169.pdf)).
- Google’s approach to distributed systems observability for Go, by [Jaana Dogan](https://twitter.com/rakyll) ([🎥](https://www.youtube.com/watch?v=MoxGcm-aYyI&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=9) / [📈](https://speakerdeck.com/rakyll/observability-at-google)).
- Creating GopherJS Apps with gRPC-Web, by [Johan Brandhorst](https://twitter.com/JohanBrandhorst) ([🎥](https://www.youtube.com/watch?v=R2HaxH7Et64&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=10) / [📈](https://talks.godoc.org/github.com/johanbrandhorst/presentations/fosdem/grpcweb.slide#1)).
- Building and testing a distributed data store in Go, by [Matt Bostock](https://twitter.com/mattbostock) ([🎥](https://www.youtube.com/watch?v=Su2WqMHVoAA&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=11) / [📈](https://fosdem.org/2018/schedule/event/datastore/attachments/📈/2618/export/events/attachments/datastore/📈/2618/designing_distributed_datastore_in_go_timbala.pdf)).
- Computer Vision Using Go And OpenCV, by [Ron Evans](https://twitter.com/deadprogram) ([🎥](https://www.youtube.com/watch?v=7ls9K-VzAb8&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=12)  / [📈](https://deadprogram.github.io/fosdem-2018/)).
- Make your Go go faster! Optimising performance through reducing memory allocations, by [Bryan Boreham](https://twitter.com/bboreham) ([🎥](https://www.youtube.com/watch?v=NS1hmEWv4Ac&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=13) / [📈](https://fosdem.org/2018/schedule/event/faster/attachments/📈/2510/export/events/attachments/faster/📈/2510/BryanBorehamGoOptimisation.pdf)).
- Distributing DevOps tools using GoLang and Containers, for Fun and Profit!, by [Lucy Davinhart](https://twitter.com/LucyDavinhart) ([🎥](https://www.youtube.com/watch?v=4ZWGFjfB3mA&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=14) / [📈](https://fosdem.org/2018/schedule/event/devops/attachments/📈/2046/export/events/attachments/devops/📈/2046/Distributing_DevOps_Tools_for_Fun_and_Profit!.pdf)).
- DNA sequencing performance in Go, C++, and Java, by [Pascal Costanza](https://twitter.com/p1cost) ([🎥](https://www.youtube.com/watch?v=l2BZoyzj6VM&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=15) / [📈](https://fosdem.org/2018/schedule/event/dna_sequencing/attachments/📈/2109/export/events/attachments/dna_sequencing/📈/2109/elprep_fosdem_public.pdf)).
- Go Lightning Talks Come speak!, by many awesome speakers! ([🎥](https://www.youtube.com/watch?v=8rtDhNtV0sQ&list=PLtLJO5JKE5YCYgIdpJPxNzWxpMuUWgbVi&index=16)).

![A picture of the Go Devroom](/post/fosdem-2018/go-devroom.jpg)

## The Speakers Dinner of Saturday Night

Is a conference really a conference without a fun speakers night? At source{d} we think that's
not the case, so we invited all the speakers from the Go and Source Code Analysis devrooms to
have a nice dinner and some drinks surrounded by source{d} employees and friends.

![A picture of the speakers dinner](/post/fosdem-2018/dinner.jpg)

## The Source Code Analysis Devroom

On Sunday afternoon, it was time for [Alex Bezzubov](https://twitter.com/seoul_engineer)
(software engineer at source{d}) and Francesc to
co-organize a second devroom. This was the first time a devroom on the topic was created and it
was, juding by the quality of the talks and the constant crowd in the room, a big success.

The talks (available in this [YouTube playlist](https://www.youtube.com/playlist?list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez)) were the following:

- Babelfish: a universal code parser for source code analysis, by [Francesc Campoy](https://twitter.com/francesc) ([🎥](https://www.youtube.com/watch?v=wywq97vnmmU&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=1&t=394s) / [📈](https://bit.ly/bblfsh-fosdem))
- Migrating code with SmaCC, by [John Brant](https://fosdem.org/2018/schedule/speaker/john_brant/) ([🎥](https://www.youtube.com/watch?v=qGdeoc0EsQ8&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=2) / [📈](https://fosdem.org/2018/schedule/event/code_migrating_code_with_smacc/attachments/slides/2422/export/events/attachments/code_migrating_code_with_smacc/slides/2422/Migrating_code_with_SmaCC.pdf))
- Moldable analysis with Moose, by [Andrei Chis](https://twitter.com/Chis_Andrei) ([🎥](https://www.youtube.com/watch?v=-BBd9dgJcEc&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=3))
- Langkit: source code analyzers for the masses, by [Raphaël Amiard](https://twitter.com/notfonk) and [Pierre-Marie De Rodat](https://twitter.com/pmderodat) ([🎥](https://www.youtube.com/watch?v=Zfn8JZDW77Q&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=4))
- Finding inter-procedural bugs at scale with Infer static analyzer, by Jules Villard ([🎥](https://www.youtube.com/watch?v=DR2ViYTxxOM&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=5) / [📈](https://fosdem.org/2018/schedule/event/code_finding_inter_procedural_bugs_at_scale_with_infer_static_analyzer/attachments/slides/2651/export/events/attachments/code_finding_inter_procedural_bugs_at_scale_with_infer_static_analyzer/slides/2651/infer_fosdem2018.pdf))
- Tree-sitter, by [Max Brunsfeld](https://twitter.com/maxbrunsfeld) ([🎥](https://www.youtube.com/watch?v=0CGzC_iss-8&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=6) / [📈](https://fosdem.org/2018/schedule/event/code_tree_sitter/attachments/slides/2484/export/events/attachments/code_tree_sitter/slides/2484/tree_sitter_fosdem_slides.pdf))
- Parsing Posix [S]hell, by Yann Regis-Gianas ([🎥](https://www.youtube.com/watch?v=fiJR4_059HA&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=7) / [📈](https://fosdem.org/2018/schedule/event/code_parsing_posix_s_hell/attachments/slides/2525/export/events/attachments/code_parsing_posix_s_hell/slides/2525/morbig.pdf))
- JavaParser: where should we head?, by [Federico Tomassetti](https://twitter.com/ftomasse) ([🎥](https://www.youtube.com/watch?v=vsn7BzJLBzo&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=8))
- Graph-based analysis of JavaScript repositories, by [Adam Lippai](https://twitter.com/alippai) ([🎥](https://www.youtube.com/watch?v=dYBURFmH9Xk&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=9) / [📈](https://fosdem.org/2018/schedule/event/code_graph_based_analysis_of_javascript_repositories/attachments/slides/2508/export/events/attachments/code_graph_based_analysis_of_javascript_repositories/slides/2508/fosdem_js_source_code_analysis_alippai.pdf))
- DIY Java Static Analysis, by [Nicolas Peru](https://twitter.com/benzonico) ([🎥](https://www.youtube.com/watch?v=h-7TXKMXn0o&list=PL5Ld68ole7j2H1SnyhDg7DI0fgh0GNuez&index=10) / [📈](https://fosdem.org/2018/schedule/event/code_diy_java_static_analysis/attachments/slides/2054/export/events/attachments/code_diy_java_static_analysis/slides/2054/DIY_Java_static_analysis.pdf))

![A picture of the Source Coce Analysis Devroom](/post/fosdem-2018/sca.jpg)

## But there's more

In addition to managing two devrooms and rewarding all the speakers with good food and cold beer,
two of our employees gave extra talks!

### Tools for large-scale collection and analysis of source code repositories

[Alex Bezzubov](https://twitter.com/seoul_engineer) gave a talk at the HPC, Big Data, and Data Science
Devroom on the tech stack we develop at [sourced{}](https://sourced.tech).

The title of the talk is *Tools for large-scale collection and analysis of source code repositories* and both the
[slides](https://fosdem.org/2018/schedule/event/large_scale_repo_analysis/attachments/slides/2400/export/events/attachments/large_scale_repo_analysis/slides/2400/FOSDEM_18__Tools_for_large_scale_collection_and_analysis_of_source_code_repositories.pdf)
and the [video](https://www.youtube.com/watch?v=2c7QSrIL02o) are already available.

<iframe width="560" height="315" src="https://www.youtube.com/embed/2c7QSrIL02o" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

### Container Linux baremetal provisioning with Terraform, Ignition and Matchbox

One of source{d} infrastructure team engineers,
[Rafa Porres](https://twitter.com/walter_burns/status/960530295891120129),
stayed in Belgium for a bit longer to speak at
[Config Management Camp 2018](http://cfgmgmtcamp.eu/) in Gent.

He gave a great talk titled *Container Linux baremetal provisioning with Terraform, Ignition and Matchbox*.
Unfortunately it was not recorded, but the [slides are available here](https://docs.google.com/presentation/d/e/2PACX-1vRQiwX6sO58fN_wFilvvRSAE_HYkJMbPEq1wlW65F9CSOoINVm5jgTou_JjJjw5r2hujefZoFEmCMqK/pub?start=false&loop=false&delayms=3000&slide=id.p).

## Thanks

Thanks to all of the speakers in our and other devrooms, to the organizers who did an incredible job,
to all those that attended our devrooms, and to those that tried but could not get in!

Let's do it all over in 2019!

#### We want you!

Are you interested on speaking at events about Go or Source Code Analysis?
We are currently organizing events in San Francisco and Madrid, let us know!

You can get in touch with us joining our Slack community (link below), on twitter at
[@sourcedtech](https://twitter.com/sourcedtech), or simply by mail at events@sourced.tech.
Are you insterested on joining source{d}? We want to also hear from you! Check out our
[careers page](https://sourced.tech/careers)!

We're looking forward to hearing from you all!