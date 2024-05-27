
#!/usr/bin/env python2
from os import path
from subprocess import check_call

import arg_parser
import context
from helpers import kernel_ctl
import sys
def setup_sage():
    sys.stderr.write("*******************\n******************* Before using Sage, make sure you have installed the proper Kernel patches (>4.19.112-0062) *******************\n*******************\n")

def main():
    args = arg_parser.sender_first()

    cc_repo1 = path.join(context.third_party_dir, 'sage')
    cc_repo = path.join(cc_repo1,'sage_rl')
    rl_fld = path.join(cc_repo, 'rl_module')
    send_src = path.join(cc_repo, 'sage.sh')
    recv_src = path.join(rl_fld, 'client')

    if args.option == 'setup':
        sh_cmd = './build.sh'
        check_call(sh_cmd, shell=True, cwd=cc_repo1)
        setup_sage()
        return

    if args.option == 'setup_after_reboot':
        setup_sage()
        return

    if args.option == 'sender':
        cmd = [send_src, "0", args.port, "wired24", "wired24", "1", "300", args.bw, args.bw2, "7", "0", "dataset-gen", "1500", args.actor_id, "0", "1", "1", "0", "0", args.run_id, args.data_dir, args.flow_id]
        sys.stderr.write("...  ...  ... %s\n" % (cmd))
        check_call(cmd)
        return

    if args.option == 'receiver':
        cmd = [recv_src, args.ip, ' 1 ' ,args.port]
        check_call(cmd)
        return

if __name__ == '__main__':
    main()
