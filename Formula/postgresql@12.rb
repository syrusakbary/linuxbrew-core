class PostgresqlAT12 < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v12.6/postgresql-12.6.tar.bz2"
  sha256 "df7dd98d5ccaf1f693c7e1d0d084e9fed7017ee248bba5be0167c42ad2d70a09"
  license "PostgreSQL"

  livecheck do
    url "https://ftp.postgresql.org/pub/source/"
    regex(%r{href=["']?v?(12(?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    sha256 arm64_big_sur: "32ac067934b8089c71193f0c97429408995138fbe8fde4f474019a476eb3e412"
    sha256 big_sur:       "e383accfea62cb7b376c260d9b5e8386473a50ce308808e76d27aaf8361f7f24"
    sha256 catalina:      "e188a2a39c76af458a7f1dd7f85743f2d6c63cc638181d0f5b3d58b6e5afbcad"
    sha256 mojave:        "a8eb8e21fafc49b777bd3fc1cb175665473f62cab3291daf2f2a79fd1f21ab2f"
    sha256 x86_64_linux:  "08d78085d1d654afcaf23c34f260ca4d49b8df0bfdc0138e89a5f54df15971de"
  end

  keg_only :versioned_formula

  # https://www.postgresql.org/support/versioning/
  deprecate! date: "2024-11-14", because: :unsupported

  depends_on "pkg-config" => :build
  depends_on "icu4c"

  # GSSAPI provided by Kerberos.framework crashes when forked.
  # See https://github.com/Homebrew/homebrew-core/issues/47494.
  depends_on "krb5"
  depends_on "openssl@1.1"
  depends_on "readline"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "perl"

  on_linux do
    depends_on "util-linux"
  end

  def install
    ENV.prepend "LDFLAGS", "-L#{Formula["openssl@1.1"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl@1.1"].opt_include} -I#{Formula["readline"].opt_include}"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{opt_pkgshare}
      --libdir=#{opt_lib}
      --includedir=#{opt_include}
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --enable-thread-safety
      --with-icu
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-perl
      --with-uuid=e2fs
    ]
    if OS.mac?
      args += %w[
        --with-bonjour
        --with-gssapi
        --with-ldap
        --with-pam
        --with-tcl
      ]
    end

    # PostgreSQL by default uses xcodebuild internally to determine this,
    # which does not work on CLT-only installs.
    args << "PG_SYSROOT=#{MacOS.sdk_path}" if MacOS.sdk_root_needed?

    system "./configure", *args

    # Work around busted path magic in Makefile.global.in. This can't be specified
    # in ./configure, but needs to be set here otherwise install prefixes containing
    # the string "postgres" will get an incorrect pkglibdir.
    # See https://github.com/Homebrew/homebrew-core/issues/62930#issuecomment-709411789
    system "make", "pkglibdir=#{lib}/postgresql"
    system "make", "install-world", "datadir=#{pkgshare}",
                                    "libdir=#{lib}",
                                    "pkglibdir=#{lib}/postgresql",
                                    "includedir=#{include}",
                                    "pkgincludedir=#{include}/postgresql",
                                    "includedir_server=#{include}/postgresql/server",
                                    "includedir_internal=#{include}/postgresql/internal"

    # Remove shim references
    if !OS.mac? && File.readlines("#{lib}/postgresql/pgxs/src/Makefile.global").grep(/#{HOMEBREW_SHIMS_PATH}/o).any?
      inreplace lib/"postgresql/pgxs/src/Makefile.global", "#{HOMEBREW_SHIMS_PATH}/linux/super/", ""
    end
  end

  def post_install
    (var/"log").mkpath
    versioned_data_dir.mkpath

    # Don't initialize database, it clashes when testing other PostgreSQL versions.
    return if ENV["HOMEBREW_GITHUB_ACTIONS"]

    system "#{bin}/initdb", "--locale=C", "-E", "UTF-8", versioned_data_dir unless versioned_pg_version_exists?
  end

  # Previous versions of this formula used the same data dir as the regular
  # postgresql formula. So we check whether the versioned data dir exists
  # and has a PG_VERSION file, which should indicate that the versioned
  # data dir is in use. Otherwise, returns the old data dir path.
  def postgresql_datadir
    if versioned_pg_version_exists?
      versioned_data_dir
    else
      old_postgres_data_dir
    end
  end

  def versioned_data_dir
    var/name
  end

  def old_postgres_data_dir
    var/"postgres"
  end

  # Same as with the data dir - use old log file if the old data dir
  # is version 12
  def postgresql_log_path
    if versioned_pg_version_exists?
      var/"log/#{name}.log"
    else
      var/"log/postgres.log"
    end
  end

  def versioned_pg_version_exists?
    (versioned_data_dir/"PG_VERSION").exist?
  end

  def postgresql_formula_present?
    Formula["postgresql"].any_version_installed?
  end

  # Figure out what version of PostgreSQL the old data dir is
  # using
  def old_postgresql_datadir_version
    pg_version = old_postgres_data_dir/"PG_VERSION"
    pg_version.exist? && pg_version.read.chomp
  end

  def caveats
    caveats = ""

    # Extract the version from the formula name
    pg_formula_version = name.split("@", 2).last
    # ... and check it against the old data dir postgres version number
    # to see if we need to print a warning re: data dir
    if old_postgresql_datadir_version == pg_formula_version
      caveats += if postgresql_formula_present?
        # Both PostgreSQL and PostgreSQL@12 are installed
        <<~EOS
          Previous versions of this formula used the same data directory as
          the regular PostgreSQL formula. This causes a conflict if you
          try to use both at the same time.

          In order to avoid this conflict, you should make sure that the
          #{name} data directory is located at:
            #{versioned_data_dir}

        EOS
      else
        # Only PostgreSQL@12 is installed, not PostgreSQL
        <<~EOS
          Previous versions of #{name} used the same data directory as
          the postgresql formula. This will cause a conflict if you
          try to use both at the same time.

          You can migrate to a versioned data directory by running:
            mv -v "#{old_postgres_data_dir}" "#{versioned_data_dir}"

          (Make sure PostgreSQL is stopped before executing this command)

        EOS
      end
    end

    caveats += <<~EOS
      This formula has created a default database cluster with:
        initdb --locale=C -E UTF-8 #{postgresql_datadir}
      For more details, read:
        https://www.postgresql.org/docs/#{version.major}/app-initdb.html
    EOS

    caveats
  end

  plist_options manual: "pg_ctl -D #{HOMEBREW_PREFIX}/var/postgres@12 start"

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
          <string>#{opt_bin}/postgres</string>
          <string>-D</string>
          <string>#{postgresql_datadir}</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardOutPath</key>
        <string>#{postgresql_log_path}</string>
        <key>StandardErrorPath</key>
        <string>#{postgresql_log_path}</string>
      </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/initdb", testpath/"test" unless ENV["HOMEBREW_GITHUB_ACTIONS"]
    assert_equal opt_pkgshare.to_s, shell_output("#{bin}/pg_config --sharedir").chomp
    assert_equal opt_lib.to_s, shell_output("#{bin}/pg_config --libdir").chomp
    assert_equal "#{lib}/postgresql", shell_output("#{bin}/pg_config --pkglibdir").chomp
  end
end
