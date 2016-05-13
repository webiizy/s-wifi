-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.coovachilli", package.seeall)

function index()
	entry( { "admin", "services", "coovachilli" }, cbi("coovachilli"), _("Coova Chilli"), 100)
	--entry( { "admin", "services", "coovachilli_test" }, call("action_test"))
end

function action_apply()
	--luci.util.exec("/etc/init.d/chilli stop")
	--luci.util.exec("/etc/init.d/chilli start")
	--luci.util.exec("'dsdsds'> /etc/chilli/test.txt")
	--os.execute("/etc/init.d/chilli restart &")
end

