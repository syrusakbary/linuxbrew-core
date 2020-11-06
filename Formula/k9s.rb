class K9s < Formula
  desc "Kubernetes CLI To Manage Your Clusters In Style!"
  homepage "https://k9scli.io/"
  url "https://github.com/derailed/k9s.git",
      tag:      "v0.23.6",
      revision: "ed1d7fbda5fca37800e452f4628cd25958559fb1"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "d89383bc429674d5f51e5cf48a364091214f0da21b56ef7934fc34669a19daf7" => :catalina
    sha256 "319c84975aabd18ec3aebbc4ef4410ef8ec9e1f4455cd5f5bdbbb448b2b3aa03" => :mojave
    sha256 "a0ff60eec4cbc459b430a3c89d6e3cc3384bcf8d76155eccf6de42651ef0b3c7" => :high_sierra
    sha256 "dde22c19a4d83bd32c2a683afcca3d8ddab4b6e23b302150300c4cd2e5a37e0c" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags",
             "-s -w -X github.com/derailed/k9s/cmd.version=#{version}
             -X github.com/derailed/k9s/cmd.commit=#{stable.specs[:revision]}",
             *std_go_args
  end

  test do
    assert_match "K9s is a CLI to view and manage your Kubernetes clusters.",
                 shell_output("#{bin}/k9s --help")
  end
end
