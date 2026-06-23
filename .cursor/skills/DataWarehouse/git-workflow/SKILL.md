---
name: git-workflow
description: Follow team Git workflow conventions for commits, branches, and pull requests. Use when committing code, creating branches, merging pull requests, or resolving merge conflicts.
---

# Git Workflow

## Branch Strategy

```
main (生产环境)
  └── develop (开发环境)
        ├── feature/{功能名称}
        ├── bugfix/{问题编号}
        └── hotfix/{紧急修复}
```

| Branch Type | Naming | Example | Lifetime |
|-------------|--------|---------|----------|
| Feature | `feature/{name}` | `feature/vintage-report` | 开发完成即合并 |
| Bugfix | `bugfix/{issue-id}` | `bugfix/JIRA-123` | 问题修复即合并 |
| Hotfix | `hotfix/{desc}` | `hotfix/data-fix` | 紧急修复生产问题 |

## Commit Message Format

### Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

| Type | Description |
|------|-------------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档变更 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构（不修复问题不增加功能） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具变更 |

### Examples

```
feat(dwd): 新增客户维度表

新增 dwd_dim_customer_df 表，整合客户基础信息和画像数据

Closes #123
```

```
fix(vintage): 修复账龄计算错误

- 修复月末账龄多计算一个月的问题
- 调整账龄起始日期计算逻辑

Closes #456
```

```
docs(sql): 更新 DWS 层命名规范

新增月度汇总表命名规则说明
```

## Commit Checklist

- [ ] Commit message 清晰描述变更内容
- [ ] 每个 Commit 只做一件事
- [ ] 提交前运行基本测试
- [ ] 敏感信息已脱敏（密码、密钥等）
- [ ] 大文件已使用 Git LFS

## Pull Request Guidelines

### PR 标题格式

```
[Feature] 功能名称
[Bugfix] 问题描述
[Hotfix] 紧急修复说明
[Refactor] 重构说明
```

### PR Description Template

```markdown
## Summary
简要描述本次变更

## Changes
- 变更点 1
- 变更点 2

## Test Plan
- [ ] 测试场景 1
- [ ] 测试场景 2

## Screenshots (if applicable)
截图或日志
```

## Merge Strategy

| Situation | Strategy |
|-----------|----------|
| Feature 分支 | Squash and Merge |
| Bugfix 分支 | Squash and Merge |
| Hotfix 分支 | Merge Commit |
| Release 分支 | Merge Commit |

## Common Commands

```bash
# 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/vintage-report

# 提交代码
git add .
git commit -m "feat(vintage): add vintage cycle report"

# 推送并创建 PR
git push -u origin feature/vintage-report

# 同步远程分支
git fetch origin
git rebase origin/develop
```

## Best Practices

1. **频繁提交**：每完成一个小功能就提交
2. **原子提交**：一个 Commit 只改一件事
3. **清晰信息**：Commit message 要能看懂改了什么
4. **先拉后推**：推送前先拉取最新代码
5. **Code Review**：重要变更必须经过评审
