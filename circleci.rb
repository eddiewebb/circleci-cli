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
    versionout = shell_output("#{bin}/circleci --version")
    assert_match "circleci cli version 0.0.4812-e4f6fcc #{version}\n", versionout
  end
end
