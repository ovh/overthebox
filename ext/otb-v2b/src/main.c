#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

#define COUNT(x) (sizeof(x) / sizeof((x)[0]))

#define SW_SPEED B115200
#define SW_PORTS 18

enum state {
    s_unknown,
    s_username,
    s_password,
    s_enable,
    s_logged,
    s_config,
    s_config_vlan,
    s_config_if,
};

struct {
    char *str;
    enum state state;
} actions[] = {
    { "Username:",            s_username    },
    { "Password:",            s_password    },
    { "Switch>",              s_enable      },
    { "Switch#",              s_logged      },
    { "Switch(config)#",      s_config      },
    { "Switch(config-vlan)#", s_config_vlan },
    { "Switch(config-if)#",   s_config_if   },
};

_Noreturn void
die(const char *restrict fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vdprintf(STDERR_FILENO, fmt, ap);
    va_end(ap);
    exit(EXIT_FAILURE);
}

int
main(int argc, char **argv)
{
    if (argc < 4)
        die("usage: %s set VLAN PORT [PORT...]\n", argv[0]);

    if (strcmp(argv[1], "set"))
        die("unknown command: %s\n", argv[1]);

    char *end = NULL;
    unsigned long vlan = strtoul(argv[2], &end, 10);

    if (!end || end[0] || vlan < 1 || vlan > 4096)
        die("bad vlan: %s\n", argv[2]);

    const int port_count = argc - 3;

    if (port_count > SW_PORTS)
        die("too many ports, limited to %d.\n", SW_PORTS);

    struct {
        unsigned long num;
        unsigned tag;
    } port[SW_PORTS] = {0};

    for (int i = 0; i < port_count; i++) {
        end = NULL;
        port[i].num = strtoul(argv[3 + i], &end, 10);

        if (end && end[0] == 't') {
            port[i].tag = 1;
            end++;
        }

        if (!end || end[0] || port[i].num < 1 || port[i].num > SW_PORTS)
            die("bad port: %s\n", argv[3 + i]);
    }

    const char *tty = getenv("SW_TTY") ?: "/dev/ttyS0";
    int fd = open(tty, O_RDWR | O_NOCTTY | O_NONBLOCK);

    if (fd == -1)
        die("%s: couldn't open (%d)\n", tty, errno);

    struct flock fl = {
        .l_type = F_WRLCK,
        .l_whence = SEEK_SET,
    };

    if (fcntl(fd, F_SETLKW, &fl))
        die("%s: couldn't lock (%d)\n", tty, errno);

    if (ioctl(fd, TIOCEXCL, NULL))
        die("%s: couldn't put into exclusive mode (%d)\n", tty, errno);

    struct termios termios;
    tcgetattr(fd, &termios);
    cfmakeraw(&termios);
    cfsetospeed(&termios, SW_SPEED);
    cfsetispeed(&termios, SW_SPEED);
    tcsetattr(fd, TCSAFLUSH, &termios);
    tcflush(fd, TCIOFLUSH);

    struct pollfd fds = {
        .fd = fd,
        .events = POLLIN,
    };

    char buf[4096];
    size_t len = 0;

    struct {
        int port, retry, config, config_if;
    } step = {0};

    dprintf(fd, "\004");

    while (1) {
        switch(poll(&fds, 1, 1000)) {
        case -1:
            die("poll failed: %d\n", errno);
        case 0:
            if (step.retry++ > 3)
                die("%s doesn't reply, give up...\n", tty);
            dprintf(fd, "\r");
            continue;
        }

        if (len + 80 > sizeof(buf)) {
            const size_t size = sizeof(buf) / 2;
            memcpy(buf, buf + size, size);
            len -= size;
        }

        ssize_t r = read(fd, buf + len, sizeof(buf) - len - 1);

        if (r == (ssize_t)-1) {
            if (errno == EAGAIN)
                continue;
            die("%s: couldn't read (%d)\n", tty, errno);
        } else if (!r) {
            die("%s: unexpectedly closed\n", tty);
        }

        len += r;
        buf[len] = 0;

        enum state state = s_unknown;

        for (unsigned k = 0; k < COUNT(actions); k++) {
            size_t alen = strlen(actions[k].str);
            if (len < alen || !strstr(buf, actions[k].str))
                continue;
            state = actions[k].state;
            step.retry = len = 0;
        }

        switch (state) {
        case s_username:
            dprintf(fd, "%s\r", getenv("SW_USER") ?: "admin");
            break;
        case s_password:
            dprintf(fd, "%s\r", getenv("SW_PASS") ?: "admin");
            break;
        case s_enable:
            dprintf(fd, "enable\r");
            break;
        case s_logged:
            if (step.config == 3)
                return 0;
            dprintf(fd, "config\r");
            break;
        case s_config:
            switch (step.config) {
            case 0:
                dprintf(fd, "vlan %lu\r", vlan);
                step.config = 1;
                break;
            case 2:
                if (step.port < port_count) {
                    dprintf(fd, "interface gi%lu\r", port[step.port].num);
                    step.config_if = 1;
                    break;
                }
                step.config = 3;       /* FALLTHRU */
            default:
                dprintf(fd, "exit\r");
            }
            break;
        case s_config_vlan:
            step.config = (step.config == 1) << 1;
            dprintf(fd, "exit\r");
            break;
        case s_config_if:
            switch (step.config_if) {
            case 1:
                dprintf(fd, "no shutdown\r");
                break;
            case 2:
                dprintf(fd, "switchport mode %s\r",
                        port[step.port].tag ? "trunk" : "access");
                break;
            case 3:
                dprintf(fd, "switchport %s %lu\r",
                        port[step.port].tag ? "trunk allowed vlan add"
                                            : "access vlan", vlan);
                break;
            case 4:
                step.port++;           /* FALLTHRU */
            default:
                dprintf(fd, "exit\r");
            }
            if (step.config_if)
                step.config_if++;      /* FALLTHRU */
        case s_unknown:
            break;
        }
    }

    return 0;
}
