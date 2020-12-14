# README
Coding exercise for Freska

* Start fixer proxy https://github.com/bagdenia/fixer_proxy


* Run:
  ```
  git clone git@github.com:bagdenia/fixer_reporter.git
  cd fixer_reporter/
  bundle
  ```

* Configure:
  Set acctual values in config.yml and .env (to check AWS in production mode)

* Run:
  ```
  ruby reporter.rb
  # accepts additional params, for instance run:
  ruby reporter.rb --base=EUR --other=RUB --date=2020-12-10 --format=xml
  # by default runs with EUR USD current_date csv
  ```


