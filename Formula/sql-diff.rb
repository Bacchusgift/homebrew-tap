class SqlDiff < Formula
  desc "智能 SQL 表结构比对工具，支持交互式多行输入和 AI 分析"
  homepage "https://bacchusgift.github.io/sql-diff/"
  url "https://github.com/Bacchusgift/sql-diff/archive/refs/tags/v1.0.1.tar.gz"
  sha256 ""  # 首次发布时会自动填充
  license "MIT"
  head "https://github.com/Bacchusgift/sql-diff.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
      -X main.BuildTime=#{time.iso8601}
      -X main.GitCommit=#{Utils.git_short_head}
    ]

    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/sql-diff"
    generate_completions_from_executable(bin/"sql-diff", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sql-diff --version")
    
    source_sql = "CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100));"
    target_sql = "CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100), email VARCHAR(255));"
    
    output = shell_output("#{bin}/sql-diff -s '#{source_sql}' -t '#{target_sql}'")
    assert_match "ADD COLUMN email", output
  end
end
