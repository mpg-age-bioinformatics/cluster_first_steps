# VS Code R Setup In Posit Workbench

This setup makes VS Code inside Posit Workbench behave more like RStudio:

- R code editor on top
- R terminal on the bottom
- `Ctrl+Enter` sends code from the editor to R
- plots display in VS Code's plot/image viewer
- different R versions can be selected with `R_VERSION`

## 1. Install VS Code Extensions

Install these extensions in VS Code:

- **R** by `REditorSupport`
- Optional: **R Debugger**
- Optional: **Quarto**, if you use `.qmd` or `.Rmd` files

## 2. Open User Settings JSON

In VS Code inside Posit Workbench:

1. Open the gear/settings menu.
2. Open **Settings**.
3. Use the settings page action to open **Settings JSON**.

The file is usually:

```text
/nexus/posix0/MAGE-flaski/service/posit/home/<username>/.vscode-server/User/settings.json
```

Add or keep these settings:

```json
{
  "r.rterm.linux": "/nexus/posix0/MAGE-flaski/service/posit/rcs/R-vscode",
  "r.sessionWatcher": true,
  "r.alwaysUseActiveTerminal": true,
  "r.plot.useHttpgd": false,
  "workbench.panel.defaultLocation": "bottom"
}
```

## 3. Set R Version For One Folder

To set the R version only for the current project/folder, create this file inside the project:

```text
.vscode/settings.json
```

Put only the project-specific R version there:

```json
{
  "terminal.integrated.env.linux": {
    "R_VERSION": "4.5.2"
  }
}
```

Keep the common R extension and plotting settings in the global/user settings. This folder setting only overrides `R_VERSION` while this folder is open in VS Code. Different projects can have different `.vscode/settings.json` files with different `R_VERSION` values.

After changing this file, close the old R terminal and create a new R terminal from the VS Code R terminal/profile menu. Existing terminals keep the R version they started with.

## 4. Start An R Terminal

Use the VS Code terminal profile/menu rather than the keyboard command palette shortcut:

1. Open the bottom terminal panel.
2. Use the terminal dropdown menu.
3. Select the R terminal/profile, or choose the command/menu entry named **>R: Create R Terminal** if available.

Then send code from an `.R` file with:

```text
Ctrl+Enter (for Windows)

Command+Enter (for Mac)
```

Test plotting with:

```r
plot(mtcars$mpg, mtcars$hp)
```

The plot should appear in VS Code's plot/image viewer.

## 6. Check The Active R Version

Inside R:

```r
R.version.string
getOption("device")
```

For plot display, `getOption("device")` should not be the plain default `pdf()` device. It should be a VS Code-managed plotting device.

## 7. List Available R Versions

In a shell terminal, run:

```bash
source /r.rc
```

Then choose a version by editing the VS Code setting:

```json
"terminal.integrated.env.linux": {
  "R_VERSION": "4.5.2"
}
```

Then start a new R terminal from the VS Code R terminal/profile menu.

Existing terminals keep the R version they started with, so close the old R terminal and create a new one after changing `R_VERSION`.
