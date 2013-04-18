# set_default :ruby_version, "1.9.3-p385"
set_default :ruby_version, "2.0.0-p0"

namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  
  task :install, roles: :app do
    unless remote_file_exists?('~/.rbenv')
      run %q{git clone git://github.com/sstephenson/rbenv.git ~/.rbenv}
      run %q{git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build}
    end

    run %q{echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile}
    run %q{echo 'eval "$(rbenv init -)"' >> ~/.profile}

    run "rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"
    
    gemrc = <<-GEMRC
install: --no-rdoc --no-ri
update:  --no-rdoc --no-ri
GEMRC

    put gemrc, "/tmp/gemrc"
    run "mv /tmp/gemrc ~/.gemrc"

    run "gem install bundler"
    run "rbenv rehash"
  end
  after "deploy:install", "rbenv:install"

  task :upgrade, roles: :app do
    run "cd ~/.rbenv/plugins/ruby-build"
    run "git pull"
    run "rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"
    run "gem install bundler"
    run "rbenv rehash"
  end

  task :upgrade, roles: :app do
    run "cd ~/.rbenv/plugins/ruby-build && git pull"
    run "rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"
    run "gem install bundler"
    run "rbenv rehash"
  end
  
end
