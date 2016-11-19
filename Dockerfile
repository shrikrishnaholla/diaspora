FROM 		debian:jessie
MAINTAINER	Shrikrishna Holla <shrikrishna.holla@gmail.com>
RUN 		apt-get update && apt-get install -y --fix-missing \
			build-essential \
			libssl-dev \
			libcurl4-openssl-dev \
			libxml2-dev \
			libxslt-dev \
			imagemagick \
			ghostscript \
			git \
			cmake \
			curl \
			libpq-dev \
			libmagickwand-dev \
			nodejs \
			gawk \
			libreadline6-dev \
			libyaml-dev \
			libsqlite3-dev \
			sqlite3 \
			autoconf \
			libgdbm-dev \
			libgmp-dev \
			libncurses5-dev \
			automake \
			bison \
			libffi-dev \
			&& apt-get -y install --fix-missing \
			&& apt-get clean \
			&& rm -rf /var/lib/apt/lists/*; \
			adduser --disabled-login --gecos "" diaspora; mkdir /diaspora;

USER 		diaspora
RUN 		gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN 		\curl -sSL https://get.rvm.io | bash -s stable

RUN			/bin/bash -l -c 'source "$HOME/.rvm/scripts/rvm" && rvm autolibs read-fail && rvm install 2.2.1'

COPY 		. /home/diaspora/diaspora

USER 		root
RUN			/bin/bash -l -c "chown -R diaspora /home/diaspora"

USER 		diaspora
WORKDIR 	/home/diaspora/diaspora
ENV 		DB=postgres RAILS_ENV=production

# VOLUME 		/home/diaspora/diaspora/config/database.yml /home/diaspora/diaspora/config/diaspora.yml
EXPOSE 		3000

RUN 		/bin/bash -l -c "gem install bundler --no-ri --no-rdoc && bundle install --without test development --with postgresql"
ONBUILD 	RUN  /bin/bash -l -c "rake assets:precompile" # if you want to build downstream, assume diaspora.yml already exists

#CMD			['/bin/bash', '-l, '-c', '"bundle exec unicorn -c config/unicorn.rb"']
CMD			/bin/bash -l -c "bundle exec unicorn -c config/unicorn.rb"
