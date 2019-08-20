dist=docs
webdev build
rm -rf $dist
mkdir $dist
cp build/*.ico $dist
cp build/*.jpg $dist
cp build/*.html $dist
cp build/*.js $dist
cp build/*.css $dist

echo "copy path to $dist"