name 'mg_nagios'
version '0.0.1'

maintainer 'Manas Gupta'
maintainer_email 'manas.gupta@gmail.com'
issues_url 'github.com/manasg/cookbook-mg_nagios'
source_url 'github.com/manasg/cookbook-mg_nagios'

depends 'nagios', '= 7.2.6'

# used for 'target' nodes
depends 'yum-epel'
