use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'rss2torrent',
    VERSION_FROM      => 'lib/rss2torrent.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    EXE_FILES => [ 'bin/rss2torrent.pl'],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/rss2torrent.pm', # retrieve abstract from module
       AUTHOR         => 'Mariusz Gronczewski <xani666@gmail.com>') : ()),
);
