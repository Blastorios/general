#Credit to: (base) https://medium.com/google-developers/how-to-run-travisci-locally-on-docker-822fc6b2db2e 
# & (up2date) https://andy-carter.com/blog/setting-up-travis-locally-with-docker-to-test-continuous-integration

# choose the image according to the language chosen in .travis.yml (https://hub.docker.com/u/travisci/)
$ docker run --name travisLocal -dit travisci/ci-python:packer-1490914243 /sbin/init
$ docker exec -it travisLocal bash -l

# now that you are in the docker image, switch to the travis user
apt-get install nano ruby-full
su - travis

# Install travis-build to generate a .sh out of .travis.yml
$ cd ~/builds \
git clone https://github.com/travis-ci/travis-build.git \
cd travis-build \
gem install travis \
travis \
bundle install \
bundler add travis \
bundler binstubs travis

# Create ssh key for Github
ssh-keygen -t rsa -b 4096 -C “your-github-email@example.com”

# Click enter to use default location for key
# You can choose empty passphrase by clicking enter twice
# Now that we have the key, let’s share with Github
less ~/.ssh/id_rsa.pub

# Copy the contents of the id_rsa.pub
# 3. Go to your Github SSH key settings
# 4. Create a new ssh key with title: “docker key”: “PASTE THE KEY CONTENTS HERE”
# 5. Go back to docker terminal

# Create project dir, assuming your project is `AUTHOR/PROJECT` on GitHub
cd ~/builds \
git clone git@github.com:AUTHOR/PROJECT.git \
cd PROJECT

# change to the branch or commit you want to investigate
# compile travis script into bash script
travis compile > ci.sh

# Go to bash script and fix the branch name
nano ci.sh

# in Vi type “/branch” to search and add the right branch name
# — branch\=\’\NEW_BRANCH’\
# You most likely will need to edit ci.sh as it ignores ‘matrix’ and ‘env’ keywords
bash ci.sh