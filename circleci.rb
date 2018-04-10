class Circleci < Formula
  desc "Unauthorized mirror of CircleCI CLI for Homebrew"
  homepage "https://edwardawebb.com/projects/creations/homebrew-circleci-cli/"
  url "https://github.com/eddiewebb/homebrew-circleci/releases/download/0.0.4812-e4f6fcc/circleci-0.0.4812-e4f6fcc.tar.gz"
  sha256 "18929b848c0ce5e61a4dccd499c73dd4d367b4eacc7532496bd42594ee10357f"
  
  depends_on "docker" => :recommended

  def install
    # Script is standalone bash script
    mv "circleci.sh","circleci"
    bin.install "circleci"
  end

  test do
    output = shell_output("#{bin}/circleci --version")
    assert_match "circleci cli version 0.0.4812-e4f6fcc #{version}\n", output

    shell_output "#{bin}/circleci"
  end
end
