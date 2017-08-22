FROM ruby:2.4.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs vim libmagic-dev software-properties-common python-pip libmagickwand-dev
RUN add-apt-repository -y 'deb http://ftp.de.debian.org/debian jessie-backports main ' && apt-get update && apt-get install -y ffmpeg
RUN pip install qtfaststart
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler
RUN bundle install
ADD . /myapp