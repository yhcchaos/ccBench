#!/usr/bin/env python

import os
from os import path
from subprocess import check_call
import logging
import arg_parser
import context


def main():
    args = arg_parser.receiver_first()

    cc_repo = path.join(context.third_party_dir, 'vivace', "pcc-gradient")
    recv_dir = path.join(cc_repo, 'receiver')
    send_dir = path.join(cc_repo, 'sender')
    recv_src = path.join(recv_dir, 'src')
    send_src = path.join(send_dir, 'src')
    recv_app = path.join(recv_dir, 'app', 'appserver')
    send_app = path.join(send_dir, 'app', 'gradient_descent_pcc_client')
    
    if args.option == 'setup':
        check_call(['make', '-j'], cwd=cc_repo)
        return
    
    if args.option == 'receiver':
        os.environ['LD_LIBRARY_PATH'] = path.join(recv_src)
        cmd = [recv_app, args.port]
        check_call(cmd)
        return

    if args.option == 'sender':
        os.environ['LD_LIBRARY_PATH'] = path.join(send_src)
        # ./gradient_descent_pcc_client pcc_server_ip pcc_server_port [latency_based]
        # Use default: Note that the parameter latency_based determines whether Vivace-Loss (latency_based = 0) or Vivace-Latency (latency_based = 1) is used. By default, latency_based = 0, and the PCC sender is not latency sensitive.
        cmd = [send_app, args.ip, args.port]
        check_call(cmd)
        return


if __name__ == '__main__':
    main()
