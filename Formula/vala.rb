class Vala < Formula
  desc "Compiler for the GObject type system"
  homepage "https://wiki.gnome.org/Projects/Vala"
  url "https://download.gnome.org/sources/vala/0.50/vala-0.50.3.tar.xz"
  sha256 "6165c1b42beca4856e2fb9a31c5e81949d76fa670e2f0cfc8389ce9b95eca5db"
  license "LGPL-2.1-or-later"

  bottle do
    sha256 arm64_big_sur: "a0036331ef47150a376cb47fb8b71202eeea545ccc36a18475a5a36569086f70"
    sha256 big_sur:       "680a9b13a1697fd86175515cb1ad6d80f8f52e6931d56e7cb689b5e2d3be1ead"
    sha256 catalina:      "49928d667fe02a27bad5e960ee1dfa24496a5b3ebec45486b1cafbd74573360e"
    sha256 mojave:        "2b5bb380c683c16993b56ce4554cb32fa94b653377f9cb0f5d49afe0350f1732"
    sha256 x86_64_linux:  "11ec654891d2ce5bb3bdf24c07f179bf7e2b5f10aa07f2082f855a2b495c569b"
  end

  depends_on "gettext"
  depends_on "glib"
  depends_on "graphviz"
  depends_on "pkg-config"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_linux do
    depends_on "libx11"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make" # Fails to compile as a single step
    system "make", "install"
  end

  test do
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libffi"].opt_lib/"pkgconfig"
    test_string = "Hello Homebrew\n"
    path = testpath/"hello.vala"
    path.write <<~EOS
      void main () {
        print ("#{test_string}");
      }
    EOS
    valac_args = [
      # Build with debugging symbols.
      "-g",
      # Use Homebrew's default C compiler.
      "--cc=#{ENV.cc}",
      # Save generated C source code.
      "--save-temps",
      # Vala source code path.
      path.to_s,
    ]
    system "#{bin}/valac", *valac_args
    assert_predicate testpath/"hello.c", :exist?

    assert_equal test_string, shell_output("#{testpath}/hello")
  end
end
