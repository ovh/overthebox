var Me = {
    call: function(method, url) {
        return m.request({
            method: method,
            url: "/cgi-bin/me/" + (url || ""),
        }).then(function(x) {
            Me.device = x.device
            Me.service = x.service
            Me.version = x.version
        })
    },
    oninit: function() {
        return Me.call("GET")
    },
    register: function() {
        return Me.call("POST", document.getElementById("service").value)
    },
    view: function(vnode) {
        return [
            m("h1.c", "OverTheBox"),
            m(".box", typeof Me.device == "string" ? [
                m("p", [
                    m("b", "Device"),
                    m(".mono", Me.device)
                ]),
                Me.service.length > 0 ? m("p", [
                    m("b", "Service"),
                    m(".mono", Me.service)
                ]) : [
                    m("p", m.trust("<b>This device is not associated with any service.</b><br>" +
                        "Please register it on the <a href=\"https://www.ovhtelecom.fr/manager/#/overTheBox/\">manager</a>.<br>" +
                        "Then confirm the service ID here.")),
                    m(".c", m("input[type=text][placeholder=Enter your service ID][size=47][maxlength=47][id=service].mono")),
                    m(".c", m("button", {onclick: Me.register}, "Register"))
                ]
            ] : m("p.c", "Loading...")),
            m("img.logo", {src:"logo.png"}),
            m(".version", Me.version || "unknown version")
        ]
    },
}

m.route(document.body, "/", {
    "/": Me,
})
