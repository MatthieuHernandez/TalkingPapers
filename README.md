<p align="center">
    <img src="https://github.com/MatthieuHernandez/TalkingPapers/blob/master/app/assets/images/talkingpapersv6.png" width="70%" style="text-align:center">
</p>

[TalkingPapers.org](https://www.talkingpapers.org) A free web app which aims to advance scientific research by helping people who read academic papers.

## Local Installation

- Ruby on Rails
  - install [Ruby 2.7](https://www.ruby-lang.org/)
  - run `gem install rails`
  - run `gem install rake`
  - run `gem install bundle`
  - clone the repository
  - run `rails server` from talkingpaper GitHub folder
- PostgreSQL
  - install postgres 12
  - run `"C:\Program Files\PostgreSQL\12\bin\pg_ctl" -D "C:\Program Files\PostgreSQL\12\data" start`
  - run `rake db:create`
- Node.js
  - install Node.js
  - run `npm install --global yarn`

- go to http://127.0.0.1:3000/

- Optional
  - install ImageMagick (for image management)

## Tests
  - run `"C:\Program Files\PostgreSQL\12\bin\pg_ctl" -D "C:\Program Files\PostgreSQL\12\data" start`
  - run `rails test` to run the unit tests