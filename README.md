### bash 写的一些小工具，安装配置脚本之类

#### 获取代码

`git clone https://github.com/librz/shell-scripts.git`

#### 执行脚本 (已经 git clone)

如果已经将项目 git clone 到本地，用 `bash /path/to/script` 的方式执行就好了 

#### 执行脚本 (不需要 git clone)

由于 raw.githubusercontent.com 国内访问不了，这些文件也被托管在 http://realrz.com/shell-scripts/ 下面

比如要执行 3p.sh, 可以 `curl -sL http://realrz.com/shell-scripts/3p.sh` 再用 bash 执行:

`bash <(curl -sL https://realrz.com/shell-scripts/3p.sh)`
