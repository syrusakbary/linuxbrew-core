class Patchelf < Formula
  desc "Modify dynamic ELF executables"
  homepage "https://github.com/NixOS/patchelf"
  url "https://bintray.com/homebrew/mirror/download_file?file_path=patchelf-0.12.tar.gz"
  sha256 "2848beb6bbdfbf4efd12d627bdc315b74e7a5ed94a6a7b01c62641cdf4560e51"
  license "GPL-3.0-or-later"
  revision 1
  head "https://github.com/NixOS/patchelf.git"

  livecheck do
    url :head
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "76fbad0cfce574922838b776de79999a9092ea00dc2d878762f2e20956a5df98" => :big_sur
    sha256 "4bdb98927df64e1af3fa765d9171dd39021093e0c5b89bfec8426af39e8ca8a2" => :catalina
    sha256 "b43f892846c58349425c2c061561e90fb74d065abeaa1c93c62ec2176bdc289d" => :mojave
    sha256 "f55c200024d22876b53bf823c52fde73e576417372b66a6b5b8b9fe5abda36dd" => :x86_64_linux
  end

  resource "helloworld" do
    url "http://timelessname.com/elfbin/helloworld.tar.gz"
    sha256 "d8c1e93f13e0b7d8fc13ce75d5b089f4d4cec15dad91d08d94a166822d749459"
  end

  # Fix unsupported overlap of SHT_NOTE and PT_NOTE
  # See https://github.com/NixOS/patchelf/pull/230
  patch do
    url "https://github.com/rmNULL/patchelf/commit/6edec83653ce1b5fc201ff6db93b966394766814.patch?full_index=1"
    sha256 "072eff6c5b33298b423f47ec794c7765a42d58a2050689bb20bf66076afb98ac"
  end

  def install
    on_linux do
      # Fix ld.so path and rpath
      # see https://github.com/Homebrew/linuxbrew-core/pull/20548#issuecomment-672061606
      ENV["HOMEBREW_DYNAMIC_LINKER"] = File.readlink("#{HOMEBREW_PREFIX}/lib/ld.so")
      ENV["HOMEBREW_RPATH_PATHS"] = nil
    end

    system "./configure", "--prefix=#{prefix}",
      "CXXFLAGS=-static-libgcc -static-libstdc++",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules"
    system "make", "install"
  end

  test do
    resource("helloworld").stage do
      assert_equal "/lib/ld-linux.so.2\n", shell_output("#{bin}/patchelf --print-interpreter chello")
      assert_equal "libc.so.6\n", shell_output("#{bin}/patchelf --print-needed chello")
      assert_equal "\n", shell_output("#{bin}/patchelf --print-rpath chello")
      assert_equal "", shell_output("#{bin}/patchelf --set-rpath /usr/local/lib chello")
      assert_equal "/usr/local/lib\n", shell_output("#{bin}/patchelf --print-rpath chello")
    end
  end
end
