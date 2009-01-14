# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="TestNG is a testing framework inspired from JUnit and NUnit"
HOMEPAGE="http://testng.org/"
SRC_URI="http://testng.org/${P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5
		dev-java/ant
		app-arch/unzip
		source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.5"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/${P}-build.diff

	java-pkg_jar-from ant-core ant.jar 3rdparty/ant.jar
	java-pkg_jar-from junit junit.jar 3rdparty/junit.jar
	ln -s "$(java-config --tools)" 3rdparty/tools.jar
}

src_compile() {
	eant dist-15 $(use_doc javadocs)
}

src_install() {
	java-pkg_newjar ${P}-jdk15.jar ${PN}.jar

	use doc && java-pkg_dojavadoc javadocs/
	use source && java-pkg_dosrc src/jdk15/org/testng/
}
