class GnuTar < Formula
  desc "GNU version of the tar archiving utility"
  homepage "https://www.gnu.org/software/tar/"
  url "https://ftp.gnu.org/gnu/tar/tar-1.34.tar.gz"
  mirror "https://ftpmirror.gnu.org/tar/tar-1.34.tar.gz"
  sha256 "03d908cf5768cfe6b7ad588c921c6ed21acabfb2b79b788d1330453507647aed"
  license "GPL-3.0-or-later"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "660e573b78965f1d3fa9f8f7f78a72d38f7f26f77ca66e9f72fec26fe9be6c3a"
    sha256 cellar: :any_skip_relocation, big_sur:       "a6ab3eb4a49d609f5f1dde43710b847fd827ebc03195aee052c7aeb528aa9bcc"
    sha256 cellar: :any_skip_relocation, catalina:      "53b9fc4011ca3ca3e669aa96a95a5394ef45138b9b2d52c76c3a17fceb432229"
    sha256 cellar: :any_skip_relocation, mojave:        "c4f9fcc7bdbb2bc5591a6650cf3bbfc1aa791e85f6d299f165a9466c235c83ae"
    sha256                               x86_64_linux:  "62b370ce29f30cf6fbcc1b106a7a9258a9d1770468eb4e075b8fd5ef192593f6"
  end

  head do
    url "https://git.savannah.gnu.org/git/tar.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
  end

  on_linux do
    conflicts_with "libarchive", because: "both install `tar` binaries"
  end

  def install
    # Work around unremovable, nested dirs bug that affects lots of
    # GNU projects. See:
    # https://github.com/Homebrew/homebrew/issues/45273
    # https://github.com/Homebrew/homebrew/issues/44993
    # This is thought to be an el_capitan bug:
    # https://lists.gnu.org/archive/html/bug-tar/2015-10/msg00017.html
    ENV["gl_cv_func_getcwd_abort_bug"] = "no" if MacOS.version == :el_capitan

    # Fix configure: error: you should not run configure as root
    ENV["FORCE_UNSAFE_CONFIGURE"] = "1" if !OS.mac? || !ENV["HOMEBREW_GITHUB_ACTIONS"]

    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
    ]

    on_macos do
      args << "--program-prefix=g"
    end
    on_linux do
      args << "--without-selinux"
    end
    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "install"

    on_macos do
      # Symlink the executable into libexec/gnubin as "tar"
      (libexec/"gnubin").install_symlink bin/"gtar" =>"tar"
      (libexec/"gnuman/man1").install_symlink man1/"gtar.1" => "tar.1"
    end

    libexec.install_symlink "gnuman" => "man"
  end

  def caveats
    on_macos do
      <<~EOS
        GNU "tar" has been installed as "gtar".
        If you need to use it as "tar", you can add a "gnubin" directory
        to your PATH from your bashrc like:

            PATH="#{opt_libexec}/gnubin:$PATH"
      EOS
    end
  end

  test do
    (testpath/"test").write("test")
    on_macos do
      system bin/"gtar", "-czvf", "test.tar.gz", "test"
      assert_match /test/, shell_output("#{bin}/gtar -xOzf test.tar.gz")
      assert_match /test/, shell_output("#{opt_libexec}/gnubin/tar -xOzf test.tar.gz")
    end

    on_linux do
      system bin/"tar", "-czvf", "test.tar.gz", "test"
      assert_match /test/, shell_output("#{bin}/tar -xOzf test.tar.gz")
    end
  end
end
