class Mpw < Formula
  desc "Stateless/deterministic password and identity manager"
  homepage "https://masterpasswordapp.com/"
  url "https://masterpasswordapp.com/mpw-2.6-cli-5-0-g344771db.tar.gz"
  version "2.6-cli-5"
  sha256 "954c07b1713ecc2b30a07bead9c11e6204dd774ca67b5bdf7d2d6ad1c4eec170"
  license "GPL-3.0"
  revision 2
  head "https://gitlab.com/MasterPassword/MasterPassword.git"

  # The first-party site doesn't seem to list version information, so it's
  # necessary to check the tags from the `head` repository instead.
  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+[._-]cli[._-]?\d+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_big_sur: "252fbad588409e4fd5be091f7c248150e75b995d39ce334938b9a7d33534cbc9"
    sha256 cellar: :any, big_sur:       "4ae85b3d30e47294436b7fddca456c98ed2bf546793f2ef9d57a372d782fb072"
    sha256 cellar: :any, catalina:      "2f275d762a9c73bd6b3f2e5a7f3f13a9c99ddfc3e2f89a2ededa07ba89b6de40"
    sha256 cellar: :any, mojave:        "9103716223529cd3e2cb969e904892bf2022cb8e73918418f2d3d343d1325c80"
    sha256 cellar: :any, high_sierra:   "07b89df8d96f9c1cebbf6296a4e98b2bac833c45f736b646a1eba24bd5244732"
    sha256 cellar: :any, x86_64_linux:  "049824290f38bd0562ebc4045ebe0d97c646e4ba399c433684c1e1ee0a379403"
  end

  depends_on "json-c"
  depends_on "libsodium"
  depends_on "ncurses"

  def install
    cd "platform-independent/c/cli" if build.head?

    ENV["targets"] = "mpw"
    # not compatible with json-c 0.14 yet
    ENV["mpw_json"] = "0"
    ENV["mpw_color"] = "1"

    system "./build"
    system "./mpw-cli-tests"
    bin.install "mpw"
  end

  test do
    assert_equal "Jejr5[RepuSosp",
      shell_output("#{bin}/mpw -q -Fnone -u 'Robert Lee Mitchell' -M 'banana colored duckling' " \
                   "-tlong -c1 -a3 'masterpasswordapp.com'").strip
  end
end
