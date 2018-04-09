class Circleci < Formula
  desc "Unauthorized mirror of CircleCI CLI for Homebrew"
  homepage "https://edwardawebb.com/projects/creations/homebrew-circleci-cli/"
  url "https://github.com/eddiewebb/circleci-cli/releases/download/0.0.4812-e4f6fcc/circleci-f59073c6e81a4a2de1b1ba20131e9bde91f48787.tar.gz"
  sha256 "d4ef9d669f3f4c373ba5d79156cd63f3a9a0daa94183a26e80ca2b559328290a"
  
  depends_on "docker" => :recommended

  def install
    # Script is standalone bash script
  end

  test do
    output = shell_output("circleci.sh --version")
    assert_match "circleci cli version 0.0.4812-e4f6fcc #{version}\n", output
  end
end