class Libmicrohttpd < Formula
  desc "Light HTTP/1.1 server library"
  homepage "https://www.gnu.org/software/libmicrohttpd/"
  url "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.72.tar.gz"
  mirror "https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-0.9.72.tar.gz"
  sha256 "0ae825f8e0d7f41201fd44a0df1cf454c1cb0bc50fe9d59c26552260264c2ff8"
  license "LGPL-2.1-or-later"

  bottle do
    rebuild 1
    sha256 cellar: :any, arm64_big_sur: "a5964ebfc90189dd2657f81e258b62de76a90f7d77d8db258c786a59baa33a3b"
    sha256 cellar: :any, big_sur:       "a74d346f3af66b65561190baf344807b926bceee07ab46fdfa4ccec67671085e"
    sha256 cellar: :any, catalina:      "2d6f224e3262bf015d7d98faa9c60aa8098937d7940795eeaad5b57c5a410b75"
    sha256 cellar: :any, mojave:        "66441caeadac2391b9a3fbf9001a9ef5bfa7cc47eab016da0e972aa3b0fcdbb8"
    sha256 cellar: :any, x86_64_linux:  "32a874b16813dc148f82e2f5088c2781d8b9dca7a4fac2779ff5e6fc911e849e"
  end

  depends_on "gnutls"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-https",
                          "--prefix=#{prefix}"
    system "make", "install"
    (pkgshare/"examples").install Dir.glob("doc/examples/*.c")
  end

  test do
    cp pkgshare/"examples/simplepost.c", testpath
    inreplace "simplepost.c",
      "return 0",
      "printf(\"daemon %p\", daemon) ; return 0"
    system ENV.cc, "-o", "foo", "simplepost.c", "-I#{include}", "-L#{lib}", "-lmicrohttpd"
    assert_match /daemon 0x[0-9a-f]+[1-9a-f]+/, pipe_output("./foo")
  end
end
