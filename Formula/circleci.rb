class Circleci < Formula
  desc "Enables you to reproduce the CircleCI environment locally"
  homepage "https://circleci.com/docs/2.0/local-cli/"
  # Updates should be pushed no more frequently than once per week.
  url "https://github.com/CircleCI-Public/circleci-cli.git",
      tag:      "v0.1.14915",
      revision: "4e9d967dff62dcb9bc3e8faebac38a47cdcfa74f"
  license "MIT"
  head "https://github.com/CircleCI-Public/circleci-cli.git"

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur:      "fc06f2a9247cf9d92f9cfce8f2435f65b3728fd9c54720122deed3cf5701114f"
    sha256 cellar: :any_skip_relocation, catalina:     "a45c51b089bb0372848028a4c9fb3146c90d37039615062e5dfad311f3e417d2"
    sha256 cellar: :any_skip_relocation, mojave:       "66668d2269c40fed60d5354b5affa8db2cc7fb4d981c7cdf2d2543c54e24866b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3c7b696a6764d5125f9ddda38f18c811eab675f0488bfeac020513505a7fe9ab"
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    dir = buildpath/"src/github.com/CircleCI-Public/circleci-cli"
    dir.install buildpath.children

    cd dir do
      ldflags = %W[
        -s -w
        -X github.com/CircleCI-Public/circleci-cli/version.packageManager=homebrew
        -X github.com/CircleCI-Public/circleci-cli/version.Version=#{version}
        -X github.com/CircleCI-Public/circleci-cli/version.Commit=#{Utils.git_short_head}
      ]
      system "make", "pack"
      system "go", "build", "-ldflags", ldflags.join(" "),
             "-o", bin/"circleci"
      prefix.install_metafiles
    end
  end

  test do
    # assert basic script execution
    assert_match /#{version}\+.{7}/, shell_output("#{bin}/circleci version").strip
    (testpath/".circleci.yml").write("{version: 2.1}")
    output = shell_output("#{bin}/circleci config pack #{testpath}/.circleci.yml")
    assert_match "version: 2.1", output
    # assert update is not included in output of help meaning it was not included in the build
    assert_match "update      This command is unavailable on your platform", shell_output("#{bin}/circleci help")
    assert_match "`update` is not available because this tool was installed using `homebrew`.",
      shell_output("#{bin}/circleci update")
  end
end
