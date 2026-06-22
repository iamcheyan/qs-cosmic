# Overview 工作区排序：停留工作区置顶

## 行为

overview 网格中，**上一次 overview 关闭时停留的工作区**排在第一格；
其余按 id 升序、末尾带“新工作区”占位。

由 `GlobalStates.overviewAnchorWorkspaceId`（新增，默认 `-1`）驱动。
`overviewWorkspaceEntriesGlobal()`（`ii/services/HyprlandData.qml:60`）
末尾用它做 `unshift`：

```js
const anchorId = GlobalStates.overviewAnchorWorkspaceId > 0
    ? GlobalStates.overviewAnchorWorkspaceId
    : (root.activeWorkspace?.id ?? 0);
if (anchorId > 0) {
    const anchorIdx = model.findIndex(e => e.id === anchorId && !e.isTrailingEmpty);
    if (anchorIdx > 0) {
        const [anchorEntry] = model.splice(anchorIdx, 1);
        model.unshift(anchorEntry);
    }
}
```

## 为什么用锚点而不是 `activeWorkspace`

最初直接用 `activeWorkspace.id` 置顶，但 grab 模式下
`selectOverviewWorkspace` 会实时 dispatch focus，导致
`activeWorkspace` 跟着高亮变 → 排序跟着变 → Tab 循环只在两个
工作区间反复横跳。

锚点**只在 overview 关闭时**更新为停留的工作区，grab 循环期间
冻结，所以 Tab 循环看到的是稳定顺序。

## 锚点更新时机

`Overview.qml` 的 `onOverviewOpenChanged`：

- **关闭时**：`overviewAnchorWorkspaceId = overviewFocusedWorkspaceId
  > 0 ? overviewFocusedWorkspaceId : currentWorkspaceId()`
  —— 松开 Win / Esc / 点击外部时，把停留的工作区记为锚点。
- **打开时**：若锚点未初始化（`< 0`），设为当前工作区。

`OverviewWidget.qml`：

- **点击工作区格**切换：`overviewAnchorWorkspaceId = workspace.workspaceValue`
  再 dispatch。
- **点击窗口**聚焦：`overviewAnchorWorkspaceId = windowData.workspace.id`
  再 dispatch。

## 边界情况

- `anchorId` 不在 model 中（被过滤 / 是空槽）：`findIndex` 返回 `-1`，
  不重排，回退到原 id 升序。
- 首次启动 / 锚点未设置：回退到 `activeWorkspace.id`，行为等同
  “当前工作区置顶”。
- 拖拽落点用 `workspace.workspaceValue`（即 `modelData.id`）匹配，
  与 index 无关，置顶不影响拖拽。