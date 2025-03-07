class Nettle < Formula
  desc "Low-level cryptographic library"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "https://ftp.gnu.org/gnu/nettle/nettle-3.7.tar.gz"
  mirror "https://ftpmirror.gnu.org/nettle/nettle-3.7.tar.gz"
  sha256 "f001f64eb444bf13dd91bceccbc20acbc60c4311d6e2b20878452eb9a9cec75a"
  license any_of: ["GPL-2.0-or-later", "LGPL-3.0-or-later"]

  bottle do
    sha256 cellar: :any, arm64_big_sur: "0f8cf7b90122188810887bd0b4b6230b1cf07898f7a135f8832db744fe89bd0d"
    sha256 cellar: :any, big_sur:       "e02e4ae1f73b54c0976a2e7afdbe2f461a202362c51c68e341f289477a9dfb6b"
    sha256 cellar: :any, catalina:      "d36ac9557eea88d8bbc2395a722af383f51f15dba6d1334bff024134579be7f7"
    sha256 cellar: :any, mojave:        "f3fd4302a0084c4be612b8f5d0968a86360bf5a080fa56977d9b293274144a13"
    sha256 cellar: :any, x86_64_linux:  "60b35111fbd75a0becbdc90a10eab57455e6dcb713f77523b246500fc424c5d3"
  end

  depends_on "gmp"

  uses_from_macos "m4" => :build

  def install
    # The LLVM shipped with Xcode/CLT 10+ compiles binaries/libraries with
    # ___chkstk_darwin, which upsets nettle's expected symbol check.
    # https://github.com/Homebrew/homebrew-core/issues/28817#issuecomment-396762855
    # https://lists.lysator.liu.se/pipermail/nettle-bugs/2018/007300.html
    if DevelopmentTools.clang_build_version >= 1000
      inreplace "testsuite/symbols-test", "get_pc_thunk",
                                          "get_pc_thunk|(_*chkstk_darwin)"
    end

    args = []
    args << "--build=aarch64-apple-darwin#{OS.kernel_version}" if Hardware::CPU.arm?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared",
                          *args
    system "make"
    system "make", "install"
    system "make", "check"

    # Move lib64/* to lib/ on Linux
    lib64 = Pathname.new "#{lib}64"
    if lib64.directory?
      mkdir_p lib
      system "mv #{lib64}/* #{lib}/"
      rmdir lib64
      inreplace Dir[lib/"pkgconfig/*"], "/lib64", "/lib"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <nettle/sha1.h>
      #include <stdio.h>

      int main()
      {
        struct sha1_ctx ctx;
        uint8_t digest[SHA1_DIGEST_SIZE];
        unsigned i;

        sha1_init(&ctx);
        sha1_update(&ctx, 4, "test");
        sha1_digest(&ctx, SHA1_DIGEST_SIZE, digest);

        printf("SHA1(test)=");

        for (i = 0; i<SHA1_DIGEST_SIZE; i++)
          printf("%02x", digest[i]);

        printf("\\n");
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lnettle", "-o", "test"
    system "./test"
  end
end
