#!/bin/bash
if [ $# -ne 4 ]
then
    echo "usage $0 [input] [output-prefix] [column of interest] [label name]"
    exit
fi
cat $1 | grep -v scheme  > file1
cat file1 | grep FabaCC > file_FabaCC

# 设置颜色代码
cat file1 | awk '{if($1=="FabaCC" || $1=="FabaCCbeta") print $0" 0xff9900";else print $0" 0x146eb4" }' > file

cat > tmp.gpl <<END
set terminal svg size 450,400 dynamic enhanced fname 'arial,15' 

# 设置图像背景为不透明
#set object 1 rectangle \
#    from screen 0,0 to screen 1,1 fillcolor rgb"#FFFFFF" behind

set output '$2.svg'
red = "#FF0000"; green = "#00FF00"; blue = "#0000FF"; skyblue = "#87CEEB"; violet= "#9400d3"
unset xtics # 隐藏x轴刻度
set ytics nomirror # 仅显示y轴标签，无轴线和刻度
set yrange [0:]
set xlabel "$4 (%)"
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.8
set key off # 关闭图例
unset border # 移除边界框
set lmargin at screen 0.2 # 调整左边距以适应y轴标签
set rmargin at screen 0.8 # 调整右边距
set tmargin at screen 0.95 # 调整顶部边距
set bmargin at screen 0.1 # 调整底部边距

# Horizontal bar graph adjustments
BoxWidth = 0.8
BoxYLow(i)  = i - BoxWidth/2.
BoxYHigh(i) = i + BoxWidth/2.

set yrange [:] reverse
set offsets 0,0,0.5,0.5

plot "file" u (0):0:(0):3:(BoxYLow(\$0)):(BoxYHigh(\$0)):5:ytic(1) w boxxy lc rgb var, \
    '' u 3:0:(sprintf("%.2f%",\$3)) w labels offset  0.5,0 left

END
gnuplot tmp.gpl 1>tmp

rm tmp* file_FabaCC file file1
