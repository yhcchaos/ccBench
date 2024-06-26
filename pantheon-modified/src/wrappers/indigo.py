#!/usr/bin/env python2

from os import path
from subprocess import check_call

import arg_parser
import context


def main():
    args = arg_parser.sender_first()

    cc_repo = path.join(context.third_party_dir, 'indigo')
    send_src = path.join(cc_repo, 'dagger', 'run_sender.py')
    recv_src = path.join(cc_repo, 'env', 'run_receiver.py')

    if args.option == 'setup':
        check_call(['pip2 install tensorflow==1.14 --no-cache-dir --ignore-installed six'], shell=True)
        return

    if args.option == 'sender':
        cmd = ['python2', send_src, args.port]
        check_call(cmd)
        return

    if args.option == 'receiver':
        cmd = ['python2', recv_src, args.ip, args.port]
        check_call(cmd)
        return


if __name__ == '__main__':
    main()
