--- 
author: eiso 
date: 2016-05-19 
title: "Top 100 Women In The Open-Source Community" 
draft: false 
image: /post/top-100-women-in-the-open-source-community/intro.jpg 
description: "A spotlight on 100 amazing women in the open-source community based on data analysis" 
--- 
<link rel="stylesheet" type="text/css" href="/post/top-100-women-in-the-open-source-community/post-style.css">

To give you a bit of background, at source{d} we analyse every Github repository
and run our own version of `git diff` ([go-git](http://github.com/src-d/go-git)) across  900 million
commits. This gives us unique insight into the code published by over 6 million
developers. 

There have been a lot of posts about gender in the development community, we
realised  that we were in a great position to contribute with data. It started
with the question,  how will we determine gender across 6 million developers. We
took the approach of classifying names based on their statistically likelihood
to be either male or female. We started with cleaning up the names used in
commits: separating first names, last names and usernames. Secondly, we went to
look for data sources for name genderization. Which led us to several census
database (UK & USA) and several API's. After a lot of cleaning, we had compiled
a database of over 144,000 names with their: gender, # of occurences and our
statistical likelihood of being correct.

From the 6 million developers who've publicly contributed to Github we were able to
accurately genderize aprox. 2 million. In the coming month, we'll be releasing
different posts and analysis on this data set.

Before we post about percentages, country specific differences and trends over
time, we wanted to take a moment and highlight some of the women who have been
active in the open-source community. This list in no way is exhaustive, and we 
have tried our best to keep it as objective as possible. To do this, we decided 
to first slice our data set on two variables:

1. Total # of commits  
2. Our own version of PageRank*

_*We look at every developer as a node in a graph and every project they
contributed to as an edge, we then weight each edge based on the ratio of # of
bytes contributed to that project. Once we have this graph, we apply the
PageRank algorithm. Please note that this is a reputation metric and is 
hence greatly influenced by the co-contributors across repositories._

We identified every developer whose name we had classified as female, whose total # 
of commits were above 1,000, and ordered based on PageRank. We then manually reviewed
over +1000 Github profiles to ensure that the contributions were open-source
projects. We decided to allow projects from any field (besides computer science 
you'll find bioinformatics and astrophysics represented here). 

The data set used to get to the commit count, is an analysis of the raw pack files 
of every public Git repository on Github until 21st April 2016. Often the counts of 
commits will differ from the Github profiles which seem to use a different method.

We have decided to order on PageRank because it gives an indication of the influence
of each developer in the open-source community. We understand that there are many ways
to order this list and are open to any suggestions. 

We have reached out to every person on this list to ask if they had any objection to 
be included or if they wanted any of their information changed. We are certain that 
we have missed some incredible people and would love to hear from you if we have.

Any suggestions or improvements can be requested on [Github](https://github.com/src-d/blog/issues).

You can also follow the tweets of this incredible list of developers here: Twitter list 

<div style="height: 45px;"><h2>1. Misty De Meo</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/mistydemeo" target="_top"><strong>Misty De Meo</strong></a>
      <img src="http://pbs.twimg.com/profile_images/695096215927521280/Gyl1TuMi_normal.jpg"><span class="location">Based in Vancouver  working at Github</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=mistydemeo" target="_blank" alt="Follow mistydemeo">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/mistydemeo" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3728</strong><span> Total Commits</span></li>
      <li><strong>1873.4</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Makes tools for devs at @github.
Sometime-archivist!!
@machomebrew, @mactigerbrew.
Opinions: mine, &c.
Follow reqs okay!
Avatar by @repoghost!
(see also; @ticky)</div>
    <div class="repo_header"><a href="https://github.com/Homebrew/homebrew-core">homebrew-core</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>732</strong><span> Commits by @mistydemeo</span></li>
      <li><strong>351</strong><span> Stars</span></li>
      <li><strong>26</strong><span> Watchers</span></li>
      <li><strong>582</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">:beers: Core formulae for the Homebrew package manager</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>2. Katrina Owen</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/kytrinyx" target="_top"><strong>Katrina Owen</strong></a>
      <img src="http://pbs.twimg.com/profile_images/651150543927185408/xq5Dy6Z5_normal.jpg"><span class="location">Working at Exercism.io</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=kytrinyx" target="_blank" alt="Follow kytrinyx">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/kytrinyx" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>9137</strong><span> Total Commits</span></li>
      <li><strong>499.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">I make exercism.io</div>
    <div class="repo_header"><a href="https://github.com/exercism/exercism.io">exercism.io</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>3314</strong><span> Commits by @kytrinyx</span></li>
      <li><strong>2109</strong><span> Stars</span></li>
      <li><strong>121</strong><span> Watchers</span></li>
      <li><strong>627</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Level up your programming skills.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>3. Jess Frazelle</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/jfrazelle" target="_top"><strong>Jess Frazelle</strong></a>
      <img src="http://pbs.twimg.com/profile_images/635287771570114560/ALpwsifs_normal.jpg"><span class="location">Based in Falken's Maze</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=jessfraz" target="_blank" alt="Follow jessfraz">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/jfrazelle" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3910</strong><span> Total Commits</span></li>
      <li><strong>438.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">has been called the Keyser Söze of containers, security @mesosphere, the band formerly known as a @docker maintainer</div>
    <div class="repo_header"><a href="https://github.com/docker/engine-api">engine-api</a> <span class="language">Go</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>810</strong><span> Commits by @jfrazelle</span></li>
      <li><strong>156</strong><span> Stars</span></li>
      <li><strong>43</strong><span> Watchers</span></li>
      <li><strong>89</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Go libraries providing client and server components compatible with the Docker engine</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>4. Natalie Weizenbaum</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/nex3" target="_top"><strong>Natalie Weizenbaum</strong></a>
      <img src="http://pbs.twimg.com/profile_images/709190819236880384/xV2PUtsb_normal.jpg"><span class="location">Based in Seattle working at Google</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=nex3" target="_blank" alt="Follow nex3">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/nex3" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>10833</strong><span> Total Commits</span></li>
      <li><strong>369.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Lesbian code gardener. Basically a dryad. Lead designer and developer of @SassCSS, working for @google on @dart_lang. Avatar by @roozuhime.</div>
    <div class="repo_header"><a href="https://github.com/sass/sass">sass</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>4340</strong><span> Commits by @nex3</span></li>
      <li><strong>8010</strong><span> Stars</span></li>
      <li><strong>601</strong><span> Watchers</span></li>
      <li><strong>1572</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Sass makes CSS fun again.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>5. Aria Stewart</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/aredridel" target="_top"><strong>Aria Stewart</strong></a>
      <img src="http://pbs.twimg.com/profile_images/651825569735290880/JRbMsOV2_normal.jpg"><span class="location">Based in Somerville, MA</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=aredridel" target="_blank" alt="Follow aredridel">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/aredridel" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>9589</strong><span> Total Commits</span></li>
      <li><strong>341.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Random internet positive commenter & foul weather friend.

Admin.

Unschooler. www at npmjs.

♥︎ node.js.

nb & woman.</div>
    <div class="repo_header"><a href="https://github.com/aredridel/html5">html5</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>752</strong><span> Commits by @aredridel</span></li>
      <li><strong>524</strong><span> Stars</span></li>
      <li><strong>32</strong><span> Watchers</span></li>
      <li><strong>115</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Event-driven HTML5 Parser in Javascript</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>6. Caitlin Potter</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/caitp" target="_top"><strong>Caitlin Potter</strong></a>
      <img src="http://pbs.twimg.com/profile_images/720445010546700288/4Zu8o3WY_normal.jpg"><span class="location">Working at Igalia</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=caitp88" target="_blank" alt="Follow caitp88">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/caitp" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2479</strong><span> Total Commits</span></li>
      <li><strong>318.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Ballerina by day, ninja chemist by night</div>
    <div class="repo_header"><a href="https://github.com/v8/v8">v8</a> <span class="language">C++</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>97</strong><span> Commits by @caitp</span></li>
      <li><strong>2351</strong><span> Stars</span></li>
      <li><strong>293</strong><span> Watchers</span></li>
      <li><strong>594</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The official mirror of the V8 git repository</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>7. Rebecca Turner</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/iarna" target="_top"><strong>Rebecca Turner</strong></a>
      <img src="http://pbs.twimg.com/profile_images/724367190061780993/VJ6elhjl_normal.jpg"><span class="location">Based in East Bay, CA working at NPM</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=rebeccaorg" target="_blank" alt="Follow rebeccaorg">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/iarna" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3597</strong><span> Total Commits</span></li>
      <li><strong>260.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">open DMs. iarna on github & irc, etc 
–––
Biases: cynically optimistic intersectional feminist pragmatic poly queer trans femininity
–––
work for npm on the cli</div>
    <div class="repo_header"><a href="https://github.com/npm/npm">npm</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>576</strong><span> Commits by @iarna</span></li>
      <li><strong>9354</strong><span> Stars</span></li>
      <li><strong>543</strong><span> Watchers</span></li>
      <li><strong>1929</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">a package manager for javascript</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>8. Julie Ralph</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/juliemr" target="_top"><strong>Julie Ralph</strong></a>
      <img src="http://pbs.twimg.com/profile_images/378800000758804318/868f250839f64926e2ac0ea6d5bb8214_normal.png"><span class="location">Based in Seattle, WA working at Google</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=SomeJulie" target="_blank" alt="Follow SomeJulie">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/juliemr" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1095</strong><span> Total Commits</span></li>
      <li><strong>246.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Protractor for AngularJS, works at Google</div>
    <div class="repo_header"><a href="https://github.com/angular/protractor">protractor</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>683</strong><span> Commits by @juliemr</span></li>
      <li><strong>5421</strong><span> Stars</span></li>
      <li><strong>389</strong><span> Watchers</span></li>
      <li><strong>1210</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">E2E test framework for Angular apps</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>9. Nicole Thomas</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rallytime" target="_top"><strong>Nicole Thomas</strong></a>
      <img src="http://pbs.twimg.com/profile_images/446703175416807424/5BuB4usQ_normal.jpeg"><span class="location">Based in Salt Lake City, Utah working at SaltStack</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=rallytime_nt" target="_blank" alt="Follow rallytime_nt">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rallytime" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3038</strong><span> Total Commits</span></li>
      <li><strong>229.5</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/saltstack/salt">salt</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2792</strong><span> Commits by @rallytime</span></li>
      <li><strong>6536</strong><span> Stars</span></li>
      <li><strong>528</strong><span> Watchers</span></li>
      <li><strong>2899</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Software to automate the management and configuration of any infrastructure or application at scale. Get access to the Salt Open software package repository here: </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>10. Lauren McCarthy</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/lmccart" target="_top"><strong>Lauren McCarthy</strong></a>
      <img src="http://pbs.twimg.com/profile_images/378800000565460833/706acfad0a02e4377702aaa2cb1882aa_normal.jpeg"><span class="location">Based in brooklyn, ny</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=laurmccarthy" target="_blank" alt="Follow laurmccarthy">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/lmccart" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5521</strong><span> Total Commits</span></li>
      <li><strong>181.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">artist, programmer, person. @ITP_NYU faculty, @BerkmanCenter affiliate, @datasociety affiliate, making @p5xjs</div>
    <div class="repo_header"><a href="https://github.com/processing/p5.js">p5.js</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1646</strong><span> Commits by @lmccart</span></li>
      <li><strong>3846</strong><span> Stars</span></li>
      <li><strong>286</strong><span> Watchers</span></li>
      <li><strong>514</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">p5.js is a JS client-side library for creating graphic and interactive experiences, based on the core principles of Processing.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>11. Coraline Ada Ehmke</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/CoralineAda" target="_top"><strong>Coraline Ada Ehmke</strong></a>
      <img src="http://pbs.twimg.com/profile_images/729718993058189315/InraL-v9_normal.jpg"><span class="location">Based in Chicago working at Github</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=CoralineAda" target="_blank" alt="Follow CoralineAda">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/CoralineAda" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3174</strong><span> Total Commits</span></li>
      <li><strong>169.5</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Code witch. Ruby Hero. Speaker, writer, mentor, Ruby Rogues panelist. 'Notorious Social Justice Warrior' --Breitbart. https://t.co/w5rw8bPZXX</div>
    <div class="repo_header"><a href="https://github.com/CoralineAda/alice">alice</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1512</strong><span> Commits by @CoralineAda</span></li>
      <li><strong>10</strong><span> Stars</span></li>
      <li><strong>3</strong><span> Watchers</span></li>
      <li><strong>7</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A spirited and game-loving IRC bot.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>12. Julia Lawall</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/JuliaLawall" target="_top"><strong>Julia Lawall</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/no-avatar.png"><span class="location">Based in France</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/JuliaLawall" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2838</strong><span> Total Commits</span></li>
      <li><strong>156.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">My current research focuses on the design and implementation of domain-specific languages, mostly targetting problems in operating systems. I have also worked on partial evaluation, optimal reduction of the lambda calculus and continuations.</div>
    <div class="repo_header"><a href="https://github.com/coccinelle/coccinelle">coccinelle</a> <span class="language">OCaml</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2838</strong><span> Commits by @JuliaLawall</span></li>
      <li><strong>127</strong><span> Stars</span></li>
      <li><strong>24</strong><span> Watchers</span></li>
      <li><strong>31</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Source code of the Coccinelle project</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>13. Gina Trapani</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/ginatrapani" target="_top"><strong>Gina Trapani</strong></a>
      <img src="http://pbs.twimg.com/profile_images/550825678673682432/YRqb4FJE_normal.png"><span class="location">Based in Brooklyn, New York, USA working at Postlight</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=ginatrapani" target="_blank" alt="Follow ginatrapani">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/ginatrapani" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2903</strong><span> Total Commits</span></li>
      <li><strong>135.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">I build software at @PostlightAgency. I also made @makerbase @thinkup @todotxt & http://narrowthegapp.com. Once upon a time, I started @Lifehacker. #2Q2BSTR8 ‍‍</div>
    <div class="repo_header"><a href="https://github.com/ThinkUpLLC/ThinkUp">ThinkUp</a> <span class="language">PHP</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1941</strong><span> Commits by @ginatrapani</span></li>
      <li><strong>3388</strong><span> Stars</span></li>
      <li><strong>210</strong><span> Watchers</span></li>
      <li><strong>773</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">ThinkUp gives you insights into your social networking activity on Twitter, Facebook, Instagram, and beyond.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>14. Sara Golemon</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/sgolemon" target="_top"><strong>Sara Golemon</strong></a>
      <img src="http://pbs.twimg.com/profile_images/563453422779645952/JVgsjmNx_normal.jpeg"><span class="location">Based in Silicon Valley</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=SaraMG" target="_blank" alt="Follow SaraMG">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/sgolemon" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3339</strong><span> Total Commits</span></li>
      <li><strong>131.4</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">lvl63 Gnomish Compiler Nerd - Working on my dual-runtime specialization.</div>
    <div class="repo_header"><a href="https://github.com/facebook/hhvm">hhvm</a> <span class="language">C++</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>713</strong><span> Commits by @sgolemon</span></li>
      <li><strong>13602</strong><span> Stars</span></li>
      <li><strong>1161</strong><span> Watchers</span></li>
      <li><strong>2500</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A virtual machine designed for executing programs written in Hack and PHP. </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>15. Camilla Berglund</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/elmindreda" target="_top"><strong>Camilla Berglund</strong></a>
      <img src="http://pbs.twimg.com/profile_images/494234179018575876/o0ZVTUsH_normal.png"><span class="location">Based in Sweden working at GLFW</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=elmindreda" target="_blank" alt="Follow elmindreda">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/elmindreda" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>6555</strong><span> Total Commits</span></li>
      <li><strong>125.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">GLFW, OpenGL, Vulkan, rendering, 囲碁, ייִדישקייט, copyfight, etc.</div>
    <div class="repo_header"><a href="https://github.com/glfw/glfw">glfw</a> <span class="language">C</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2654</strong><span> Commits by @elmindreda</span></li>
      <li><strong>1935</strong><span> Stars</span></li>
      <li><strong>245</strong><span> Watchers</span></li>
      <li><strong>523</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A multi-platform library for OpenGL, window and input</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>16. Jo Liss</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/joliss" target="_top"><strong>Jo Liss</strong></a>
      <img src="http://pbs.twimg.com/profile_images/2400062801/kwvv3onjs6z6bg57i0en_normal.png"><span class="location"></span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=jo_liss" target="_blank" alt="Follow jo_liss">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/joliss" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2404</strong><span> Total Commits</span></li>
      <li><strong>116.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Serial entrepreneur. Creator of Broccoli and other open source libraries. Feminist.</div>
    <div class="repo_header"><a href="https://github.com/broccolijs/broccoli">broccoli</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>538</strong><span> Commits by @joliss</span></li>
      <li><strong>2758</strong><span> Stars</span></li>
      <li><strong>104</strong><span> Watchers</span></li>
      <li><strong>165</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Browser compilation library – an asset pipeline for applications that run in the browser</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>17. Jaana Burcu Dogan</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rakyll" target="_top"><strong>Jaana Burcu Dogan</strong></a>
      <img src="http://pbs.twimg.com/profile_images/732669098287497216/XjY2dvBB_normal.jpg"><span class="location">Based in San Francisco, CA working at Google</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=rakyll" target="_blank" alt="Follow rakyll">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rakyll" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2323</strong><span> Total Commits</span></li>
      <li><strong>106.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Hacker at Google. Mostly #golang and occasionally hardware hacking. (Please don't DM, I use telegram and email.)</div>
    <div class="repo_header"><a href="https://github.com/golang/mobile">mobile</a> <span class="language">Go</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>125</strong><span> Commits by @rakyll</span></li>
      <li><strong>1665</strong><span> Stars</span></li>
      <li><strong>249</strong><span> Watchers</span></li>
      <li><strong>196</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">[mirror] Go on Mobile</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>18. Lea Verou</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/leaverou" target="_top"><strong>Lea Verou</strong></a>
      <img src="http://pbs.twimg.com/profile_images/584963092120899586/TxkxQ7Y5_normal.png"><span class="location">Based in Boston, MA working at MIT</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=leaverou" target="_blank" alt="Follow leaverou">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/leaverou" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1817</strong><span> Total Commits</span></li>
      <li><strong>106.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">HCI researcher @MIT_CSAIL, @CSSWG IE, @CSSSecretsBook author, Ex @W3C staff. Made @prismjs @dabblet @prefixfree. I ♥ standards, code, design, UX, life!</div>
    <div class="repo_header"><a href="https://github.com/PrismJS/prism">prism</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>376</strong><span> Commits by @leaverou</span></li>
      <li><strong>3029</strong><span> Stars</span></li>
      <li><strong>86</strong><span> Watchers</span></li>
      <li><strong>426</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Lightweight, robust, elegant syntax highlighting.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>19. Monica Dinculescu</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/notwaldorf" target="_top"><strong>Monica Dinculescu</strong></a>
      <img src="http://pbs.twimg.com/profile_images/643781313665695745/R4-XNNS2_normal.png"><span class="location">Based in Montreal ✈︎ Sun Funcisco ☀️ working at Google</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=notwaldorf" target="_blank" alt="Follow notwaldorf">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/notwaldorf" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2821</strong><span> Total Commits</span></li>
      <li><strong>100.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">✨Emojineer✨ on @polymer & @googlechrome. Looks like she will bite; usually doesn't. Unless you're pizza. Taiwan #1</div>
    <div class="repo_header"><a href="https://github.com/PolymerElements/paper-input">paper-input</a> <span class="language">HTML</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>129</strong><span> Commits by @notwaldorf</span></li>
      <li><strong>30</strong><span> Stars</span></li>
      <li><strong>33</strong><span> Watchers</span></li>
      <li><strong>62</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A Material Design text field</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>20. Audrey Tang</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/audreyt" target="_top"><strong>Audrey Tang</strong></a>
      <img src="http://pbs.twimg.com/profile_images/712752441293295616/FLPx8w0H_normal.jpg"><span class="location">Based in Taipei, Taiwan working at Apple & SocialText</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=audreyt" target="_blank" alt="Follow audreyt">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/audreyt" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>8691</strong><span> Total Commits</span></li>
      <li><strong>95.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Civic hacker @g0vtw. Grew up among Tiananmen exiles. “Conservative Anarchist.”
Consultant @ Apple, OUP and Socialtext.
⛏ #Perl6 #Haskell #EtherCalc #MoeDict</div>
    <div class="repo_header"><a href="https://github.com/audreyt/ethercalc">ethercalc</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>612</strong><span> Commits by @audreyt</span></li>
      <li><strong>1327</strong><span> Stars</span></li>
      <li><strong>96</strong><span> Watchers</span></li>
      <li><strong>243</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Node.js port of Multi-user SocialCalc</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>21. Jeanine Adkisson</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/jneen" target="_top"><strong>Jeanine Adkisson</strong></a>
      <img src="http://pbs.twimg.com/profile_images/644948567065407488/89jFclLW_normal.jpg"><span class="location">Based in Berkeley, CA working at GoodGuide</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=jneen_" target="_blank" alt="Follow jneen_">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/jneen" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3030</strong><span> Total Commits</span></li>
      <li><strong>95.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Gayer than you can possibly imagine. I design languages. ask me about my cool new language @tuliplang. </div>
    <div class="repo_header"><a href="https://github.com/jneen/tulip">tulip</a> <span class="language">Lua</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>141</strong><span> Commits by @jneen</span></li>
      <li><strong>100</strong><span> Stars</span></li>
      <li><strong>21</strong><span> Watchers</span></li>
      <li><strong>5</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Tulip, an untyped functional language which is going to be pretty cool</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>22. Ola Sitarska</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/olasitarska" target="_top"><strong>Ola Sitarska</strong></a>
      <img src="http://pbs.twimg.com/profile_images/702193549945622529/0do9Fuh__normal.jpg"><span class="location">Based in London, UK working at Potato</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=olasitarska" target="_blank" alt="Follow olasitarska">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/olasitarska" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1805</strong><span> Total Commits</span></li>
      <li><strong>95.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">miss radiating enthusiasm. ✨ senior developer @potatolondon, co-founder @djangogirls, organizer @djangoconeurope & @djangounderhood</div>
    <div class="repo_header"><a href="https://github.com/DjangoGirls/djangogirls">djangogirls</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>451</strong><span> Commits by @olasitarska</span></li>
      <li><strong>105</strong><span> Stars</span></li>
      <li><strong>31</strong><span> Watchers</span></li>
      <li><strong>106</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Website for DjangoGirls.org</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>23. Emily Stark</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/estark37" target="_top"><strong>Emily Stark</strong></a>
      <img src="http://pbs.twimg.com/profile_images/378800000153418066/78f6a61d2dc4437687fd12eccfac3d1d_normal.jpeg"><span class="location">Based in San Francisco working at Google</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=estark37" target="_blank" alt="Follow estark37">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/estark37" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1970</strong><span> Total Commits</span></li>
      <li><strong>93.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Security engineer working on @GoogleChrome and Blink, trying to make the web a less scary place. Formerly @meteorjs.</div>
    <div class="repo_header"><a href="https://github.com/meteor/meteor">meteor</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1254</strong><span> Commits by @estark37</span></li>
      <li><strong>33882</strong><span> Stars</span></li>
      <li><strong>1931</strong><span> Watchers</span></li>
      <li><strong>4162</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Meteor, the JavaScript App Platform</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>24. Elizabeth Mattijsen</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/lizmat" target="_top"><strong>Elizabeth Mattijsen</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/elizabeth-mattijsen.png"><span class="location">Based in The Netherlands working at Dijkmat</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/lizmat" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5867</strong><span> Total Commits</span></li>
      <li><strong>87.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">In the last 4 (and a bit more) years she has been involved in the development of Perl modules and even contributed a bit to the development of Perl itself. She is an active member of the Dutch Perl community and she also is active as a Perl Monk. At the first Dutch Perl Workshop she gave a presentation about Parsing XML/HTML.</div>
    <div class="repo_header"><a href="https://github.com/rakudo/rakudo">rakudo</a> <span class="language">Perl6</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>3377</strong><span> Commits by @lizmat</span></li>
      <li><strong>769</strong><span> Stars</span></li>
      <li><strong>134</strong><span> Watchers</span></li>
      <li><strong>254</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Rakudo Perl -- Perl 6 on MoarVM and the JVM</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>25. Lindsey Kuper</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/lkuper" target="_top"><strong>Lindsey Kuper</strong></a>
      <img src="http://pbs.twimg.com/profile_images/539312697225932800/OGwFuF0u_normal.jpeg"><span class="location">Based in Santa Clara, CA working at Intel Labs</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=lindsey" target="_blank" alt="Follow lindsey">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/lkuper" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2798</strong><span> Total Commits</span></li>
      <li><strong>87.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">A little bit “Permit yourself to open a book and start reading from anywhere”; a little bit “I HAVE NO TOOLS BECAUSE I'VE DESTROYED MY TOOLS WITH MY TOOLS”.</div>
    <div class="repo_header"><a href="https://github.com/iu-parfunc/lvars">lvars</a> <span class="language">Haskell</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>346</strong><span> Commits by @lkuper</span></li>
      <li><strong>52</strong><span> Stars</span></li>
      <li><strong>32</strong><span> Watchers</span></li>
      <li><strong>6</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The LVish Haskell library </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>26. Colleen Murphy</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/cmurphy" target="_top"><strong>Colleen Murphy</strong></a>
      <img src="http://pbs.twimg.com/profile_images/472945105641291776/_dJTFflB_normal.jpeg"><span class="location">Based in Portland, Oregon working at Hewlett-Packard</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=pdx_krinkle" target="_blank" alt="Follow pdx_krinkle">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/cmurphy" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1752</strong><span> Total Commits</span></li>
      <li><strong>85.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Core reviewer on the OpenStack Puppet Modules team, on the puppet modules subteam on the OpenStack Infrastructure team and chief shepherd for the Infra Cloud project.</div>
    <div class="repo_header"><a href="https://github.com/puppetlabs/modulesync">modulesync</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>125</strong><span> Commits by @cmurphy</span></li>
      <li><strong>48</strong><span> Stars</span></li>
      <li><strong>109</strong><span> Watchers</span></li>
      <li><strong>22</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Synchronize common files between github module repositories.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>27. Eileen McNaughton</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/eileenmcnaughton" target="_top"><strong>Eileen McNaughton</strong></a>
      <img src="http://pbs.twimg.com/profile_images/517423307243524096/O3D_Y3hd_normal.jpeg"><span class="location">Working at Fuzion</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=eileentnaughton" target="_blank" alt="Follow eileentnaughton">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/eileenmcnaughton" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4827</strong><span> Total Commits</span></li>
      <li><strong>80.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Key contributor within the CiviCRM community.</div>
    <div class="repo_header"><a href="https://github.com/civicrm/civicrm-core">civicrm-core</a> <span class="language">PHP</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2614</strong><span> Commits by @eileenmcnaughton</span></li>
      <li><strong>150</strong><span> Stars</span></li>
      <li><strong>38</strong><span> Watchers</span></li>
      <li><strong>416</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">CiviCRM (Core Application and Framework)</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>28. Heather Miller</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/heathermiller" target="_top"><strong>Heather Miller</strong></a>
      <img src="http://pbs.twimg.com/profile_images/1452273043/profilepic_normal.jpg"><span class="location">Based in Lausanne, Switzerland working at LAMP lab @ EPFL</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=heathercmiller" target="_blank" alt="Follow heathercmiller">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/heathermiller" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2762</strong><span> Total Commits</span></li>
      <li><strong>80.5</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Research Scientist, Executive Director of the Scala Center at EPFL. Past life: artist @ Cooper Union</div>
    <div class="repo_header"><a href="https://github.com/scala/scala-lang">scala-lang</a> <span class="language">CSS</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>394</strong><span> Commits by @heathermiller</span></li>
      <li><strong>50</strong><span> Stars</span></li>
      <li><strong>28</strong><span> Watchers</span></li>
      <li><strong>96</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The Scala Website</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>29. Linda</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rhysd" target="_top"><strong>Linda</strong></a>
      <img src="http://pbs.twimg.com/profile_images/3626384430/3a64cf406665c1940d68ab737003605c_normal.jpeg"><span class="location">Based in Tokyo, Japan</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=Linda_pp" target="_blank" alt="Follow Linda_pp">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rhysd" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>7376</strong><span> Total Commits</span></li>
      <li><strong>77.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">ソフトウェアエンジニア (Developer + QA)．趣味で C++，Ruby，TypeScript，Dachs をVimったりする．計算機言語などのプログラミングツールが好き．あと写真も楽しい．犬．</div>
    <div class="repo_header"><a href="https://github.com/rhysd/Dachs">Dachs</a> <span class="language">C++</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1419</strong><span> Commits by @rhysd</span></li>
      <li><strong>34</strong><span> Stars</span></li>
      <li><strong>7</strong><span> Watchers</span></li>
      <li><strong>3</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Dachs; A Doggy :dog: Programming Language written in C++14.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>30. Raquel Vélez</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rockbot" target="_top"><strong>Raquel Vélez</strong></a>
      <img src="http://pbs.twimg.com/profile_images/657044546430177280/47ES_A2x_normal.jpg"><span class="location">Based in Bay Area, CA working at NPM</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=rockbot" target="_blank" alt="Follow rockbot">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rockbot" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1477</strong><span> Total Commits</span></li>
      <li><strong>76.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">purveyor of flan ∙ web wombat at @npmjs ∙ polyglot ∙ co-host of @reactivepod</div>
    <div class="repo_header"><a href="https://github.com/npm/newww">newww</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>927</strong><span> Commits by @rockbot</span></li>
      <li><strong>61</strong><span> Stars</span></li>
      <li><strong>19</strong><span> Watchers</span></li>
      <li><strong>30</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The npm website</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>31. Emily Stolfo</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/estolfo" target="_top"><strong>Emily Stolfo</strong></a>
      <img src="http://pbs.twimg.com/profile_images/643443749893316608/m9LIo18J_normal.png"><span class="location">Based in Berlin working at MongoDB</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=EmStolfo" target="_blank" alt="Follow EmStolfo">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/estolfo" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1283</strong><span> Total Commits</span></li>
      <li><strong>74.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">gem install mongo; gem install mongoid</div>
    <div class="repo_header"><a href="https://github.com/mongodb/mongo-ruby-driver">mongo-ruby-driver</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>894</strong><span> Commits by @estolfo</span></li>
      <li><strong>1254</strong><span> Stars</span></li>
      <li><strong>47</strong><span> Watchers</span></li>
      <li><strong>408</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Ruby driver for MongoDB</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>32. Gina Häußge</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/foosel" target="_top"><strong>Gina Häußge</strong></a>
      <img src="http://pbs.twimg.com/profile_images/729310895940079617/lLvat2_M_normal.jpg"><span class="location">Based in Obertshausen, Germany</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=foosel" target="_blank" alt="Follow foosel">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/foosel" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3234</strong><span> Total Commits</span></li>
      <li><strong>64.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Passionate code monkey, creator of OctoPrint</div>
    <div class="repo_header"><a href="https://github.com/foosel/OctoPrint">OctoPrint</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1754</strong><span> Commits by @foosel</span></li>
      <li><strong>1333</strong><span> Stars</span></li>
      <li><strong>252</strong><span> Watchers</span></li>
      <li><strong>582</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">OctoPrint is the snappy web interface for your 3D printer!</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>33. Margaret Leibovic</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/leibovic" target="_top"><strong>Margaret Leibovic</strong></a>
      <img src="http://pbs.twimg.com/profile_images/601058260406247424/WOn9q0rC_normal.jpg"><span class="location">Based in Toronto, Ontario working at Mozilla</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=mleibovic" target="_blank" alt="Follow mleibovic">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/leibovic" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1330</strong><span> Total Commits</span></li>
      <li><strong>61.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Firefox for Android engineering manager at Mozilla. I like the web, running, and food.</div>
    <div class="repo_header"><a href="https://github.com/mozilla/gecko-dev">gecko-dev</a> <span class="language">Java</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>297</strong><span> Commits by @leibovic</span></li>
      <li><strong>658</strong><span> Stars</span></li>
      <li><strong>105</strong><span> Watchers</span></li>
      <li><strong>806</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Git mirror of the Mercurial gecko repository</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>34. Siri Hansen</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/sirihansen" target="_top"><strong>Siri Hansen</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/no-avatar.png"><span class="location">Based in Stockholm, Sweden working at Ericsson</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/sirihansen" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1397</strong><span> Total Commits</span></li>
      <li><strong>57.4</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/erlang/otp">otp</a> <span class="language">Erlang</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>766</strong><span> Commits by @sirihansen</span></li>
      <li><strong>4546</strong><span> Stars</span></li>
      <li><strong>481</strong><span> Watchers</span></li>
      <li><strong>1312</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Erlang/OTP</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>35. Varya Stepanova</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/varya" target="_top"><strong>Varya Stepanova</strong></a>
      <img src="http://pbs.twimg.com/profile_images/443865798793117696/AEOrym9F_normal.jpeg"><span class="location">Based in Helsinki working at SC5</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=varya_en" target="_blank" alt="Follow varya_en">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/varya" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3834</strong><span> Total Commits</span></li>
      <li><strong>56.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Frontend dev for SC5 (Helsinki). Before was TMG (Amsterdam) and Yandex (Moscow). Truly BEM #b_ adept and a cat fan. For tweets in Russian follow @toivonens.</div>
    <div class="repo_header"><a href="https://github.com/SC5/sc5-styleguide">sc5-styleguide</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>635</strong><span> Commits by @varya</span></li>
      <li><strong>915</strong><span> Stars</span></li>
      <li><strong>58</strong><span> Watchers</span></li>
      <li><strong>119</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Styleguide generator is a handy little tool that helps you generate good looking styleguides from stylesheets using KSS notation</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>36. Soledad Penadés</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/sole" target="_top"><strong>Soledad Penadés</strong></a>
      <img src="http://pbs.twimg.com/profile_images/1536057871/digger_normal.png"><span class="location">Based in London, UK working at Mozilla</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=supersole" target="_blank" alt="Follow supersole">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/sole" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3614</strong><span> Total Commits</span></li>
      <li><strong>55.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">DEVANGENEERING AT @MOZILLA, GIF curator, emoji practitioner, likes music & quiet places</div>
    <div class="repo_header"><a href="https://github.com/sole/rtcamera">rtcamera</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>266</strong><span> Commits by @sole</span></li>
      <li><strong>26</strong><span> Stars</span></li>
      <li><strong>5</strong><span> Watchers</span></li>
      <li><strong>12</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A fun camera app to process images in real time, using Web technologies.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>37. Ashley Williams</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/ashleygwilliams" target="_top"><strong>Ashley Williams</strong></a>
      <img src="http://pbs.twimg.com/profile_images/717057207754428421/CDqYM8eg_normal.jpg"><span class="location">Based in NYC, USA working at NPM</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=ag_dubs" target="_blank" alt="Follow ag_dubs">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/ashleygwilliams" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2558</strong><span> Total Commits</span></li>
      <li><strong>52.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">a mess like this is easily five to ten years ahead of its time. human, @npmjs. @nodejs board of directors. founder, @node_together.</div>
    <div class="repo_header"><a href="https://github.com/bocoup/open-web-fundamentals">open-web-fundamentals</a> <span class="language">CSS</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>78</strong><span> Commits by @ashleygwilliams</span></li>
      <li><strong>20</strong><span> Stars</span></li>
      <li><strong>22</strong><span> Watchers</span></li>
      <li><strong>7</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">a celebration and exploration of the open web, for and by those interested in becoming responsible and informed web- makers and consumers</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>38. Jennifer Bryan</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/jennybc" target="_top"><strong>Jennifer Bryan</strong></a>
      <img src="http://pbs.twimg.com/profile_images/660978605606875137/s3YrJetD_normal.jpg"><span class="location">Based in Vancouver, BC working at University of British Columbia</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=JennyBryan" target="_blank" alt="Follow JennyBryan">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/jennybc" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3143</strong><span> Total Commits</span></li>
      <li><strong>51.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">prof at UBC, humane #rstats, statistics, genomics, teach @STAT545</div>
    <div class="repo_header"><a href="https://github.com/jennybc/googlesheets">googlesheets</a> <span class="language">R</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>491</strong><span> Commits by @jennybc</span></li>
      <li><strong>331</strong><span> Stars</span></li>
      <li><strong>40</strong><span> Watchers</span></li>
      <li><strong>65</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Google Spreadsheets R API</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>39. Rebecca Murphey</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rmurphey" target="_top"><strong>Rebecca Murphey</strong></a>
      <img src="http://pbs.twimg.com/profile_images/504070124509229056/6t-MUDgL_normal.jpeg"><span class="location">Based in Austin, TX working at Indeed</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=rmurphey" target="_blank" alt="Follow rmurphey">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rmurphey" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3250</strong><span> Total Commits</span></li>
      <li><strong>51.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Software engineer @IndeedEng.</div>
    <div class="repo_header"><a href="https://github.com/rmurphey/mulberry">mulberry</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1075</strong><span> Commits by @rmurphey</span></li>
      <li><strong>8</strong><span> Stars</span></li>
      <li><strong>8</strong><span> Watchers</span></li>
      <li><strong>34</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Home of Toura Mulberry, tools and a framework for quickly producing cross-platform mobile applications using Javascript, HTML, CSS, and PhoneGap</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>40. Delisa Mason</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/kattrali" target="_top"><strong>Delisa Mason</strong></a>
      <img src="http://pbs.twimg.com/profile_images/542803639316664320/Jzcs814D_normal.png"><span class="location">Working at BugSnag</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=kattrali" target="_blank" alt="Follow kattrali">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/kattrali" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2321</strong><span> Total Commits</span></li>
      <li><strong>49.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Hacking back in time  

Lead Open Source Engineer @bugsnag</div>
    <div class="repo_header"><a href="https://github.com/danlucraft/redcar">redcar</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>645</strong><span> Commits by @kattrali</span></li>
      <li><strong>1002</strong><span> Stars</span></li>
      <li><strong>52</strong><span> Watchers</span></li>
      <li><strong>160</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A cross-platform programmer's editor written in Ruby.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>41. Nelle Varoquaux</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/NelleV" target="_top"><strong>Nelle Varoquaux</strong></a>
      <img src="http://pbs.twimg.com/profile_images/569716392/twitterProfilePhoto_normal.jpg"><span class="location">Based in Paris working at Center for Computational Biology</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=nvaroqua" target="_blank" alt="Follow nvaroqua">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/NelleV" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1889</strong><span> Total Commits</span></li>
      <li><strong>49.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Currently PHD candidate at MINES ParisTech</div>
    <div class="repo_header"><a href="https://github.com/MarkUsProject/Markus">Markus</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>432</strong><span> Commits by @NelleV</span></li>
      <li><strong>137</strong><span> Stars</span></li>
      <li><strong>11</strong><span> Watchers</span></li>
      <li><strong>172</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Git repository of MarkUs</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>42. Mikayla Hutchinson</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/mhutch" target="_top"><strong>Mikayla Hutchinson</strong></a>
      <img src="http://pbs.twimg.com/profile_images/660886133262319616/CeK5UubM_normal.jpg"><span class="location">Based in Somerville, MA, USA working at Xamarin</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=mjhutchinson" target="_blank" alt="Follow mjhutchinson">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/mhutch" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>7178</strong><span> Total Commits</span></li>
      <li><strong>47.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Xamarin Technical PM, gamedev, silversmith, baker, ratmom. I make tools to help people create wonderful things.</div>
    <div class="repo_header"><a href="https://github.com/mono/monodevelop">monodevelop</a> <span class="language">C#</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>5075</strong><span> Commits by @mhutch</span></li>
      <li><strong>1620</strong><span> Stars</span></li>
      <li><strong>206</strong><span> Watchers</span></li>
      <li><strong>679</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">MonoDevelop is a cross platform IDE mostly aimed at Mono/.NET developers</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>43. Corinna Vinschen</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="" target="_top"><strong>Corinna Vinschen</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/corinna-vinschen.jpeg"><span class="location">Working at RedHat</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button hide" href="" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>12492</strong><span> Total Commits</span></li>
      <li><strong>44.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Lead since mid-2014 on Cygwin at RedHat</div>
    <div class="repo_header"><a href="https://github.com/mirror/newlib-cygwin">newlib-cygwin</a> <span class="language">C</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>5235</strong><span> Commits by @</span></li>
      <li><strong>8</strong><span> Stars</span></li>
      <li><strong>1</strong><span> Watchers</span></li>
      <li><strong>4</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Cygwin newlib mirror </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>44. Sarah Allen</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/ultrasaurus" target="_top"><strong>Sarah Allen</strong></a>
      <img src="http://pbs.twimg.com/profile_images/451707693577682945/6MKmBXjK_normal.jpeg"><span class="location">Based in San Francisco, CA working at 18F</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=ultrasaurus" target="_blank" alt="Follow ultrasaurus">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/ultrasaurus" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2095</strong><span> Total Commits</span></li>
      <li><strong>43.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">I write code, connect pixels and speak truth to make change. @bridgefoundry @mightyverse @18F</div>
    <div class="repo_header"><a href="https://github.com/18F/midas">openopps-platform</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>356</strong><span> Commits by @ultrasaurus</span></li>
      <li><strong>198</strong><span> Stars</span></li>
      <li><strong>47</strong><span> Watchers</span></li>
      <li><strong>116</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Open Opportunities open source platform</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>45. Marian Beermann</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/enkore" target="_top"><strong>Marian Beermann</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/no-avatar.png"><span class="location"></span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/enkore" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1184</strong><span> Total Commits</span></li>
      <li><strong>43.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/enkore/i3pystatus">i3pystatus</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>765</strong><span> Commits by @enkore</span></li>
      <li><strong>229</strong><span> Stars</span></li>
      <li><strong>27</strong><span> Watchers</span></li>
      <li><strong>123</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A complete replacement for i3status</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>46. Carol Nichols</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/carols10cents" target="_top"><strong>Carol Nichols</strong></a>
      <img src="http://pbs.twimg.com/profile_images/446291681252364288/_okxMUY1_normal.jpeg"><span class="location">Based in Pittsburgh working at Think Through Learning</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=Carols10cents" target="_blank" alt="Follow Carols10cents">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/carols10cents" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2871</strong><span> Total Commits</span></li>
      <li><strong>43.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Rust developer. Pittsburgh, tech, music, sports, home improvement. I'm a maker, connector, hugger. All my mistakes/they brought me to you.</div>
    <div class="repo_header"><a href="https://github.com/hotsh/rstat.us">rstat.us</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>508</strong><span> Commits by @carols10cents</span></li>
      <li><strong>747</strong><span> Stars</span></li>
      <li><strong>44</strong><span> Watchers</span></li>
      <li><strong>225</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Simple microblogging network based on the ostatus protocol.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>47. Vanessa Sochat</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/vsoch" target="_top"><strong>Vanessa Sochat</strong></a>
      <img src="http://pbs.twimg.com/profile_images/1033615710/vsoch_normal.jpg"><span class="location">Based in Stanford, CA working at Stanford University</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=vsoch" target="_blank" alt="Follow vsoch">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/vsoch" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3344</strong><span> Total Commits</span></li>
      <li><strong>42.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">PhD student at Standord in Biomedical Informatics</div>
    <div class="repo_header"><a href="https://github.com/expfactory/expfactory-docker">expfactory-docker</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>231</strong><span> Commits by @vsoch</span></li>
      <li><strong>0</strong><span> Stars</span></li>
      <li><strong>3</strong><span> Watchers</span></li>
      <li><strong>4</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">container for deploying behavioral psychology experiments</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>48. Kristina Chodorow</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/kchodorow" target="_top"><strong>Kristina Chodorow</strong></a>
      <img src="http://pbs.twimg.com/profile_images/362414023/n809676_30991415_5620_normal.jpg"><span class="location">Based in New York City working at Google</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=kchodorow" target="_blank" alt="Follow kchodorow">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/kchodorow" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3186</strong><span> Total Commits</span></li>
      <li><strong>41.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Software engineer at Google working on @bazelbuild, author of several O'Reilly books on MongoDB.</div>
    <div class="repo_header"><a href="https://github.com/mongodb/mongo">mongo</a> <span class="language">C++</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>597</strong><span> Commits by @kchodorow</span></li>
      <li><strong>9300</strong><span> Stars</span></li>
      <li><strong>959</strong><span> Watchers</span></li>
      <li><strong>2618</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The Mongo Database</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>49. Lisa Passing</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/lislis" target="_top"><strong>Lisa Passing</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/lisa-passing.png"><span class="location">Based in Berlin, Germany working at Travis CI</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/lislis" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2102</strong><span> Total Commits</span></li>
      <li><strong>39.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Lisa Passing is working as a frontend developer at Travis CI. She's been heavily stalking diaspora* since 2011, organizing monthly user gatherings in Berlin and making merchandise for the community.
</div>
    <div class="repo_header"><a href="https://github.com/travis-ci/travis-web">travis-web</a> <span class="language">CSS</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>964</strong><span> Commits by @lislis</span></li>
      <li><strong>334</strong><span> Stars</span></li>
      <li><strong>36</strong><span> Watchers</span></li>
      <li><strong>150</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The Ember web client for Travis CI</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>50. Alena Prokharchyk</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/alena1108" target="_top"><strong>Alena Prokharchyk</strong></a>
      <img src="http://pbs.twimg.com/profile_images/526072719087910913/5mpnIcdL_normal.png"><span class="location">Based in Mountain View, California working at Rancher Labs</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=lemonjet" target="_blank" alt="Follow lemonjet">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/alena1108" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>6425</strong><span> Total Commits</span></li>
      <li><strong>38.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Software Engineer @Rancher_Labs</div>
    <div class="repo_header"><a href="https://github.com/apache/cloudstack">cloudstack</a> <span class="language">Java</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2142</strong><span> Commits by @alena1108</span></li>
      <li><strong>374</strong><span> Stars</span></li>
      <li><strong>87</strong><span> Watchers</span></li>
      <li><strong>487</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Mirror of Apache Cloudstack</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>51. Katerina Marchán</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/zkat" target="_top"><strong>Katerina Marchán</strong></a>
      <img src="http://pbs.twimg.com/profile_images/726562339319767041/EjdWYRZm_normal.jpg"><span class="location">Based in Oakland, CA working at NPM</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=maybekatz" target="_blank" alt="Follow maybekatz">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/zkat" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>6318</strong><span> Total Commits</span></li>
      <li><strong>37.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Green-haired digital dryad. Boricua. Cook. Game dev. PLT nerd. npm CLI team. Queer/ace/gq.  時々日本語で書ける/hablo español/falo um pouco de BR  https://t.co/ucZRAWkG2S</div>
    <div class="repo_header"><a href="https://github.com/zkat/sheeple">sheeple</a> <span class="language">Common Lisp</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1227</strong><span> Commits by @zkat</span></li>
      <li><strong>51</strong><span> Stars</span></li>
      <li><strong>7</strong><span> Watchers</span></li>
      <li><strong>4</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Cheeky prototypes for Common Lisp</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>52. Abigail Cabunoc Mayes</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/acabunoc" target="_top"><strong>Abigail Cabunoc Mayes</strong></a>
      <img src="http://pbs.twimg.com/profile_images/549828293654876160/tHuO1vnZ_normal.jpeg"><span class="location">Based in Toronto, Canada working at Mozilla</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=abbycabs" target="_blank" alt="Follow abbycabs">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/acabunoc" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4279</strong><span> Total Commits</span></li>
      <li><strong>36.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Lead developer, Mozilla Science Lab (@MozillaScience) (web + science = ♥) alum:@OICR_news @wormbase @uwaterloo // Fully known & truly loved</div>
    <div class="repo_header"><a href="https://github.com/mozillascience/PaperBadger">PaperBadger</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>202</strong><span> Commits by @acabunoc</span></li>
      <li><strong>65</strong><span> Stars</span></li>
      <li><strong>23</strong><span> Watchers</span></li>
      <li><strong>36</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Issuing badges to credit authors for their work on academic papers </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>53. Aswini Sridhar</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/ashumeow" target="_top"><strong>Aswini Sridhar</strong></a>
      <img src="http://pbs.twimg.com/profile_images/447828615338549248/qCMt0tXw_normal.jpeg"><span class="location">Based in Somewhere else still in Earth working at MepServe</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=ashumeow" target="_blank" alt="Follow ashumeow">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/ashumeow" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5027</strong><span> Total Commits</span></li>
      <li><strong>36.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">A Geek who isn't nerdy but an introvert who is workaholic & rarely, a gamer. Loves to scribble, break & code! Music made her love Signals. Books are her buddies</div>
    <div class="repo_header"><a href="https://github.com/Geek-Research-Lab/MeowJS">MeowJS</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1148</strong><span> Commits by @ashumeow</span></li>
      <li><strong>4</strong><span> Stars</span></li>
      <li><strong>2</strong><span> Watchers</span></li>
      <li><strong>1</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A simple fast JavaScript Library</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>54. Karissa McKelvey</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/karissa" target="_top"><strong>Karissa McKelvey</strong></a>
      <img src="http://pbs.twimg.com/profile_images/724943710908256256/cKJ3qP7H_normal.jpg"><span class="location">Based in Oakland, CA working at US Open Data</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=okdistribute" target="_blank" alt="Follow okdistribute">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/karissa" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4113</strong><span> Total Commits</span></li>
      <li><strong>36.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Mad science with @dat_project during the day, trumpet at night</div>
    <div class="repo_header"><a href="https://github.com/maxogden/dat">dat</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>390</strong><span> Commits by @karissa</span></li>
      <li><strong>4374</strong><span> Stars</span></li>
      <li><strong>286</strong><span> Watchers</span></li>
      <li><strong>281</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">:floppy_disk: open source peer to peer data sharing</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>55. Jessica B. Hamrick</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/jhamrick" target="_top"><strong>Jessica B. Hamrick</strong></a>
      <img src="http://pbs.twimg.com/profile_images/2907249863/bb82aadc2644b9e044f5d04dfd910b9b_normal.jpeg"><span class="location">Based in Berkeley, CA working at UC Berkeley</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=jhamrick" target="_blank" alt="Follow jhamrick">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/jhamrick" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5259</strong><span> Total Commits</span></li>
      <li><strong>34.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Bayesian, pythonista, cognitive scientist, feminist. IPython and Jupyter, too.</div>
    <div class="repo_header"><a href="https://github.com/jupyter/nbgrader">nbgrader</a> <span class="language">HTML</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>213</strong><span> Commits by @jhamrick</span></li>
      <li><strong>161</strong><span> Stars</span></li>
      <li><strong>15</strong><span> Watchers</span></li>
      <li><strong>43</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A system for assigning and grading notebooks</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>56. Marina Glancy</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/marinaglancy" target="_top"><strong>Marina Glancy</strong></a>
      <img src="http://pbs.twimg.com/profile_images/461503093855637504/PT9t9q-F_normal.jpeg"><span class="location">Working at Moodle</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=marinaglancy" target="_blank" alt="Follow marinaglancy">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/marinaglancy" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2252</strong><span> Total Commits</span></li>
      <li><strong>32.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Working on the core team at Moodle.</div>
    <div class="repo_header"><a href="https://github.com/iomad/iomad">iomad</a> <span class="language">PHP</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1404</strong><span> Commits by @marinaglancy</span></li>
      <li><strong>22</strong><span> Stars</span></li>
      <li><strong>23</strong><span> Watchers</span></li>
      <li><strong>20</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Iomad</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>57. Alison Gianotto</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/snipe" target="_top"><strong>Alison Gianotto</strong></a>
      <img src="http://pbs.twimg.com/profile_images/545415835675033600/gDuSi44o_normal.jpeg"><span class="location">Based in NYC expat in San Diego, CA working at Grokability</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=snipeyhead" target="_blank" alt="Follow snipeyhead">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/snipe" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2945</strong><span> Total Commits</span></li>
      <li><strong>31.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Hacker, co-founder/CTO @MassMosaic, creator Snipe-IT, CEO of Grokability, open sourcerer, author, speaker, devops, infosec, atheist, chaotic neutral, ENTP, NSFW</div>
    <div class="repo_header"><a href="https://github.com/snipe/snipe-it">snipe-it</a> <span class="language">PHP</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2400</strong><span> Commits by @snipe</span></li>
      <li><strong>751</strong><span> Stars</span></li>
      <li><strong>123</strong><span> Watchers</span></li>
      <li><strong>366</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A free open source IT asset/license management system built in PHP on Laravel 4.2 and Bootstrap 3. </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>58. Evadne Wu</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/evadne" target="_top"><strong>Evadne Wu</strong></a>
      <img src="http://pbs.twimg.com/profile_images/2246294748/6603BCF2-2CDC-45B8-981C-FFA56AEB7329_normal"><span class="location">Based in SYD / HND / YVR / LHR working at Faria Systems</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=evadne" target="_blank" alt="Follow evadne">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/evadne" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>7394</strong><span> Total Commits</span></li>
      <li><strong>30.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">HCI & Software Architecture / Visa Collector / Open Source Contributor / International Women of Mystery</div>
    <div class="repo_header"><a href="https://github.com/waveface/Partio-iOS">Partio-iOS</a> <span class="language">Objective-C</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>4455</strong><span> Commits by @evadne</span></li>
      <li><strong>0</strong><span> Stars</span></li>
      <li><strong>10</strong><span> Watchers</span></li>
      <li><strong>1</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Partio is a Latin verb meaning "to share", which is exactly what we are going to do</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>59. Erin Braswell</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/erinspace" target="_top"><strong>Erin Braswell</strong></a>
      <img src="http://pbs.twimg.com/profile_images/3262809538/3724f2d31e8ae55d0b89e2f7cef5f95f_normal.jpeg"><span class="location">Based in Charlottesville, VA working at Center for Open Science</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=erinbspace" target="_blank" alt="Follow erinbspace">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/erinspace" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5168</strong><span> Total Commits</span></li>
      <li><strong>30.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Lover of all things astronomy, science and computers; professional wrestling enthusiast</div>
    <div class="repo_header"><a href="https://github.com/fabianvf/scrapi">scrapi</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1926</strong><span> Commits by @erinspace</span></li>
      <li><strong>0</strong><span> Stars</span></li>
      <li><strong>1</strong><span> Watchers</span></li>
      <li><strong>1</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A data processing pipeline that schedules and runs content harvesters, normalizes their data, and outputs that normalized data to a variety of output streams. This is part of the SHARE project, and will be used to create a free and open dataset of research (meta)data. Data collected can be explored at https://osf.io/share/, and viewed at https://osf.io/api/v1/share/search/. Developer docs can be viewed at https://osf.io/wur56/wiki</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>60. Katharine Berry</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/Katharine" target="_top"><strong>Katharine Berry</strong></a>
      <img src="http://pbs.twimg.com/profile_images/3630087303/66bcb76a9ce7da35ab4d5ff13e3f2716_normal.jpeg"><span class="location">Based in Redwood City, CA working at Pebble Technology</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=KatharineBerry" target="_blank" alt="Follow KatharineBerry">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/Katharine" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2669</strong><span> Total Commits</span></li>
      <li><strong>29.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Developer Tooling Lead and Sparkly Code Princess at @Pebble.

Almost certainly insane.</div>
    <div class="repo_header"><a href="https://github.com/pebble/cloudpebble">cloudpebble</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1097</strong><span> Commits by @Katharine</span></li>
      <li><strong>145</strong><span> Stars</span></li>
      <li><strong>64</strong><span> Watchers</span></li>
      <li><strong>33</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">CloudPebble source. Here be dragons.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>61. Joanna Rutkowska</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rootkovska" target="_top"><strong>Joanna Rutkowska</strong></a>
      <img src="http://pbs.twimg.com/profile_images/498767272744202243/szRTjdOX_normal.jpeg"><span class="location">Based in Warsaw working at Invisible Things Lab & QubesOS</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=rootkovska" target="_blank" alt="Follow rootkovska">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rootkovska" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5618</strong><span> Total Commits</span></li>
      <li><strong>24.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Founder of Invisible Things Lab and @QubesOS</div>
    <div class="repo_header"><a href="https://github.com/QubesOS/qubes-core-admin">qubes-core-admin</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>497</strong><span> Commits by @rootkovska</span></li>
      <li><strong>15</strong><span> Stars</span></li>
      <li><strong>9</strong><span> Watchers</span></li>
      <li><strong>22</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Qubes component: core-admin</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>62. Melissa Linkert</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/melissalinkert" target="_top"><strong>Melissa Linkert</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/melissa-linkert.jpeg"><span class="location">Working at Glencoe Software</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=melissa_linkert" target="_blank" alt="Follow melissa_linkert">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/melissalinkert" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>13534</strong><span> Total Commits</span></li>
      <li><strong>24.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Interested in the Open Microscopy Environment</div>
    <div class="repo_header"><a href="https://github.com/openmicroscopy/bioformats">bioformats</a> <span class="language">Java</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>6759</strong><span> Commits by @melissalinkert</span></li>
      <li><strong>101</strong><span> Stars</span></li>
      <li><strong>13</strong><span> Watchers</span></li>
      <li><strong>129</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Bio-Formats is a Java library for reading and writing data in life sciences image file formats. It is developed by the  Open Microscopy Environment (particularly  UW-Madison LOCI and  Glencoe Software). Bio-Formats is released under the  GNU General Public License (GPL); commercial licenses are available from  Glencoe Software. </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>63. Corinne Krych</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/corinnekrych" target="_top"><strong>Corinne Krych</strong></a>
      <img src="http://pbs.twimg.com/profile_images/1804433301/corinne_1__normal.png"><span class="location">Based in French Riviera working at Red Hat</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=corinnekrych" target="_blank" alt="Follow corinnekrych">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/corinnekrych" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2743</strong><span> Total Commits</span></li>
      <li><strong>23.5</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Mobile - HTML5 - iOS - AeroGear - RHMAP Client SDK tech lead - Red Hat</div>
    <div class="repo_header"><a href="https://github.com/aerogear/aerogear-ios-cookbook">aerogear-ios-cookbook</a> <span class="language">Swift</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>264</strong><span> Commits by @corinnekrych</span></li>
      <li><strong>14</strong><span> Stars</span></li>
      <li><strong>26</strong><span> Watchers</span></li>
      <li><strong>18</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The AeroGear iOS cookbook is a list of recipes to quick start your iOS AeroGear experience. Each recipe is a complete iOS app.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>64. Rebecca Sutton Koeser</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rlskoeser" target="_top"><strong>Rebecca Sutton Koeser</strong></a>
      <img src="http://pbs.twimg.com/profile_images/378800000211609542/3ebe6b1a1fe4c57741c55cfa74cb7366_normal.png"><span class="location">Based in Atlanta, Georgia, USA working at Emory University Libraries</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=suttonkoeser" target="_blank" alt="Follow suttonkoeser">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rlskoeser" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>6425</strong><span> Total Commits</span></li>
      <li><strong>23.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Software Engineer, PhD in English Literature; digital libraries/digital humanities.  Python programmer, reader, gamer, gadget girl, mother.</div>
    <div class="repo_header"><a href="https://github.com/emory-libraries/readux">readux</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>792</strong><span> Commits by @rlskoeser</span></li>
      <li><strong>5</strong><span> Stars</span></li>
      <li><strong>9</strong><span> Watchers</span></li>
      <li><strong>1</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Django web application to display, annotate, and export digitized books in a Fedora Commons repository</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>65. Melanie Warrick</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/nyghtowl" target="_top"><strong>Melanie Warrick</strong></a>
      <img src="http://pbs.twimg.com/profile_images/3649874017/b1bd533fab6633b705c7a583cba4f07a_normal.jpeg"><span class="location">Based in SF working at Skymind.io</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=nyghtowl" target="_blank" alt="Follow nyghtowl">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/nyghtowl" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4886</strong><span> Total Commits</span></li>
      <li><strong>23.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Deep Learning Engineer at Skymind. I want to make tech sapient.</div>
    <div class="repo_header"><a href="https://github.com/deeplearning4j/nd4j">nd4j</a> <span class="language">Java</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>58</strong><span> Commits by @nyghtowl</span></li>
      <li><strong>390</strong><span> Stars</span></li>
      <li><strong>60</strong><span> Watchers</span></li>
      <li><strong>189</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Fast, Scientific and Numerical Computing for the JVM (NDArrays)</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>66. Louise Crow</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/crowbot" target="_top"><strong>Louise Crow</strong></a>
      <img src="http://pbs.twimg.com/profile_images/19826292/450870060_e593f305fd_s_normal.jpg"><span class="location">Based in London (Peckham) working at mySociety</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=crowbot" target="_blank" alt="Follow crowbot">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/crowbot" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>8317</strong><span> Total Commits</span></li>
      <li><strong>23.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">developer for @mySociety, working on Alaveteli, the FOI software behind @WhatDoTheyKnow. Live in Peckham. Personal account.</div>
    <div class="repo_header"><a href="https://github.com/mysociety/fixmytransport">fixmytransport</a> <span class="language">Ruby</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>3073</strong><span> Commits by @crowbot</span></li>
      <li><strong>39</strong><span> Stars</span></li>
      <li><strong>16</strong><span> Watchers</span></li>
      <li><strong>13</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A site focussed on connecting and empowering people who share transport problems of different kinds.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>67. Lilia Markham</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/liliakai" target="_top"><strong>Lilia Markham</strong></a>
      <img src="http://pbs.twimg.com/profile_images/116727166/me_normal.jpg"><span class="location">Based in Open Whisper Systems working at Open WhisperSystems</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=liliakai" target="_blank" alt="Follow liliakai">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/liliakai" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2048</strong><span> Total Commits</span></li>
      <li><strong>23.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">ləˈlē-ə ˈkaɪ</div>
    <div class="repo_header"><a href="https://github.com/WhisperSystems/TextSecure-Browser">Signal-Desktop</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1502</strong><span> Commits by @liliakai</span></li>
      <li><strong>1592</strong><span> Stars</span></li>
      <li><strong>179</strong><span> Watchers</span></li>
      <li><strong>227</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Signal Private Messenger for the Desktop</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>68. Amanda Shih</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/pandafulmanda" target="_top"><strong>Amanda Shih</strong></a>
      <img src="http://pbs.twimg.com/profile_images/546906721554145280/6zxoznyM_normal.jpeg"><span class="location">Based in Houstan, Texas working at OpenStax</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=pandafulmanda" target="_blank" alt="Follow pandafulmanda">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/pandafulmanda" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2743</strong><span> Total Commits</span></li>
      <li><strong>21.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/openstax/tutor-js">tutor-js</a> <span class="language">CoffeeScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1097</strong><span> Commits by @pandafulmanda</span></li>
      <li><strong>5</strong><span> Stars</span></li>
      <li><strong>30</strong><span> Watchers</span></li>
      <li><strong>2</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">:mortar_board: Javascript frontend for openstax tutor</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>69. Jana Beck</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/jebeck" target="_top"><strong>Jana Beck</strong></a>
      <img src="http://pbs.twimg.com/profile_images/729810331434913793/JpOmuQch_normal.jpg"><span class="location">Based in Bay Area, CA working at Tidepool</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=ipancreas" target="_blank" alt="Follow ipancreas">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/jebeck" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4220</strong><span> Total Commits</span></li>
      <li><strong>20.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">PWD (type 1). Avid QuantifiedSelfer with interests in data visualization, statistics, gamification. Coffee snob. (Slow) runner. Bike commuter.</div>
    <div class="repo_header"><a href="https://github.com/tidepool-org/tideline">tideline</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1624</strong><span> Commits by @jebeck</span></li>
      <li><strong>25</strong><span> Stars</span></li>
      <li><strong>29</strong><span> Watchers</span></li>
      <li><strong>11</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Library for Tidepool's timeline-style diabetes data visualization(s) used in Blip</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>70. Danielle Madeley</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/danni" target="_top"><strong>Danielle Madeley</strong></a>
      <img src="http://pbs.twimg.com/profile_images/378800000644838767/fe1075e8ef820187f9fc301a185537bc_normal.jpeg"><span class="location">Based in Melbourne, Australia working at Squareweave</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=dannipenguin" target="_blank" alt="Follow dannipenguin">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/danni" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2133</strong><span> Total Commits</span></li>
      <li><strong>20.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Crosslegged on the front lawn. She's had a bad pill.</div>
    <div class="repo_header"><a href="https://github.com/GNOME/empathy">empathy</a> <span class="language">C</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>366</strong><span> Commits by @danni</span></li>
      <li><strong>23</strong><span> Stars</span></li>
      <li><strong>4</strong><span> Watchers</span></li>
      <li><strong>16</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Empathy IM Client</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>71. Mary Rose Cook</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/maryrosecook" target="_top"><strong>Mary Rose Cook</strong></a>
      <img src="http://pbs.twimg.com/profile_images/513365278135025664/dQ8Zo9FG_normal.jpeg"><span class="location">Based in London, England working at Code Lauren </span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=maryrosecook" target="_blank" alt="Follow maryrosecook">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/maryrosecook" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5272</strong><span> Total Commits</span></li>
      <li><strong>19.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">I’m making Code Lauren (game programming for beginners). I made Gitlet, Isla, Empty Black and Pistol Slut.</div>
    <div class="repo_header"><a href="https://github.com/maryrosecook/gitlet">gitlet</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>952</strong><span> Commits by @maryrosecook</span></li>
      <li><strong>1325</strong><span> Stars</span></li>
      <li><strong>42</strong><span> Watchers</span></li>
      <li><strong>82</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Git implemented in JavaScript</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>72. Alice Zoë Bevan-McGregor</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/amcgregor" target="_top"><strong>Alice Zoë Bevan-McGregor</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/alice-zoe-bevan-mcgregor.jpeg"><span class="location">Based in Montreal, Canada working at Illico Hodes</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=GothAlice" target="_blank" alt="Follow GothAlice">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/amcgregor" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2738</strong><span> Total Commits</span></li>
      <li><strong>19.5</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Currently leading a small international development team working on a WebCore (Python) job distribution and analytics platform powered by MongoDB.</div>
    <div class="repo_header"><a href="https://github.com/marrow/WebCore">WebCore</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>328</strong><span> Commits by @amcgregor</span></li>
      <li><strong>52</strong><span> Stars</span></li>
      <li><strong>9</strong><span> Watchers</span></li>
      <li><strong>7</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">WebCore, the super tiny and blazingly fast modular Python web nanoframework. We offer a dependency graphing extension system, MVC separation, reusable namespaces, and universal URL dispatch protocol with tight WebOb integration and natural Python semantics in a few hundred lines of code.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>73. Isis Agora Lovecruft</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/isislovecruft" target="_top"><strong>Isis Agora Lovecruft</strong></a>
      <img src="http://pbs.twimg.com/profile_images/2726879247/c650a4ac75330afbacee3fc52d56a29b_normal.jpeg"><span class="location">Based in 4096R/A3ADB67A2CDB8B35 working at The Tor Project</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=isislovecruft" target="_blank" alt="Follow isislovecruft">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/isislovecruft" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>7040</strong><span> Total Commits</span></li>
      <li><strong>19.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Anarchist; hacker; physicist. Core developer @torproject: #Tor bridges, #censorship circumvention, sometimes Tor Browser. they/their. !آزادی بیان برای همه</div>
    <div class="repo_header"><a href="https://github.com/isislovecruft/bridgedb">bridgedb</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1834</strong><span> Commits by @isislovecruft</span></li>
      <li><strong>1</strong><span> Stars</span></li>
      <li><strong>2</strong><span> Watchers</span></li>
      <li><strong>1</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Personal development fork of https://git.torproject.org/bridgedb.git. Don't clone this copy of the repo, or I'll happily rebase branches out from under you. Clone https://git.torproject.org/user/isis/bridgedb.git instead.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>74. Sarah Bird</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/birdsarah" target="_top"><strong>Sarah Bird</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/sarah-bird.jpeg"><span class="location">Based in Oakland, CA working at Continuum Analytics</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/birdsarah" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2391</strong><span> Total Commits</span></li>
      <li><strong>19.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Developing Bokeh - an open source data visualization library</div>
    <div class="repo_header"><a href="https://github.com/moneypenny/blicblock-js">blicblock-js</a> <span class="language">Javascript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>235</strong><span> Commits by @birdsarah</span></li>
      <li><strong>4</strong><span> Stars</span></li>
      <li><strong>2</strong><span> Watchers</span></li>
      <li><strong>2</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A JavaScript implementation of the Blicblock game from The Sims 4.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>75. Maira Bello</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/mairatma" target="_top"><strong>Maira Bello</strong></a>
      <img src="http://pbs.twimg.com/profile_images/449184421522833408/vE97maMs_normal.jpeg"><span class="location">Working at Liferay</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=mairatma" target="_blank" alt="Follow mairatma">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/mairatma" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2853</strong><span> Total Commits</span></li>
      <li><strong>17.4</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/alloyui/core">metal.js</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>451</strong><span> Commits by @mairatma</span></li>
      <li><strong>58</strong><span> Stars</span></li>
      <li><strong>18</strong><span> Watchers</span></li>
      <li><strong>22</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Build UI components in a solid, flexible way</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>76. Heather Piwowar</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/hpiwowar" target="_top"><strong>Heather Piwowar</strong></a>
      <img src="https://pbs.twimg.com/profile_images/519570521/heather_new_haircut_bigger.jpg"><span class="location">Working at Impactstory</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=researchremix" target="_blank" alt="Follow researchremix">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/hpiwowar" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4854</strong><span> Total Commits</span></li>
      <li><strong>17.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">cofounder of @impactstory: learn the full impact of your research. Research passion: measuring data sharing and reuse. Adore cookies+cycling+reading+my fam.</div>
    <div class="repo_header"><a href="https://github.com/total-impact/total-impact-core">total-impact-core</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1757</strong><span> Commits by @hpiwowar</span></li>
      <li><strong>54</strong><span> Stars</span></li>
      <li><strong>12</strong><span> Watchers</span></li>
      <li><strong>9</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">An api and backend code to gather the impacts of diverse scholarly products online.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>77. Maria Grazia Alastra</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/MariagraziaAlastra" target="_top"><strong>Maria Grazia Alastra</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/maria-grazia-alastra.jpeg"><span class="location"></span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/MariagraziaAlastra" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2427</strong><span> Total Commits</span></li>
      <li><strong>17.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Core contributor to the DuckDuckGo - Community Platform</div>
    <div class="repo_header"><a href="https://github.com/duckduckgo/community-platform">community-platform</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2067</strong><span> Commits by @MariagraziaAlastra</span></li>
      <li><strong>419</strong><span> Stars</span></li>
      <li><strong>70</strong><span> Watchers</span></li>
      <li><strong>117</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">DuckDuckGo Community Platform</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>78. Nada Amin</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/namin" target="_top"><strong>Nada Amin</strong></a>
      <img src="http://pbs.twimg.com/profile_images/564694579543166976/lW7ec0h6_normal.jpeg"><span class="location">Based in Geneva, Switzerland working at LAMP lab @ EPFL</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=nadamin" target="_blank" alt="Follow nadamin">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/namin" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>5618</strong><span> Total Commits</span></li>
      <li><strong>16.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/TiarkRompf/minidot">minidot</a> <span class="language">Coq</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1785</strong><span> Commits by @namin</span></li>
      <li><strong>15</strong><span> Stars</span></li>
      <li><strong>5</strong><span> Watchers</span></li>
      <li><strong>0</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Dependent Object Types (DOT), bottom up</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>79. Sarah Vessels</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/cheshire137" target="_top"><strong>Sarah Vessels</strong></a>
      <img src="http://pbs.twimg.com/profile_images/716116943913267200/fi6YRHKU_normal.jpg"><span class="location">Based in Nashville, TN working at Github</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=cheshire137" target="_blank" alt="Follow cheshire137">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/cheshire137" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2553</strong><span> Total Commits</span></li>
      <li><strong>16.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Tea drinker, gamer, developer at GitHub. Find me at https://t.co/KnsiOll0fP</div>
    <div class="repo_header"><a href="https://github.com/moneypenny/blicblock-js">blicblock-js</a> <span class="language">CSS</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>235</strong><span> Commits by @cheshire137</span></li>
      <li><strong>4</strong><span> Stars</span></li>
      <li><strong>2</strong><span> Watchers</span></li>
      <li><strong>2</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A JavaScript implementation of the Blicblock game from The Sims 4.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>80. Olga Botvinnik</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/olgabot" target="_top"><strong>Olga Botvinnik</strong></a>
      <img src="http://pbs.twimg.com/profile_images/596720676276342784/HQWFRIVq_normal.jpg"><span class="location">Based in San Diego, CA working at UCSD</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=olgabot" target="_blank" alt="Follow olgabot">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/olgabot" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4172</strong><span> Total Commits</span></li>
      <li><strong>15.4</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">@MIT, @UCSC Alumna. PhD student in Bioinformatics @UCSanDiego. Data dula. Beware of opinions on: Python, open science, dataviz, yoga, fashion, Beyoncé.</div>
    <div class="repo_header"><a href="https://github.com/YeoLab/flotilla">flotilla</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2010</strong><span> Commits by @olgabot</span></li>
      <li><strong>66</strong><span> Stars</span></li>
      <li><strong>36</strong><span> Watchers</span></li>
      <li><strong>15</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Reproducible machine learning analysis of gene expression and alternative splicing data</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>81. Remi Taylor</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/remi" target="_top"><strong>Remi Taylor</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/remi-taylor.jpg"><span class="location">Working at Google</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/remi" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2780</strong><span> Total Commits</span></li>
      <li><strong>15.3</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/remi/clide">clide</a> <span class="language">C#</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>139</strong><span> Commits by @remi</span></li>
      <li><strong>0</strong><span> Stars</span></li>
      <li><strong>1</strong><span> Watchers</span></li>
      <li><strong>0</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Manage .NET (VS) project files from the command-line</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>82. Flavia Missi</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/flaviamissi" target="_top"><strong>Flavia Missi</strong></a>
      <img src="http://pbs.twimg.com/profile_images/584492581012295681/EMEq3obC_normal.jpg"><span class="location">Based in Stockholm, Sweden working at FundedByMe</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=flaviamissi" target="_blank" alt="Follow flaviamissi">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/flaviamissi" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3019</strong><span> Total Commits</span></li>
      <li><strong>15.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Passionate software developer, always seeking for new challenges. Eternal learner. Pythonist from heart, in love with Golang.</div>
    <div class="repo_header"><a href="https://github.com/tsuru/tsuru">tsuru</a> <span class="language">Go</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1195</strong><span> Commits by @flaviamissi</span></li>
      <li><strong>1883</strong><span> Stars</span></li>
      <li><strong>178</strong><span> Watchers</span></li>
      <li><strong>237</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Open source, extensible and Docker-based Platform as a Service (PaaS).</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>83. Christine Spang</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/spang" target="_top"><strong>Christine Spang</strong></a>
      <img src="http://pbs.twimg.com/profile_images/724720803980283904/VSN8D78k_normal.jpg"><span class="location">Based in OAK | SFO working at Nylas</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=spang" target="_blank" alt="Follow spang">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/spang" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2037</strong><span> Total Commits</span></li>
      <li><strong>13.6</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">there's gotta be a better way | cofounder & CTO @nylas | spang@nylas.com</div>
    <div class="repo_header"><a href="https://github.com/nylas/sync-engine">sync-engine</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>956</strong><span> Commits by @spang</span></li>
      <li><strong>2931</strong><span> Stars</span></li>
      <li><strong>153</strong><span> Watchers</span></li>
      <li><strong>254</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">:incoming_envelope: IMAP/SMTP sync system with modern APIs</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>84. Lindsay Young</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/LindsayYoung" target="_top"><strong>Lindsay Young</strong></a>
      <img src="http://pbs.twimg.com/profile_images/655085971164164096/Gou4wYy-_normal.jpg"><span class="location">Based in US working at 18F</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=not_young" target="_blank" alt="Follow not_young">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/LindsayYoung" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2509</strong><span> Total Commits</span></li>
      <li><strong>12.4</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Political data nerd in DC. All opinions belong to strangers. Retweets = marriage proposals.</div>
    <div class="repo_header"><a href="https://github.com/18F/openFEC">openFEC</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1142</strong><span> Commits by @LindsayYoung</span></li>
      <li><strong>148</strong><span> Stars</span></li>
      <li><strong>32</strong><span> Watchers</span></li>
      <li><strong>39</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The first RESTful API for the Federal Election Commission. We're aiming to make campaign finance more accessible for journalists, academics, developers, and other transparency seekers.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>85. Kylie McClain</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/somasis" target="_top"><strong>Kylie McClain</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/kylie-mcclain.png"><span class="location">Based in North Carolina, USA</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/somasis" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2675</strong><span> Total Commits</span></li>
      <li><strong>12.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">My name is Kylie McClain, and I am a 17 year old woman. I have been using computers since I was about three years old, and using Linux since age seven.</div>
    <div class="repo_header"><a href="https://github.com/Somasis/beginning">beginning</a> <span class="language">Shell</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>338</strong><span> Commits by @somasis</span></li>
      <li><strong>22</strong><span> Stars</span></li>
      <li><strong>4</strong><span> Watchers</span></li>
      <li><strong>0</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">an init system that isn't smarter than you</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>86. Laura DeCicco</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/ldecicco-USGS" target="_top"><strong>Laura DeCicco</strong></a>
      <img src="http://pbs.twimg.com/profile_images/637276761609277446/ynePZaMu_normal.jpg"><span class="location">Working at U.S. Geological Survey</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=deciccodonk" target="_blank" alt="Follow deciccodonk">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/ldecicco-USGS" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>4037</strong><span> Total Commits</span></li>
      <li><strong>12.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/USGS-R/dataRetrieval">dataRetrieval</a> <span class="language">R</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1139</strong><span> Commits by @ldecicco-USGS</span></li>
      <li><strong>37</strong><span> Stars</span></li>
      <li><strong>20</strong><span> Watchers</span></li>
      <li><strong>21</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">This R package is designed to obtain its water quality sample data, streamflow data, and metadata directly from either the USGS  or EPA, as well as user-supplied text files.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>87. Anne Lyle</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/ens-ap5" target="_top"><strong>Anne Lyle</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/no-avatar.png"><span class="location">Working at Ensembl.org</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/ens-ap5" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>8422</strong><span> Total Commits</span></li>
      <li><strong>11.7</strong><span> PageRank</span></li>
    </ul>
    <div class="footer"></div>
    <div class="repo_header"><a href="https://github.com/Ensembl/ensembl-webcode">ensembl-webcode</a> <span class="language">Perl</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>6708</strong><span> Commits by @ens-ap5</span></li>
      <li><strong>9</strong><span> Stars</span></li>
      <li><strong>15</strong><span> Watchers</span></li>
      <li><strong>26</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The code to run an Ensembl website</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>88. Kathryn Killebrew</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/flibbertigibbet" target="_top"><strong>Kathryn Killebrew</strong></a>
      <img src="http://pbs.twimg.com/profile_images/677341154237685760/4tnqkYU8_normal.jpg"><span class="location">Based in Philadelphia, PA working at Azavea</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=banderkat" target="_blank" alt="Follow banderkat">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/flibbertigibbet" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>2564</strong><span> Total Commits</span></li>
      <li><strong>10.8</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Software developer and data wrangler.</div>
    <div class="repo_header"><a href="https://github.com/WorldBank-Transport/open-transit-indicators">open-transit-indicators</a> <span class="language">Scala</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>305</strong><span> Commits by @flibbertigibbet</span></li>
      <li><strong>23</strong><span> Stars</span></li>
      <li><strong>21</strong><span> Watchers</span></li>
      <li><strong>14</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">An open-source tool to support transport agencies in planning and managing public transit systems</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>89. Franziska Hinkelmann</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/fhinkel" target="_top"><strong>Franziska Hinkelmann</strong></a>
      <img src="http://pbs.twimg.com/profile_images/661485440751509505/ZnNN9qes_normal.jpg"><span class="location">Based in Munich, Germany working at Google</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=fhinkel" target="_blank" alt="Follow fhinkel">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/fhinkel" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3108</strong><span> Total Commits</span></li>
      <li><strong>10.2</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Mathematician turned software engineer.</div>
    <div class="repo_header"><a href="https://github.com/fhinkel/InteractiveShell">InteractiveShell</a> <span class="language">HTML</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>1069</strong><span> Commits by @fhinkel</span></li>
      <li><strong>6</strong><span> Stars</span></li>
      <li><strong>4</strong><span> Watchers</span></li>
      <li><strong>3</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Build web apps for interactive command-line tools</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>90. Angie Byron</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/webchick" target="_top"><strong>Angie Byron</strong></a>
      <img src="http://pbs.twimg.com/profile_images/468968010976227328/vqMnCLG5_normal.png"><span class="location">Based in Vancouverish, BC working at Acquia</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=webchick" target="_blank" alt="Follow webchick">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/webchick" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>10379</strong><span> Total Commits</span></li>
      <li><strong>10.1</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Herder of cats. @Drupal core committer. Director of Community Development for @Acquia. @OReillyMedia author. @DrupalAssoc. Mom. Lesbionic Ace. Nerd. Gamer.</div>
    <div class="repo_header"><a href="https://github.com/drupal/drupal">drupal</a> <span class="language">PHP</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>3106</strong><span> Commits by @webchick</span></li>
      <li><strong>2233</strong><span> Stars</span></li>
      <li><strong>370</strong><span> Watchers</span></li>
      <li><strong>1074</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Verbatim mirror of the git.drupal.org repository for Drupal core. Changes will not be pulled, and merge requests will not be accepted, if you want to contribute, go to Drupal.org: </div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>91. Rachel Mandelbaum</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/rmandelb" target="_top"><strong>Rachel Mandelbaum</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/rachel-mandelbaum.png"><span class="location">Based in Pittsburgh, Pennsylvania working at Carnegie Mellon University</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/rmandelb" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>3099</strong><span> Total Commits</span></li>
      <li><strong>10.0</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">My research interests are predominantly in the areas of observational cosmology and galaxy studies, with the goal of improving our understanding of dark energy, dark matter, and galaxy formation.</div>
    <div class="repo_header"><a href="https://github.com/GalSim-developers/GalSim">GalSim</a> <span class="language">Python</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>2075</strong><span> Commits by @rmandelb</span></li>
      <li><strong>54</strong><span> Stars</span></li>
      <li><strong>43</strong><span> Watchers</span></li>
      <li><strong>31</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">The modular galaxy image simulation toolkit</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>92. Ada Rose Edwards</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/AdaRoseEdwards" target="_top"><strong>Ada Rose Edwards</strong></a>
      <img src="https://pbs.twimg.com/profile_images/592907703615418369/baa1Upgp_400x400.png"><span class="location">Based in London, UK working at FT Labs</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=lady_ada_king" target="_blank" alt="Follow lady_ada_king">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/AdaRoseEdwards" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1753</strong><span> Total Commits</span></li>
      <li><strong>9.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">JS Dev, Photography and Muay Thai. Developer for the Financial Times. Tumbr: http://sonbr.tumblr.com  (nsfw)</div>
    <div class="repo_header"><a href="https://github.com/AdaRoseEdwards/81">81</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>104</strong><span> Commits by @AdaRoseEdwards</span></li>
      <li><strong>0</strong><span> Stars</span></li>
      <li><strong>1</strong><span> Watchers</span></li>
      <li><strong>0</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Offline First Progressive WebApp with Push Notifications</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>93. Lisa Ballard</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/basilleaf" target="_top"><strong>Lisa Ballard</strong></a>
      <img src="https://pbs.twimg.com/profile_images/539202902825259008/FF3oahiv_400x400.jpeg"><span class="location">Based in San Francisco, CA working at NASA PDS Rings Node, SETI Institute</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=basilleaf" target="_blank" alt="Follow basilleaf">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/basilleaf" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1916</strong><span> Total Commits</span></li>
      <li><strong>9.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">Web dev, hacker, space geek. Science, nature, wildlife, health, social justice. NASASocial Alum. Learning to scuba dive.</div>
    <div class="repo_header"><a href="https://github.com/basilleaf/spaceprob.es">spaceprob.es</a> <span class="language">JavaScript</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>272</strong><span> Commits by @basilleaf</span></li>
      <li><strong>1</strong><span> Stars</span></li>
      <li><strong>2</strong><span> Watchers</span></li>
      <li><strong>1</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">Spaceprob.es catalogs the active human-made machines that freckle our solar system and dot our galaxy</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>94. Emma Strubell</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/strubell" target="_top"><strong>Emma Strubell</strong></a>
      <img src="https://pbs.twimg.com/profile_images/553022864144601089/oliNrQGv_400x400.jpeg"><span class="location">Based in Amherst, MA working at UMass Amherst</span></span>

      <div class="custom-follow-button ">
        <a href="https://twitter.com/intent/user?screen_name=strubell" target="_blank" alt="Follow strubell">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/strubell" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1159</strong><span> Total Commits</span></li>
      <li><strong>9.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">I'm a Ph.D. student at UMass Amherst working in the Information Extraction and Synthesis Laboratory with Professor Andrew McCallum.</div>
    <div class="repo_header"><a href="https://github.com/factorie/factorie">factorie</a> <span class="language">Scala</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>492</strong><span> Commits by @strubell</span></li>
      <li><strong>409</strong><span> Stars</span></li>
      <li><strong>72</strong><span> Watchers</span></li>
      <li><strong>131</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">FACTORIE is a toolkit for deployable probabilistic modeling, implemented as a software library in Scala. It provides its users with a succinct language for creating relational factor graphs, estimating parameters and performing inference.</div>
  </div>
</div>
<div style="height: 5px"></div>

<div style="height: 45px;"><h2>95. Lisa Glendenning</h2></div>    
<div id="user-card">
  <div class="github-card user-card">
    <div class="header">
      <a class="avatar" href="https://github.com/lisaglendenning" target="_top"><strong>Lisa Glendenning</strong></a>
      <img src="/post/top-100-women-in-the-open-source-community/lisa-glendenning.JPG"><span class="location">Based in Seattle, Washington working at University of Washington</span></span>

      <div class="custom-follow-button hide">
        <a href="https://twitter.com/intent/user?screen_name=" target="_blank" alt="Follow ">
          <i class="btn-icon"></i>
          <span class="btn-text">Follow</span>
        </a>
      </div>
      <a class="button " href="https://github.com/lisaglendenning" target="_top">
        <span class="flaticon-circle"></span> Follow
        </a>
    </div>
    <ul class="status">
      <li><strong>1686</strong><span> Total Commits</span></li>
      <li><strong>9.9</strong><span> PageRank</span></li>
    </ul>
    <div class="footer">I am a Ph.D. candidate advised by Thomas Anderson and Arvind Krishnamurthy at the University of Washington. My research focuses on building blocks for fault-tolerant distributed systems.</div>
    <div class="repo_header"><a href="https://github.com/lisaglendenning/zookeeper-lite">zookeeper-lite</a> <span class="language">Java</span> <span class="featured_repo">Featured Repo</span></div>
    <ul class="repo_stats">
      <li><strong>508</strong><span> Commits by @lisaglendenning</span></li>
      <li><strong>5</strong><span> Stars</span></li>
      <li><strong>3</strong><span> Watchers</span></li>
      <li><strong>0</strong><span> Forks</span></li>
    </ul>
    <div class="repo_footer">A "lite" implementation of both the server and client ZooKeeper protocol.</div>
  </div>
</div>
<div style="height: 5px"></div>
