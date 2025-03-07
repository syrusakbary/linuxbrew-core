class Ocproxy < Formula
  desc "User-level SOCKS and port forwarding proxy"
  homepage "https://github.com/cernekee/ocproxy"
  url "https://github.com/cernekee/ocproxy/archive/v1.60.tar.gz"
  sha256 "a7367647f07df33869e2f79da66b6f104f6495ae806b12a8b8d9ca82fb7899ac"
  license "BSD-3-Clause"
  revision 1
  head "https://github.com/cernekee/ocproxy.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d{1,3})+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_big_sur: "d598c7b18b39b70d0bff1cc24b044a7351f8161ada44ef860649bc658323734a"
    sha256 cellar: :any, big_sur:       "c215e90cdcbcd59674c111bd2bbdf157ad554247c65025560c6688677d25be53"
    sha256 cellar: :any, catalina:      "53016c9f83444b015e71e2f1678b1aab1e7914f42a8c5d8de1ab581fca130ef8"
    sha256 cellar: :any, mojave:        "786f0c42a3d282b78d8dc2fa18c36e46707451f4ac848e9af7dd82ab31b40f6d"
    sha256 cellar: :any, high_sierra:   "0cd70ac67ebd419b869ad4dd70c6cd1217248c8e7b7a57d3a7c8e15c7d2f7dfc"
    sha256 cellar: :any, sierra:        "8e33eae007c082ec9b6787210096a4e20992151a7b2c5f345941f68c478ae0e2"
    sha256 cellar: :any, x86_64_linux:  "ab9030077d842b07fdd98e887b98d9e50abd22459cb24bf5a4379c6c7b3a5359"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libevent"

  def install
    system "./autogen.sh"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match /VPNFD.is.not.set/, shell_output("#{bin}/ocproxy 2>&1", 1)
  end
end
