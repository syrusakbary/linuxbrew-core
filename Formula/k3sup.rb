class K3sup < Formula
  desc "Utility to create k3s clusters on any local or remote VM"
  homepage "https://k3sup.dev"
  url "https://github.com/alexellis/k3sup.git",
      tag:      "0.9.13",
      revision: "95fc8b074a6e0ea48ea03a695491e955e32452ea"
  license "MIT"
  head "https://github.com/alexellis/k3sup.git"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  bottle do
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "857e5232a524b1458ef42038817b8a93713ea8e92e4d60441241990fc5bd5d22"
    sha256 cellar: :any_skip_relocation, big_sur:       "1a58b4c61dd608e30e4ae2010d0cbcc5cc1208fe4035e4b152759b3e9b5c1424"
    sha256 cellar: :any_skip_relocation, catalina:      "4303e006d4fafd8622976c09af83003e59512e062fb57cd4622bf4d99f0da691"
    sha256 cellar: :any_skip_relocation, mojave:        "4790e0a97346b18606cdaa1f1f4fcccc6c1dfecccf4b7ba40abefd4960bb096d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4ec0f2e0ee12ea959b5ed15265962466a4771f6a831bf1a04adba4f0967c712c"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/alexellis/k3sup/cmd.Version=#{version}
      -X github.com/alexellis/k3sup/cmd.GitCommit=#{Utils.git_short_head}
    ]
    system "go", "build", "-ldflags", ldflags.join(" "), *std_go_args
  end

  test do
    output = shell_output("#{bin}/k3sup install 2>&1", 1).split("\n").pop
    assert_match "unable to load the ssh key", output
  end
end
