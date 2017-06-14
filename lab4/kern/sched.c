#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

//static int yieldtimes = 0;
// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;
	int i;
	//cprintf("SCHED_YIELD CALLED %d TIMES\n", yieldtimes++);
	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING) and never choose an
	// idle environment (env_type == ENV_TYPE_IDLE).  If there are
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	//cprintf("\tIn sched_yield, now is CPU%d\n",cpunum());
	int first_cand_env;
	if(thiscpu->cpu_env == NULL){
		//cprintf("\tFrank: now no env is on this cpu\n");
		first_cand_env = 0;
	}
	else{
		first_cand_env = (ENVX(thiscpu->cpu_env->env_id) + 1) % NENV;
	}
	for (i = 0; i < NENV; i++) {
		int candidate_env = (first_cand_env + i)%NENV;
		//cprintf("\t\t Candidate now is: envs[%d]\n\t\t\tTYPE is:%d\n\t\t\tSTATUS is:%d\n\t\t\tOWNER is CPU%d\n", 
		//	candidate_env, envs[candidate_env].env_type, envs[candidate_env].env_status, 
		//	envs[candidate_env].env_status == ENV_RUNNING ? envs[candidate_env].env_cpunum:-1);
		if (envs[candidate_env].env_type != ENV_TYPE_IDLE &&
		    envs[candidate_env].env_status == ENV_RUNNABLE){
			cprintf("\t\tFinal choose USERTYPE env[%d]\n",candidate_env);	
			env_run(&envs[candidate_env]);
		}
		else if (first_cand_env !=0 && i == NENV-1 && envs[candidate_env].env_type != ENV_TYPE_IDLE){
			//Frank: must be ENV_RUNNING as this env is the one who invokes sched_yield().(if invoker has no env, condition will not be satisfied for TYPE=IDLE)
			cprintf("\t\tFinal choose ORIGINAL env[%d]\n",candidate_env);
			env_run(&envs[candidate_env]);
		}
	}
	/*
	if (i == NENV) {
		cprintf("No more runnable environments!\n");
		while (1)
			monitor(NULL);
	}*/

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
		panic("CPU %d: No idle environment!", cpunum());
	env_run(idle);
}
