class Mysql < Formula
  desc "Open source relational database management system"
  homepage "https://dev.mysql.com/doc/refman/8.0/en/"
  url "https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-boost-8.0.23.tar.gz"
  sha256 "1c7a424303c134758e59607a0b3172e43a21a27ff08e8c88c2439ffd4fc724a5"
  license "GPL-2.0-only"

  livecheck do
    url "https://dev.mysql.com/downloads/mysql/?tpl=files&os=src"
    regex(/href=.*?mysql[._-](?:boost[._-])?v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_big_sur: "e3508cd61df805a453628e8bbc52115c3665b9b8affddb2732f0481ec015a19f"
    sha256 big_sur:       "c47107257dff45ee81f671271a213e232b8c682c560277e6f3c554234ae1a686"
    sha256 catalina:      "308601d9802846e2a47e8d9ffed21bfe10a4186c9cd3adcff25e3ba936a2d94d"
    sha256 mojave:        "080fd12e447803dfe1312d8628b07b8764b2634e7a0136fc69f506766e68146e"
  end

  depends_on "cmake" => :build
  depends_on "openssl@1.1"
  depends_on "protobuf"

  # Fix error: Cannot find system editline libraries.
  uses_from_macos "libedit"

  conflicts_with "mariadb", "percona-server",
    because: "mysql, mariadb, and percona install the same binaries"

  unless OS.mac?
    patch do
      url "https://raw.githubusercontent.com/NixOS/nixpkgs/dae42566dbee37a3b7a609fa86eca9618f4f4b67/pkgs/servers/sql/mysql/abi-check.patch"
      sha256 "0dcfcca3bb3e7eb7ccd3ae02d4eb4fb07877970359611f081b03eab77bd4d6c9"
    end
    depends_on "pkg-config" => :build
    fails_with gcc: "5"
    fails_with gcc: "6"
    depends_on "gcc@7"
  end

  def datadir
    var/"mysql"
  end

  def install
    # Fix libmysqlgcs.a(gcs_logging.cc.o): relocation R_X86_64_32
    # against `_ZN17Gcs_debug_options12m_debug_noneB5cxx11E' can not be used when making
    # a shared object; recompile with -fPIC
    ENV.append_to_cflags "-fPIC" unless OS.mac?

    # -DINSTALL_* are relative to `CMAKE_INSTALL_PREFIX` (`prefix`)
    args = %W[
      -DFORCE_INSOURCE_BUILD=1
      -DCOMPILATION_COMMENT=Homebrew
      -DINSTALL_DOCDIR=share/doc/#{name}
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_INFODIR=share/info
      -DINSTALL_MANDIR=share/man
      -DINSTALL_MYSQLSHAREDIR=share/mysql
      -DINSTALL_PLUGINDIR=lib/plugin
      -DMYSQL_DATADIR=#{datadir}
      -DSYSCONFDIR=#{etc}
      -DWITH_BOOST=boost
      -DWITH_EDITLINE=system
      -DWITH_SSL=#{Formula["openssl@1.1"].opt_prefix}
      -DWITH_PROTOBUF=system
      -DWITH_UNIT_TESTS=OFF
      -DENABLED_LOCAL_INFILE=1
      -DWITH_INNODB_MEMCACHED=ON
    ]

    system "cmake", ".", *std_cmake_args, *args
    system "make"
    system "make", "install"

    (prefix/"mysql-test").cd do
      system "./mysql-test-run.pl", "status", "--vardir=#{Dir.mktmpdir}"
    end

    # Remove libssl copies as the binaries use the keg anyway and they create problems for other applications
    rm_rf lib/"libssl.dylib"
    rm_rf lib/"libssl.1.1.dylib"
    rm_rf lib/"libcrypto.1.1.dylib"
    rm_rf lib/"libcrypto.dylib"
    rm_rf lib/"plugin/libcrypto.1.1.dylib"
    rm_rf lib/"plugin/libssl.1.1.dylib"

    # Remove the tests directory
    rm_rf prefix/"mysql-test"

    # Don't create databases inside of the prefix!
    # See: https://github.com/Homebrew/homebrew/issues/4975
    rm_rf prefix/"data"

    # Fix up the control script and link into bin.
    inreplace "#{prefix}/support-files/mysql.server",
              /^(PATH=".*)(")/,
              "\\1:#{HOMEBREW_PREFIX}/bin\\2"
    bin.install_symlink prefix/"support-files/mysql.server"

    # Install my.cnf that binds to 127.0.0.1 by default
    (buildpath/"my.cnf").write <<~EOS
      # Default Homebrew MySQL server config
      [mysqld]
      # Only allow connections from localhost
      bind-address = 127.0.0.1
      mysqlx-bind-address = 127.0.0.1
    EOS
    etc.install "my.cnf"
  end

  def post_install
    # Make sure the var/mysql directory exists
    (var/"mysql").mkpath

    # Don't initialize database, it clashes when testing other MySQL-like implementations.
    return if ENV["HOMEBREW_GITHUB_ACTIONS"]

    unless (datadir/"mysql/general_log.CSM").exist?
      ENV["TMPDIR"] = nil
      system bin/"mysqld", "--initialize-insecure", "--user=#{ENV["USER"]}",
        "--basedir=#{prefix}", "--datadir=#{datadir}", "--tmpdir=/tmp"
    end
  end

  def caveats
    s = <<~EOS
      We've installed your MySQL database without a root password. To secure it run:
          mysql_secure_installation

      MySQL is configured to only allow connections from localhost by default

      To connect run:
          mysql -uroot
    EOS
    if (my_cnf = ["/etc/my.cnf", "/etc/mysql/my.cnf"].find { |x| File.exist? x })
      s += <<~EOS

        A "#{my_cnf}" from another install may interfere with a Homebrew-built
        server starting up correctly.
      EOS
    end
    s
  end

  plist_options manual: "mysql.server start"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/mysqld_safe</string>
          <string>--datadir=#{datadir}</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{datadir}</string>
      </dict>
      </plist>
    EOS
  end

  test do
    (testpath/"mysql").mkpath
    (testpath/"tmp").mkpath
    system bin/"mysqld", "--no-defaults", "--initialize-insecure", "--user=#{ENV["USER"]}",
      "--basedir=#{prefix}", "--datadir=#{testpath}/mysql", "--tmpdir=#{testpath}/tmp"
    port = free_port
    fork do
      system "#{bin}/mysqld", "--no-defaults", "--user=#{ENV["USER"]}",
        "--datadir=#{testpath}/mysql", "--port=#{port}", "--tmpdir=#{testpath}/tmp"
    end
    sleep 5
    assert_match "information_schema",
      shell_output("#{bin}/mysql --port=#{port} --user=root --password= --execute='show databases;'")
    system "#{bin}/mysqladmin", "--port=#{port}", "--user=root", "--password=", "shutdown"
  end
end
