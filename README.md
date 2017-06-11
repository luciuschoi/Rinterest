# Rinterest

: A sample Rails project to demonstrate the Pinterest-like styled page layout.

## Prerequisite

1. System Postgresql installed on local machine

2. Database creation and migration
  ```sh
  $ rails db:create
  $ rails db:migrate
  ```

3. Data seeding
  ```sh
  $ rails db:seed
  ```

4. Start rails server

   ```sh
   $ rails server
   ```

## Browsing

: http://localhost:3000

## Documentation

: http://withrails.com/Rinterest


[`Pinterest`](https://www.pinterest.co.kr/) 서비스는 그 특징적인 웹페이지 레이아웃으로 유명하다. 한번도 본 적이 없다면 지금 바로 웹사이트를 방문해 보기 바란다.

![](https://medrails.files.wordpress.com/2017/06/pin_website-2.png?w=1680)

아래의 동영상을 보면 `Pinterest`에 대한 간단한 소개를 볼 수 있다.

https://youtu.be/1QkMOdW0Kyc

이 글에서는 `Pinterest`에 대한 설명을 하려는 것이 아니고 앞서 언급했던 `Pinterest` 방식의 페이지 레이아웃을 레일스 프로젝트에서 적용하는 방법을 소개하고자 한다.
<!--more-->
웹개발자라면 Masonry([https://masonry.desandro.com/](https://masonry.desandro.com/)) 그리드 레이아웃 라이브러리를 한번 쯤은 들어 봤거나 실제로 웹페이지 레이아웃으로 구현해 사용해 봤을 정도로 유명하다.

레일스 프로젝트에서도 물론 이 라이브러리를 이용하여 데이터를 멋지게 뿌려줄 수 있다.이 글에서는 이 작업을 하고자 하는 것이다.

가장 먼저 **Masonry** 라이브러리를 레일스용 젬으로 만든 것이 있는지 알아 보면, 젬 2개 정도를 찾을 수 있다.  

* [TheDonDope/jquery-masonry-rails](https://github.com/TheDonDope)
* [kristianmandrup/masonry-rails](https://github.com/kristianmandrup)


`masonry-rails` 젬은 4년전에 업데이트가 중단된 상태이고 **Masonry** 버전도 2.x 로 최신 버전(4.x)이 아니다. 반면에 `jquery-masonry-rails` 젬은 최신 갱신일이 10개월전이며 **Masonry** 버전도 최신 버전이어서 이 젬을 사용하기로 한다.

그러나 사용법은 `masonry-rails` 젬 [README.md](https://github.com/kristianmandrup/masonry-rails/blob/master/README.md) 파일 내용을 참고하였다.



## 개발환경

: macOS Sierra 10.12.5, 루비 2.4.1, 레일스 5.1.1, Postgresql 9.6.3 버전

![](https://medrails.files.wordpress.com/2017/06/local_machine-2.png)

참고로 저자의 개발환경을 터미널에서 확인하면 다음과 같다.

```sh
$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.12.5
BuildVersion:	16F73

$ ruby -v
ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-darwin16]

$ rails -v
Rails 5.1.1

$ psql --version
psql (PostgreSQL) 9.6.3
```



## 토이 프로젝트 생성

효과적인 설명을 위해 `Rinterest` 라는 임의의 프로젝트를 생성한다.

```sh
$ rails new Rinterest -d postgresql
```

이제 터미널에서 `rails server` 명령을 실행하고 브라우저에서 http://localhost:3000 으로 접속하면, 다음과 같은 브라우저 화면이 보이게 된다. 우스게 소리지만 레일스를 처음 접하는 초급자들 중 **public/index.html** 파일을 찾아보려 할지도 모르겠다. ^^

![](https://medrails.files.wordpress.com/2017/06/smoke_page-2.png?w=1680)

`Post` 리소스를 `scaffold` **제너레이터** 를 사용하여 생성하고 데이터베이스를 생성한 후 마이그레이션 한다.

```sh
$ rails generate scaffold Post title content:text
$ rails db:create
$ rails db:migrate
```



## 테스트 데이터의 생성

다음으로 테스트 데이터를 생성하기 위해 `fake` 젬을 추가하고,

```ruby
···
group :development, :test do
 gem 'fake'
end
···
```

번들 인스톨한다.

```sh
$ bundle install
```

그리고 `db/seeds.rb` 파일을 열고, 다음과 같이 추가한 후  

```ruby
Faker::Config.locale = 'ko'
100.times do
 Post.create! title: Faker::Lorem.sentence,
              content: Faker::Lorem.paragraph(3)
end
```

터미널에서 다음과 같이 명령을 실행한다.

```sh
$ rails db:seed
```

> **주의** : `rake db:seed`  명령도 정확히 같은 작업을 수행한다.

제대로 데이터가 추가되었는지 확인하기 위해 다음과 같이 명령을 실행하고,

```sh
$ rails console
Running via Spring preloader in process 49199
Loading development environment (Rails 5.1.1)
>> Post.count
  (0.5ms)  SELECT COUNT(*) FROM "posts"
=> 100
```

`posts` 테이블의 레코드 갯수를 확인한다.

이제 브라우저에서 http://localhost:3000/posts 주소를 접속해 보면 다음과 같이 보이게 될 것이다.

![](https://medrails.files.wordpress.com/2017/06/posts_index_page-2.png?w=1680)



## Masonry 라이브러리 적용하기

레일스용 `Masonry` 라이브러리 젬인 `jQuery-masonry-rails` 을 `Gemfile` 파일에 추가한다.

```ruby
···
gem 'jquery-masonry-rails'
···
```

`jQuery` 자바스크립트 라이브러리를 사용하기 위해서 레일스 `5.1.1` 버전부터는 별도의 추가 작업을 해 주어야 하는데 이 때  `yarn` 이라는 **자바스크립트 라이브러리 패키지 매니저**를 이용한다. 젬을 `Gemfile`에 추가한 후 `bundler` 를 이용하여 설치하는 것 처럼, 자바스크립트 라이브러리에 대한 `bundler` 역할을 `yarn` 패키지 매니저가 담당하는 것으로 생각하면 된다.

> **yarn 설치법** : https://yarnpkg.com/lang/en/docs/install/

```sh
$ yarn add jquery
```

그리고 `assets/javascripts/application.js` 파일을 열고 다음과 같이 작성한다.

```javascript
//= require jquery
//= require rails-ujs
//= require masonry.pkgd
//= require turbolinks
//= require_tree .
```

1번과 3번 코드라인을 추가했다.

실제로 **Masonry** 라이브러리를 제대로 사용하기 위해서는 두가지 자바스크립트 라이브러리를 더 추가해 주어야 하는데, `imagesloaded` 는 `yarn` 으로 설치하고 `jquery.inifitescroll.min.js` 파일을 아래의 주소에서 복사해서 `assets/javascripts/` 디렉토리에 복사해 둔다.

```sh
$ yarn add imagesloaded
```

> **다운로드** : assets/javascripts/[jquery.inifinitescroll.min.js](https://raw.githubusercontent.com/metafizzy/infinite-scroll/master/jquery.infinitescroll.min.js)

그리고 `application.js` 파일을 열고 다음과 같이 4, 5번 라인을 추가한다.

```javascript
//= require jquery
//= require rails-ujs
//= require masonry.pkgd
//= require imagesloaded
//= require jquery.infinitescroll.min
//= require turbolinks
//= require_tree .
```



## Coffeescript 파일의 작성

`assets/javascripts/posts.coffee` 파일을 열고 다음과 같이 추가한다.

```javascript
$(document).on 'turbolinks:load', ->

 $grid = $('.grid')

 $grid.imagesLoaded ->
   $grid.masonry
     percentPosition: true
     itemSelector: '.grid-item'
     columnWidth: '.grid-sizer'
     gutter: '.gutter-sizer'
   return

 $grid.infinitescroll {
   navSelector: '.pagination'
   nextSelector: 'a.next_page'
   itemSelector: '.grid-item'
 }, (newElements) ->
   # hide new items while they are loading
   $newElems = $(newElements).css(opacity: 0)
   # ensure that images load before adding to masonry layout
   $newElems.imagesLoaded ->
     # show elems now they are ready
     $newElems.animate opacity: 1
     $grid.masonry 'appended', $newElems, true
     return
   return
 return
```

## 스타일시트 파일의 작성

`assets/stylesheets/posts.scss` 파일을 열고 다음과 같이 추가한다.

```scss
.posts.grid {
 .grid-sizer,
 .grid-item {
   // default width (set to maximal columns within maxiaml screen width, 5 columns)
   width: 19.281%;

   @media screen and (min-width: 1150px)  {
     // 5 columns
     width: 19.281%;
   }
   @media screen and (min-width: 1057px) and (max-width: 1149px) {
     // 5 columns
     width: 19.213%;
   }
   @media screen and (min-width: 821px) and (max-width: 1056px)  {
     // 4 columns
     width: 24%;
   }
   @media screen and (min-width: 541px) and (max-width: 820px)  {
     // 3 columns
     width: 32%;
   }
   @media screen and (min-width: 517px) and (max-width: 540px)  {
     // 2 column
     width: 49%;
   }
   @media screen and (min-width: 410px) and (max-width: 516px)  {
     // 2 column
     width: 48.69%;
   }
   @media screen and (max-width: 409px) {
     // 1 column
     width: 100%;
   }
 }
 .gutter-sizer {
   width: 10px;
 }

 .grid-item {
   background-color: rgba(#cdcdcd, 0.97);
   border: 1px solid #858585;
   border-radius: 4px;
   box-sizing: border-box;
   float: left;
   margin-bottom: .5em;
   padding: .5em;

   &:hover {
     border: 1px solid #fff;
     box-shadow: 0 0 5px 5px rgba(0, 0, 0, .38);
     transform: scale(1.001) rotate(2deg);
   }
   *:last-child {
     margin-bottom: 0;
   }
 }
}

.post-title {
 color: #0e57b9;
 font-weight: bold;
 margin-bottom: .2em;
}

.post-content {
 background-color: rgb(245, 245, 245);
 border: 1px solid #ccc;
 color: #999;
 font-size: .9em;
 padding: .5em;
}

.post-actions {
 font-size: .8em;
 margin-bottom: 0;
 text-align: right;
}

a {
 text-decoration: none;

 &:hover {
   color: inherit;
   background-color: transparent;
   text-decoration: underline;
 }
}
```

사실 반응형 레이아웃으로 유연하게 작동하려면 **media query**의 섬세한 **rule** 정의가 중요하다. 위의 `@media screen` 내용 중 폭 속성인 `width` 값은 일일이 브라우저 크기를 조절해 가면서 수작업으로 값을 정한 것이다.

그리고, `assets/stylesheets/application.css` 파일은 `scss` 파일(`assets/stylesheets/application.scss`)로 변경하고 다음과 같이 스타일시트 파일을 임포트한다.

```css
@import 'scaffolds';
@import 'posts';
```



## 뷰 템플릿 파일의 작성

뷰 파일은 의외로 간단하게 작성할 수 있다.

먼저 페이징 기능을 추가하기 위해서 `Gemfile`을 열고 `will_paginate` 젬을 추가하고,

```ruby
···
gem 'will_paginate'
···
```

터미널에서 번들 인스톨한다.

```sh
$ bundle install
```

다음은 **posts** 인덱스 뷰 템플릿 `views/posts/index.html.erb` 파일을 열고 다음과 같이 작성한다.

```erb
<p id="notice"><%= notice %></p>

<h1>Posts</h1>

<div class='posts grid'>
 <div class='grid-sizer'></div>
 <div class='gutter-sizer'></div>
 <%= render @posts %>
</div>

<%= will_paginate @posts %>

<%= link_to 'New Post', new_post_path %>
```

**views/posts/** 디렉토리에 파셜 템플릿 `_post.html.erb` 파일을 생성하고 다음과 같이 작성한다.

```erb
<div class='post grid-item'>
 <div class="post-title">
   <%= post.title %>
 </div>
 <div class="post-content">
   <%= post.content %>
 </div>
 <div class='post-actions'>
   <%= link_to 'Show', post %> ·
   <%= link_to 'Edit', edit_post_path(post) %> ·
   <%= link_to 'Destroy', post, method: :delete, data: { confirm: 'Are you sure?' } %>
 </div>
</div>
```

위에서 보여 준 두 개의 뷰 파일에서 사용한 4 가지 **class** 명을 주목하기 바란다.

* `.grid` : Masonry 레이아웃을 적용할 <u>**컨테이너 HTML 엘리먼트**</u>에 적용할 클래스명이며 임의로 지정할 수 있다.
* `.grid-item` : 컨테이너 엘리먼트에 포함할 <u>**자식 엘리먼트**</u>의 클래스명으로 임의로 지정할 수 있다.
* `.grid-sizer` : <u>**자식 엘리먼트의 폭**</u>을 지정하기 위한 **placeholder** 엘리먼트에 적용할 클래스명이며 임의로 지정할 수 있다.
* `.gutter-sizer` : <u>**자식 엘리먼트 간의 가로 간격**</u>을 지정하기 위한 **placeholder** 엘리먼트에 적용할 클래스명이며 임의로 지정할 수 있다.



자, 이제 http://localhost:3000/posts 로 접속하면 다음과 같이 브라우저 화면이 보이게 될 것이다.

![](https://medrails.files.wordpress.com/2017/06/posts_index_page_after-2.png?w=1680)

그리고 화면을 스크롤할 때 자동으로 페이지가 이동하여 추가된 글들이 화면 아래에서 연이어 보이게 될 것이다. 브라우저의 폭을 마우스로 좁혔다 넓혔다 해 보면 글 박스들이 반응형 레이아웃 디자인으로 인하여 멋진 애니메니션을 연출하게 될 것이다.

그렇지 않으면 어딘가에서 코딩 오류가 발생한 것이다. 위의 내용을 다시 보면서 천천히 검토해 보기 바란다.

이상으로 레일스 프로젝트에서 **Pinterest** 스타일의 레이아웃을 구현하는 방법을 함께 알아 보았다.
