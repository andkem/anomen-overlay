# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils

DESCRIPTION="Python im-/export filters for MS Excel files. Including xls2txt, xls2csv and xls2html commands."
HOMEPAGE="http://sourceforge.net/projects/pyexcelerator"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
RESTRICT="mirror"

LICENSE="BSD-4"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

src_install() {
	distutils_src_install

	dobin tools/xls2csv.py || die
	dobin tools/xls2html.py || die
	dobin tools/xls2txt.py || die

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/* || die
	fi
}
