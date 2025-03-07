class Buildkit < Formula
  desc "Сoncurrent, cache-efficient, and Dockerfile-agnostic builder toolkit"
  homepage "https://github.com/moby/buildkit"
  url "https://github.com/moby/buildkit.git",
      tag:      "v0.8.1",
      revision: "8142d66b5ebde79846b869fba30d9d30633e74aa"
  license "Apache-2.0"
  head "https://github.com/moby/buildkit.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "1d9745061ffdead3c2a13af9ea53ccb35387188d301aff52308027d72da7918b"
    sha256 cellar: :any_skip_relocation, big_sur:       "3e71ae1f0248956f11e74d4d2d90decc62763e61c526ec77d65353d2bc42eeb3"
    sha256 cellar: :any_skip_relocation, catalina:      "ba36ac1a8b1b3c7c2f8e0e6bbbd403be303fa6ca0d193a5193eeb4e22f21d0cb"
    sha256 cellar: :any_skip_relocation, mojave:        "e6b41db313e3c7fb44dc70931dbab30e6f59274d522e58e194d5307977680d3d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "089966d1691e629dc7cbcdbcdfcd07f35895d318a9c205e8fad0647d79b5c71c"
  end

  depends_on "go" => :build

  def install
    revision = Utils.git_head
    ldflags = %W[
      -s -w
      -X github.com/moby/buildkit/version.Version=#{version}
      -X github.com/moby/buildkit/version.Revision=#{revision}
      -X github.com/moby/buildkit/version.Package=github.com/moby/buildkit
    ]

    system "go", "build", "-mod=vendor", "-trimpath",
      "-ldflags", ldflags.join(" "), "-o", bin/"buildctl", "./cmd/buildctl"

    doc.install Dir["docs/*.md"]
  end

  test do
    shell_output("#{bin}/buildctl --addr unix://dev/null --timeout 0 du 2>&1", 1)
  end
end
