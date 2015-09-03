[![Stories in Ready](https://badge.waffle.io/codesterkemp/image-regression.svg?label=ready&title=Ready)](http://waffle.io/codesterkemp/image-regression)
[![Stories in Backlog](https://badge.waffle.io/codesterkemp/image-regression.svg?label=backlog&title=Backlog)](http://waffle.io/codesterkemp/image-regression)
# image-regression
This is a tool designed to simplify the visual comparison of different versions of the same website.
Prerequisite programs you need to install them before running.
selenium-webdriver gem
imagemagick program
firefox

To use:

clone repo.

gem install selenium-webdriver

install imagemagick

install firefox

to demo tool run the img_regression_eng.rb

the png files starting with \_combined\_ should a combined image consisting of pngs of the webpages you are comparing stitched together with the resulting comparison on the far right. All black indicates the pages are identical, while the light areas highglight the differences.

