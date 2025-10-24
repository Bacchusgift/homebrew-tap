class SqlDiff < Formula
  desc "智能 SQL 表结构比对工具，支持交互式多行输入和 AI 分析"
  homepage "https://bacchusgift.github.io/sql-diff/"
  url "https://github.com/Bacchusgift/sql-diff/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "b76e8f7b68a4863c24a9f66a832c0ff253f108baf318dd847cfc4742b1320350"
  license "MIT"
  head "https://github.com/Bacchusgift/sql-diff.git", branch: "main"

  depends_on "go" => :build

  def install
    # 构建标志
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
      -X main.BuildTime=#{time.iso8601}
    ]
    
    # 仅在 HEAD 版本（从 Git 安装）时添加 GitCommit
    if build.head?
      ldflags << "-X main.GitCommit=#{Utils.git_short_head}"
    end

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
