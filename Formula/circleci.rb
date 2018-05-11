class Circleci < Formula
  desc "Unauthorized mirror of CircleCI CLI for Homebrew"
  homepage "https://edwardawebb.com/projects/creations/homebrew-circleci-cli/"
  url "https://github.com/eddiewebb/local-cli/releases/download/v0.0.4705-deba4df/circleci-0.0.4705-deba4df.tar.gz"
  sha256 "2587b22259c9caa70d1354aeaba2c8fa4da7f4dfe394626f932b9c4d2ac2000c"
  depends_on "docker"

  def install
    # Script is standalone bash script
    mv "circleci.sh", "circleci"
    bin.install "circleci"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/circleci --version")
    (testpath/".circleci").mkpath
    (testpath/".circleci/config.yml").write <<~EOS
      version: 2.0
      jobs:
        checkout_code:
          docker:
            - image: circleci/ruby:2.4-node
            - image: circleci/postgres:9.4.12-alpine
          working_directory: ~/circleci-demo-workflows
          steps:
            - checkout
            - save_cache:
                key: v1-repo-{{ .Environment.CIRCLE_SHA1 }}
                paths:
                  - ~/circleci-demo-workflows
        bundle_dependencies:
          docker:
            - image: circleci/ruby:2.4-node
            - image: circleci/postgres:9.4.12-alpine
          working_directory: ~/circleci-demo-workflows
          steps:
            - restore_cache:
                key: v1-repo-{{ .Environment.CIRCLE_SHA1 }}
            - restore_cache:
                key: v1-bundle-{{ checksum "Gemfile.lock" }}
            - run: bundle install --path vendor/bundle
            - save_cache:
                key: v1-bundle-{{ checksum "Gemfile.lock" }}
                paths:
                  - ~/circleci-demo-workflows/vendor/bundle
        rake_test:
          docker:
            - image: circleci/ruby:2.4-node
            - image: circleci/postgres:9.4.12-alpine
          working_directory: ~/circleci-demo-workflows
          steps:
            - restore_cache:
                key: v1-repo-{{ .Environment.CIRCLE_SHA1 }}
            - restore_cache:
                key: v1-bundle-{{ checksum "Gemfile.lock" }}
            - run: bundle --path vendor/bundle
            - run: bundle exec rake db:create db:schema:load
            - run:
                name: Run tests
                command: bundle exec rake
        precompile_assets:
          docker:
            - image: circleci/ruby:2.4-node
            - image: circleci/postgres:9.4.12-alpine
          working_directory: ~/circleci-demo-workflows
          steps:
            - restore_cache:
                key: v1-repo-{{ .Environment.CIRCLE_SHA1 }}
            - restore_cache:
                key: v1-bundle-{{ checksum "Gemfile.lock" }}
            - run: bundle --path vendor/bundle
            - run:
                name: Precompile assets
                command: bundle exec rake assets:precompile
            - save_cache:
                key: v1-assets-{{ .Environment.CIRCLE_SHA1 }}
                paths:
                  - ~/circleci-demo-workflows/public/assets
        deploy:
          machine:
              enabled: true
          working_directory: ~/circleci-demo-workflows
          environment:
            - HEROKU_APP: still-shelf-38337
          steps:
            - restore_cache:
                key: v1-repo-{{ .Environment.CIRCLE_SHA1 }}
            - restore_cache:
                key: v1-bundle-{{ checksum "Gemfile.lock" }}
            - restore_cache:
                key: v1-assets-{{ .Environment.CIRCLE_SHA1 }}
            - run:
                name: Setup Heroku
                command: bash .circleci/setup-heroku.sh
            - run:
                command: |
                  git push heroku fan-in-fan-out:master
                  heroku run rake db:migrate
                  sleep 5 # sleep for 5 seconds to wait for dynos
                  heroku restart
      workflows:
        version: 2
        build-and-deploy:
          jobs:
            - checkout_code
            - bundle_dependencies:
                requires:
                  - checkout_code
            - rake_test:
                requires:
                  - bundle_dependencies
            - precompile_assets:
                requires:
                  - bundle_dependencies
            - deploy:
                requires:
                  - rake_test
                  - precompile_assets
    EOS
    validation_output = shell_output("#{bin}/circleci config validate")
    assert_match "config file is valid", validation_output
    assert_match version.to_s, shell_output("#{bin}/circleci --tag latest version")
  end
end
