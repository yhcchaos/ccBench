import json
import argparse
from os import path
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--win-margin', metavar='WIN-MARGIN', type=float, required=True,
            default=10.0,help='win margin in % -> 10 means 10%')
    parser.add_argument('--win-start', metavar='WIN-BEGIN-TIME', type=int, required=True,
            default=0,help='start time in second (default 0)')
    parser.add_argument('--win-end', metavar='WIN-BEGIN-TIME', type=int,required=True,
            default=100,help='start time in second (default 0)')
    parser.add_argument("--datadir", "-d", help="datadirectory containing json files for the evaluation")
    parser.add_argument('--schemes', metavar='"SCHEME1 SCHEME2..."',help='analyze a space-separated list of schemes',required=True)

    args = parser.parse_args()
    win_start = args.win_start
    win_end = args.win_end
    win_margin = args.win_margin
    schemes = args.schemes.split()

    scheme_keys={}
    ml_schemes={}
    ml_schemes={"aurora","indigo","dcubic","dbbr","orca","pure"}
    for cc in schemes:
        #if cc in {"pure"}:
        #    scheme_keys[cc]="sage"
        #else:
        scheme_keys[cc]=str(cc)

    for flow_num in [1,2,3]:
        num_env = 0
        num_env_lossy = 0
        num_env_noloss = 0
        for loss in ["-0.01"]:
            #for link in []:
            for link in [12,24,48,96,192]:
                link_posts = ["-x1-35"]
                #FIXME: Mahimahi had an issue with higher than 250/300Mbps links! (This is resolved in our Remi Patch now!)
                '''
                if link==192:
                    #link_posts = ["","-2x-d-7s","-4x-d-7s"]
                    link_posts = ['-x0.5-25']
                elif link==12:
                    link_posts = ["-x2-25"]
                else:
                    link_posts = ["-x2-25", '-x0.5-25']   
                '''
                for link_post in link_posts:
                    #for uni_del in [5,10,20,40,80]:
                    for uni_del in [5, 10, 20, 40, 80]:
                        bdp=int(2*link*uni_del/12)
                        if flow_num==1:
                            bdp_multi = [1, 2, 4, 8, 16]
                        else:
                            bdp_multi = [1, 2, 4, 8, 16]
                        #for qs in [int(bdp/2),bdp,2*bdp,4*bdp,8*bdp,16*bdp]:
                        for mul in bdp_multi:
                            qs = int(mul*bdp)
                            dir_post=str(flow_num)+"-wired"+str(link)+link_post+"-"+str(uni_del)+"-"+str(qs)+loss

                            min_del_95=999999.0
                            min_del_avg=999999.0
                            min_del_90=999999.0
                            max_tput=0.0
                            final={}

                            winners=[]
                            max_score=0.0

                            for cc in schemes:
                                dir_post=str(flow_num)+"-wired"+str(link)+link_post+"-"+str(uni_del)+"-"+str(qs)+loss
                                dir_name="dataset-gen-"+cc+"-"+dir_post
                                data_dir = path.join(args.datadir, dir_name)
                                #info_path = path.join(data_dir, 'pantheon_metadata.json')
                                data_path = path.join(data_dir,'piecewise_perf_'+str(win_start)+'_'+str(win_end)+'.json')

                                #with open(info_path) as json_file:
                                #    info = json.load(json_file)

                                run_times   = 3   #   自己写
                                flows       = flow_num  #自己写
                                bw_share    = link // flows
                                with open(data_path) as json_file:
                                    meta = json.load(json_file)
                                
                                final[cc]={}
                                final[cc]['score']=0
                                final[cc]['tput']           = 0
                                final[cc]['delay_95']       = 0
                                final[cc]['delay_90']       = 0
                                final[cc]['delay_avg']      = 0
                                # even though we specify runtimes=3, very few environments only run one or two times.
                                real_run_times = 0
                                for run_id in range(1, 1 + run_times):
                                    #Avg:
                                    final[cc][str(run_id)]                   = {}
                                    final[cc][str(run_id)]['score']          = 0
                                    final[cc][str(run_id)]['tput']           = 0
                                    final[cc][str(run_id)]['tput_trunc_sum'] = 0
                                    final[cc][str(run_id)]['delay_95']       = 0
                                    final[cc][str(run_id)]['delay_90']       = 0
                                    final[cc][str(run_id)]['delay_avg']      = 0
                                    final[cc][str(run_id)]['loss_rate_all']  = 0
                                    final[cc][str(run_id)]['delay_avg_all']  = 0
                                    if str(run_id) in meta[scheme_keys[cc]] and  meta[scheme_keys[cc]][str(run_id)]['all']['delay_avg']<=5000:
                                        is_flow_num_right = True
                                        final[cc][str(run_id)]['loss_rate_all']  = meta[scheme_keys[cc]][str(run_id)]['all']['loss']
                                        final[cc][str(run_id)]['delay_avg_all']  = meta[scheme_keys[cc]][str(run_id)]['all']['delay_avg']
                                        for flow_id in range(1, flows + 1):
                                            if(str(flow_id) in meta[scheme_keys[cc]][str(run_id)]):
                                                try:
                                                    if meta[scheme_keys[cc]] != None and meta[scheme_keys[cc]][str(run_id)][str(flow_id)]['delay_avg']>0:
                                                        final[cc][str(run_id)]['tput']              +=  meta[scheme_keys[cc]][str(run_id)][str(flow_id)]['tput']
                                                        final[cc][str(run_id)]['tput_trunc_sum']    +=  min(bw_share, meta[scheme_keys[cc]][str(run_id)][str(flow_id)]['tput'])
                                                        final[cc][str(run_id)]['delay_avg']         +=  meta[scheme_keys[cc]][str(run_id)][str(flow_id)]['delay_avg']+uni_del
                                                        final[cc][str(run_id)]['delay_90']          +=  meta[scheme_keys[cc]][str(run_id)][str(flow_id)]['delay_90']+uni_del
                                                        final[cc][str(run_id)]['delay_95']          +=  meta[scheme_keys[cc]][str(run_id)][str(flow_id)]['delay']+uni_del
                                                except:
                                                    print("calculating stuff @"+str(data_dir)+":no valid data for "+str(cc))
                                            else:
                                                is_flow_num_right=False
                                        # our scores, we need to specify the proper loss_factor
                                        if is_flow_num_right==False:
                                            break
                                        real_run_times += 1
                                        loss_factor = 0
                                        final[cc][str(run_id)]['score'] = (final[cc][str(run_id)]['tput_trunc_sum'] - loss_factor * final[cc][str(run_id)]['loss_rate_all']) * (final[cc][str(run_id)]['tput_trunc_sum'] - loss_factor * final[cc][str(run_id)]['loss_rate_all']) / final[cc][str(run_id)]['delay_avg_all']
                                        #final[cc][str(run_id)]['score'] = (final[cc][str(run_id)]['tput_trunc_sum'] - loss_factor * final[cc][str(run_id)]['loss_rate_all'])  / final[cc][str(run_id)]['delay_avg_all']
                                        final[cc][str(run_id)]['tput'] /= flows
                                        final[cc][str(run_id)]['delay_95'] /= flows
                                        final[cc][str(run_id)]['delay_90'] /= flows
                                        final[cc][str(run_id)]['delay_avg'] /= flows
                                    final[cc]['score']          +=  final[cc][str(run_id)]['score']
                                    final[cc]['tput']           +=  final[cc][str(run_id)]['tput']        
                                    final[cc]['delay_95']       +=  final[cc][str(run_id)]['delay_95']
                                    final[cc]['delay_90']       +=  final[cc][str(run_id)]['delay_90']
                                    final[cc]['delay_avg']      +=  final[cc][str(run_id)]['delay_avg']
                                if real_run_times>0:
                                    final[cc]['score']          /=  real_run_times
                                    final[cc]['tput']           /=  real_run_times      
                                    final[cc]['delay_95']       /=  real_run_times
                                    final[cc]['delay_90']       /=  real_run_times
                                    final[cc]['delay_avg']      /=  real_run_times
                                else:
                                    print(data_dir+"-" + str(win_start) + "-" + str(win_end)+"-"+'real_run_times=0'+cc)
                            for cc in schemes:
                                for run_id in range(1, run_times+1):
                                    for flow_id in range(1, flows+1):
                                        if final[cc]['delay_avg']>0:
                                            if max_tput<final[cc]['tput']:
                                                max_tput=final[cc]['tput']

                                            if min_del_95>final[cc]['delay_95']:
                                                min_del_95=final[cc]['delay_95']

                                            if min_del_avg>final[cc]['delay_avg']:
                                                min_del_avg=final[cc]['delay_avg']

                                            if min_del_90>final[cc]['delay_90']:
                                                min_del_90=final[cc]['delay_90']

                                            if max_score<final[cc]['score']:
                                                max_score=final[cc]['score']

                            for cc in schemes:
                                #for run_id in range(1, run_times+1):
                                    #for flow_id in range(1, flows+1):
                                if final[cc]['delay_avg']>0:
                                    if (max_score*(1-win_margin/100.0))<=final[cc]['score']:
                                        winners.append(cc)
                            print('%s -> winners:%s'%(dir_post, winners))

                            for cc in schemes:
                                final[cc]['score_abs']=final[cc]['score']
                                final[cc]['tput_abs']=final[cc]['tput']
                                final[cc]['delay_95_abs']=final[cc]['delay_95']
                                final[cc]['delay_90_abs']=final[cc]['delay_90']
                                final[cc]['delay_avg_abs']=final[cc]['delay_avg']
                                final[cc]['score']/=max_score
                                final[cc]['tput']/=max_tput
                                final[cc]['delay_95']/=min_del_95
                                final[cc]['delay_avg']/=min_del_avg
                                final[cc]['delay_90']/=min_del_90

                            dataset_path = path.join(args.datadir,"dataset-gen-league-"+str(win_start)+"_"+str(win_end))
                            cmd = "mkdir -p %s" % (dataset_path)
                            
                            os.system(cmd)

                            dataset_log_path = path.join(dataset_path,"log")
                            cmd = "mkdir -p %s" % (dataset_log_path)
                            os.system(cmd)

                            tmp_file = path.join(dataset_path, 'tmp')
                            perf_sum = path.join(dataset_log_path, 'dataset-gen-all-'+dir_post+'-sum')
                            perf_sum_abs = path.join(dataset_log_path, 'dataset-gen-all-'+dir_post+'-sum-abs')
                            winner = path.join(dataset_log_path, 'dataset-gen-winner-'+dir_post)

                            final_file= open(tmp_file,"w")
                            final_file.write("scheme \t throughput \t dela_avg \t delay_95\n")

                            for cc in schemes:
                                if final[cc]['delay_avg']>0:
                                    final_file.write("{:s} \t {:.3f} \t {:.3f} \t {:.3f}\n".format(
                                        cc,final[cc]['tput'], final[cc]['delay_avg'],final[cc]['delay_95']))

                            final_file.close()

                            cmd = "column -t %s > %s && rm %s" % (tmp_file,perf_sum,tmp_file)
                            os.system(cmd)

                            final_file= open(tmp_file,"w")
                            final_file.write("scheme \t throughput \t dela_avg \t delay_95\n")
                            for cc in schemes:
                                if final[cc]['delay_avg_abs']>0:
                                    final_file.write("{:s} \t {:.3f} \t {:.3f} \t {:.3f}\n".format(
                                        cc,final[cc]['tput_abs'], final[cc]['delay_avg_abs'],final[cc]['delay_95_abs']))

                            final_file.close()
                            cmd = "column -t %s > %s && rm %s" % (tmp_file,perf_sum_abs,tmp_file)
                            os.system(cmd)

                            cmd="a=0"
                            for winner_ in winners:
                                cmd = "%s;echo %s >> %s" % (cmd,winner_,winner)
                            os.system(cmd)

                            num_env = num_env + 1
                            if loss=="-0":
                                num_env_noloss = num_env_noloss + 1
                            else:
                                num_env_lossy = num_env_lossy + 1

        #Multi Winner Case:
        cmd = 'cd %s;rm flow%d_winners;for i in log/dataset-gen-winner-%d-wired*; do for winner in `cat $i`; do  trace=`echo $i | sed "s/log\/dataset-gen-winner-/$winner-/g;"`;  echo $trace"_cwnd.txt" >> flow%d_winners;  done;done;' % (dataset_path, flow_num, flow_num, flow_num)
        os.system(cmd)

        #Total number of games/environments
        cmd='echo "total %d" > %s/flow%d_num_env' %(num_env,dataset_path, flow_num)
        cmd='%s;echo "noloss %d" >> %s/flow%d_num_env' %(cmd,num_env_noloss,dataset_path, flow_num)
        os.system(cmd)

if __name__== "__main__":
    main()
