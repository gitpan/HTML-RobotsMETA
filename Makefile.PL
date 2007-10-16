use strict;
use inc::Module::Install;

name('HTML-RobotsMETA');
all_from('lib/HTML/RobotsMETA.pm');
requires('HTML::Parser', 3);

WriteAll;

1;