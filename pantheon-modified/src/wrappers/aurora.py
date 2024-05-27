#!/usr/bin/env python

import os
from os import path
from subprocess import check_call

import arg_parser
import context


def main():
    args = arg_parser.receiver_first()

    cc_repo = path.join(context.third_party_dir, 'aurora')
    rl_dir = path.join(cc_repo, "PCC-RL")
    env_dir = path.join(cc_repo, "PCC-Uspace")
    env_src_dir = path.join(env_dir, 'src')
    env_lib_dir = path.join(env_src_dir, 'core')
    env_app_dir = path.join(env_src_dir, 'app')
    env_send_src = path.join(env_app_dir, 'pccclient')
    env_recv_src = path.join(env_app_dir, 'pccserver')

    if args.option == 'deps':
        print ('python3-dev')
        return

    if args.option == 'setup':
        # check_call(['sudo', 'apt', '-y', 'install', 'python3-pip'])
        check_call(['pip3', 'install', 'numpy==1.19.5'])
        check_call(['pip3', 'install', 'tensorflow==1.14.0'])
        check_call(['pip3', 'install', 'gym==0.15.3'])
        check_call(['pip3', 'install', 'stable-baselines==2.4.0'])
        check_call(['make'], cwd=env_src_dir)
        return

    if args.option == 'receiver':
        os.environ['LD_LIBRARY_PATH'] = path.join(env_lib_dir)
        cmd = [env_recv_src, 'recv', args.port]
        check_call(cmd)
        return

    if args.option == 'sender':
        os.environ['LD_LIBRARY_PATH'] = path.join(env_lib_dir)
        cmd = [env_send_src, 'send', args.ip, args.port,
               "--pcc-rate-control=python",
               "-pyhelper=loaded_client",
               "-pypath=" + os.path.join(rl_dir,"src/udt-plugins/testing/"),
               "--history-len=10", "--pcc-utility-calc=linear",
               "--model-path="+os.path.join(rl_dir, "src/gym/model_A")]
        check_call(cmd)
        return


if __name__ == '__main__':
    main()
