# 起因: line feed 和 tab 都是不可见字符，而 cat -v -t -e 输出的结果不是 "\n" 和 "\t" 这种标准形式，开始自己造轮子

# 普通用法: bash <(curl -sL https://raw.githubusercontent.com/librz/shell_scripts/main/show_non_printable.sh) filename.txt
# piping用法: echo "H" | bash <(curl -sL https://raw.githubusercontent.com/librz/shell_scripts/main/show_non_printable)

# 思路：先把字符串转为 hex，替换 line feed 的 hex 为 \和n 的 hex, 替换 tab 的 hex 为 \和t 的 hex; 再用 xxd 把 hex 转为 ascii 字符

# to use hexdump, bsdmainutils must be installed
yes Y | apt install bsdmainutils xxd > /dev/null

# newline ascii hex code: 0a
# tab ascii hex code: 09

# backsladh ascii hex code: 5c
# n ascii hex code: 6e
# t ascii hex code: 74

hexdump -e '16/1 "%02x " "\n"' $1 | sed 's/0a/5c6e/g' | sed 's/09/5c74/g' | xxd -r -p

# 待改进，输出结尾没有 line feed
# 目前只支持 line feed 和 tab 这两种不可见字符
