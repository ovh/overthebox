import logging
import logging.handlers

def init_logger(name):
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)

    syslog = logging.handlers.SysLogHandler(address='/dev/log')
    stdout = logging.StreamHandler()

    syslog.setFormatter(logging.Formatter('%(name)s: %(message)s'))

    logger.addHandler(syslog)
    logger.addHandler(stdout)

    return logger
